#include <vector>
#include <algorithm>
#include <cmath>

#include "CONCclass.h"
#include "statFunctions.h"

//********************************************************************
// Initialize concentration calculation parameters and vectors
//********************************************************************
void CONCclass::initialize(int iD, int iT, int iS, int iC, int iG){
    activeDrugs = iD;
    nTime  = iT;
    nSteps = iS;
    nComp  = iC;
    isGranuloma = iG;

    VEC tempN0(nSteps, 0.0);
    VEC tempN1(nSteps, 1.0);
    VEC2 tempCN0 (nComp, tempN0);
    VEC2 tempCN1 (nComp, tempN1);

    // concentration and kill & growth function vectors per compartment and drug per time
    // note: growth factor vectors initialized with value=1.0 (zero bacteriostatic effect)
    // vector dimensions: [drugID][compartmentID][timeStep(hour)]

    concValue.assign(activeDrugs, tempCN0);
    concKill.assign(activeDrugs, tempCN0);
    concGrow.assign(activeDrugs, tempCN1);      // initialized with 1
}
//********************************************************************
// Calculate auto-induction effects on Ke parameter for PK calculation
// Checks drug dosing occurences during previous days
// Apply autoinduction proportional to number of days vs. KeTime
// Linear function starting at KeBase
// Reaches max value (KeMult * KeBase) when DaysOnDrug > KeTime
//********************************************************************
double CONCclass::autoInduction(double doseDays, double KeBase, double KeMult,
                                double KeTime)
{
    double daysOnDrug = std::min(KeTime, doseDays);

    return KeBase * (1.0 + (KeMult - 1.0) * daysOnDrug / KeTime);
}

//********************************************************************
// Generates concentration vectors for PK calculation
// Single compartment, first-order, elimination
// Solved using basic Euler method, with 100 steps per time increment
// Patient variability applied to each of the equation parameters
// Output is hourly concentration values for each drug in list
//********************************************************************
void CONCclass::setConc(PARAMclass& PARA, DRUGLISTclass& DRUGLIST, DOSEclass& DOSE)
{
    for (int iD=0; iD<activeDrugs; iD++) {
        int iDT = PARA.drugTable[iD];
        const int nSolve(100);
        const double dxSolve = 1.0 / double (nSolve);

        // patient-specific values by adding variance factor
        double Ka_p = DRUGLIST.get(iDT).KaMean * (1.0 + normDist(0.0, DRUGLIST.get(iDT).KaStdv, -0.9, 2.0));
        double Ke   = DRUGLIST.get(iDT).KeMean * (1.0 + normDist(0.0, DRUGLIST.get(iDT).KeStdv, -0.9, 2.0));
        double V_p  = DRUGLIST.get(iDT).V1Mean * (1.0 + normDist(0.0, DRUGLIST.get(iDT).V1Stdv, -0.9, 2.0));

        if (linDist(0.0, 1.0)>PARA.shareLowAcetylators){
            Ke = Ke * DRUGLIST.get(iDT).highAcetFactor;  // is high acetylator (for INH)
        }

        double A1(0.0), D(0.0);

        // iterate days
        for (int iT=DRUGLIST.getDrugStart(); iT<DRUGLIST.getDrugStop(); iT++) {
            // auto induction
            double Ke_p = autoInduction(DOSE.doseDays[iD][iT], Ke,
                                        DRUGLIST.get(iDT).KeMult, DRUGLIST.get(iDT).KeTime);

            //add variance to parameters for each time step
            double Ka_t = Ka_p * (1.0 + PARA.timeStepStdv * linDist(-0.5, 0.5));
            double Ke_t = Ke_p * (1.0 + PARA.timeStepStdv * linDist(-0.5, 0.5));
            double V_t  = V_p  * (1.0 + PARA.timeStepStdv * linDist(-0.5, 0.5));
            double V_tDiv = 1.0 / V_t;          // no check if divide by zero

            // add drug dose for that day
            D += DOSE.doseValue[iD][iT];
            // counter to save results
            int iIndex = PARA.kMax * iT;

            // iterate hours for each day
            for (int k=0; k<PARA.kMax; k++){
                // iterate Euler step-wise estimation for each hour
                for (int m=0; m<nSolve; m++){
                    double dD  = Ka_t * D;
                    double dA1 = dD - Ke_t * A1;

                    D  += - dD * dxSolve;
                    A1 += dA1  * dxSolve;

                    // apply strict non-zero constraint
                    D  = std::max(D,  0.0);
                    A1 = std::max(A1, 0.0);
                }

                // concentration for extracellular outside granuloma
                // applied to compartment 0
                concValue[iD][0][iIndex] = A1 * V_tDiv;

                // index to save hourly results
                iIndex++;
            }
        }
        // calculate drug concentration also in other compartments
        drugCompartmentTransfer(iD, PARA, DRUGLIST.get(iDT).IOfactor,
                                DRUGLIST.get(iDT).GRfactor, DRUGLIST.get(iDT).multiplier,
                                DRUGLIST.get(iDT).rise50, DRUGLIST.get(iDT).fall50,
                                DRUGLIST.get(iDT).decayFactor);
    }
}
//********************************************************************
// Calculate transfer of drug from main compartment to other compartments
// note: concentrations are applied as ratios vs. extracellular space
// thus calculation does NOT involve any actual mass transfer
// assumption is that transferred drug volume is relatively minimal
// method 1) uses 'basic' approach, with a gradual decline same for all drugs
// method 2) uses enhanced method insipired by Veronique's work
//********************************************************************
void CONCclass::drugCompartmentTransfer(int iD, PARAMclass& PARA,
                                        double IOfactor, double GRfactor,
                                        double multiplier, double rise50, double fall50,
                                        double decayFactor)
{
    // transfer from compartment I to compartment II
    // intracellular uptake assumed to occur relatively fast
    multVectorAlt(concValue[iD][0], concValue[iD][1],  IOfactor);

    if (PARA.isGranuloma==1){
        // basic method for transfer of drug into GRANULOMA and onwards
        if (PARA.isGradualDiffusion==0){
            // transfer from compartment I based to compartment III
            multVectorAlt(concValue[iD][0], concValue[iD][2], GRfactor);
        }
        // enhanced method to model diffusion in/out of granuloma
        else {
            // transfer from compartment I based to compartment III
            drugDiffusion(PARA, concValue[iD][0], concValue[iD][2],
                          multiplier, rise50, fall50);
        }
        // transfer from compartment III to compartment IV
        // assumes intracellular uptake is rapid relative to drug diffusion in/out of granuloma
        multVectorAlt(concValue[iD][2], concValue[iD][3], IOfactor);
    }

    // slow concentration decay out of INTRACELLULAR compartments
    // is only applied on declining concentration phase
    decayVector(concValue[iD][1], decayFactor);
    if (PARA.isGranuloma==1) {
        decayVector(concValue[iD][3], decayFactor);
    }
}
//********************************************************************
// Calculate diffusion in/out of granuloma
// uses rise50 and fall50 parameters to define speed of
// rise vs. decay of concentration profile
//********************************************************************
void CONCclass::drugDiffusion(PARAMclass& PARA, VEC& F, VEC& f,
                              double multiplier, double rise50, double fall50){
    // F is the source compartment
    // f is the target compartment

	// start for-loop at = 1 to allow compare with iN-1
	for (int iN=1; iN<PARA.nSteps; iN++){
        // lowest possible concentration
        double minf = 0.0;
        // highest possible concentration
        double maxf = F[iN] * multiplier;
        // concentration in last time step
        double lastf= f[iN-1];
        //first assign starting value based on previous time period
        double out  = lastf;
        // increasing concentration in F compartment
        if (maxf>lastf){
            out = std::min(maxf, lastf + std::abs(maxf - lastf) * rise50);
        }
        // decreasing concentration in F compartment
        else if (maxf<lastf){
            out = std::max(minf, lastf - std::abs(lastf - maxf) * fall50);
        }
        f[iN] = out;
	}
}

//********************************************************************
// Transform drug concentration levels for each compartment and drug
// to kill and grow ratios used in PD EC50 calculations
//********************************************************************
void CONCclass::setConcFactors(PARAMclass& PARA, DRUGLISTclass& DRUGLIST){

    int hourStart = PARA.drugStart * PARA.kMax;
    int hourStop  = std::min(nTime, PARA.drugStop+5) * PARA.kMax; // allow drugs to clear out

    for (int iC=0; iC<2; iC++){
        for (int iD=0; iD<activeDrugs; iD++) {
            int iDT = PARA.drugTable[iD];
            createConcFactors(hourStart, hourStop, concValue[iD][iC], concKill[iD][iC],
                              concGrow[iD][iC], DRUGLIST.get(iDT).EC50k,
                              DRUGLIST.get(iDT).ak, DRUGLIST.get(iDT).EC50g,
                              DRUGLIST.get(iDT).ag, DRUGLIST.get(iDT).ECStdv);
            if (isGranuloma==1) {
                createConcFactors(hourStart, hourStop, concValue[iD][iC+2], concKill[iD][iC+2],
                                  concGrow[iD][iC+2], DRUGLIST.get(iDT).EC50k,
                                  DRUGLIST.get(iDT).ak, DRUGLIST.get(iDT).EC50g,
                                  DRUGLIST.get(iDT).ag, DRUGLIST.get(iDT).ECStdv);
            }
        }
    }
}

//********************************************************************
// Use concentration vectors to generate factors for PD calculation
// Creates KILL and GROWTH factors based on formula incorporating
// EC50 and hill factor coefficient for both killing and growth rate
//********************************************************************
void CONCclass::createConcFactors(int hourStart, int hourStop, VEC& concValue,
                                  VEC& concKill, VEC& concGrow, double EC50k,
                                  double ak, double EC50g, double ag, double ECStdv)
{
    // apply patient-level variability to PD parameters
    double ECk_p = EC50k * (1.0 + normDist(0.0, ECStdv, -0.9, 2.0));
    double ak_p  = ak    * (1.0 + normDist(0.0, ECStdv, -0.9, 2.0));
    double EC50kPow = std::pow(ECk_p, ak_p);

    double ECg_p = EC50g * (1.0 + normDist(0.0, ECStdv, -0.9, 2.0));
    double ag_p  = ag    * (1.0 + normDist(0.0, ECStdv, -0.9, 2.0));
    double EC50gPow = std::pow(ECg_p, ag_p);

    for (int iN=hourStart; iN<hourStop; iN++){
        double conc = concValue[iN];
        double BePowak = std::pow(conc, ak_p);
        double BePowag = std::pow(conc, ag_p);

        concKill[iN] = BePowak /(EC50kPow + BePowak + 1e-20);
        concGrow[iN] = 1.0 - BePowag /(EC50gPow + BePowag + 1e-20);
    }
}

//********************************************************************
// Extract kill factors for given time index value and compartment
//********************************************************************
VEC CONCclass::getKillIndex(int iC, int iIndex){
    VEC tempC(activeDrugs, 0.0);
    for (int iD=0; iD<activeDrugs; iD++){
        tempC[iD] = concKill[iD][iC][iIndex];
    }
    return tempC;
}

//********************************************************************
// Extract growth factors for given time index value and compartment
//********************************************************************
VEC CONCclass::getGrowIndex(int iC, int iIndex){
    VEC tempC(activeDrugs, 0.0);
    for (int iD=0; iD<activeDrugs; iD++){
        tempC[iD] = concGrow[iD][iC][iIndex];
    }
    return tempC;
}


