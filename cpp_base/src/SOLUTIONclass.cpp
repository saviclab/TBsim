#include <vector>
#include <algorithm>

#include <iostream>
#include "SOLUTIONclass.h"
#include "rungeKutta.h"
#include "statFunctions.h"

void SOLUTIONclass::initialize(int nD, int nT, int isG, int nC, int nB, int nM, int nI)
{
    nTime       = nT;
    activeDrugs = nD;
    isGranuloma = isG;
    nComp       = nC;
    nImmune     = nI;   // number of immune system variables (see list below)
    nMacro      = nM;   // number of macrophage types (0=Ma, 1=Mr, 2=Mi)
    nBact       = nB;   // number of main bacteria types (0=wild type, 1=total)

    VEC tempT(nTime, 0.0);
    VEC2 tempCT(nComp, tempT);

    // macrophages and bacteria
    M.assign(nMacro, tempCT);
    B.assign(nBact, tempCT);
    Br.assign(activeDrugs, tempCT);

    // immune system variables (calculation, and outputs), [0..nImmune]
    // 0=Tp, 1=T1, 2=T2, 3=MDC, 4=IDC, 5=TLN, 6=TpLN, 7=IL10
    // 8=IL4, 9=IFN, 10=IL12L, 11=IL12LN
    // immune parameters assumed to be similar across all compartments
    immune.assign(nImmune, tempT);

    // clear temporary variables
    tempT.clear();   tempCT.clear();
}
// copy from x vector to IM variables
// used to save daily simulation results
void SOLUTIONclass::copyXtoIM(int iT, VEC& xs, VEC& xBs)
{
        double s(0.0), b(0.0);  // temp variables

        int iC = 0;
        M[0][iC][iT] = xs[0];    // Ma in compartments I and III
        M[1][iC][iT] = xs[1];    // Mr
        M[2][iC][iT] = xs[2];    // Mi

        iC = 1;
        M[0][iC][iT] = xs[3];    // Ma in compartments II and IV
        M[1][iC][iT] = xs[4];    // Mr
        M[2][iC][iT] = xs[5];    // Mi

        // iterate for each compartment
        for (iC=0; iC<nComp; iC++){
            B[0][iC][iT]  = xs[18+iC];
            s=0.0;
            for (int iD=0; iD<activeDrugs; iD++){
                b = xBs[iD+iC*activeDrugs];
                Br[iD][iC][iT] = b;
                s += b;
            }
            B[1][iC][iT]  = xs[18+iC] + s;
        }

        // 0=Tp, 1=T1, 2=T2, 3=MDC, 4=IDC, 5=TLN, 6=TpLN, 7=IL10
        // 8=IL4, 9=IFN, 10=IL12L, 11=IL12LN
        immune[7][iT]  = xs[6];   // in all compartments
        immune[10][iT] = xs[7];
        immune[8][iT]  = xs[8];
        immune[9][iT]  = xs[9];
        immune[0][iT]  = xs[10];
        immune[1][iT]  = xs[11];
        immune[2][iT]  = xs[12];
        immune[11][iT] = xs[13];
        immune[5][iT]  = xs[14];
        immune[3][iT]  = xs[15];
        immune[4][iT]  = xs[16];
        immune[6][iT]  = xs[17];
}

//===============================================================
// Compute PD effects and TB immune response given input dose per
// drug and bacterial starting values,
// includes both intra- and extracellular effects
//================================================================
void SOLUTIONclass::simulateInfection(PARAMclass& PARA, int nPar, VEC& p, double immuneStatus,
                                      int nODE, VEC& xi, VEC& xBi,
                                      DRUGLISTclass& DRUGLIST, CONCclass& CONC,
                                      DOSEclass& DOSE, GRANclass& GRAN, MONITORclass& MONITOR)
{
    int nDrugs4 = activeDrugs*4;
    int nODEtot = nODE + nDrugs4;

    VEC xpRK(nODEtot, 0.0);
    VEC xfRK(nODEtot, 0.0);

    VEC xp(nODE, 0.0);              // input values to ODE solver
    VEC xf(nODE, 0.0);              // final results from ODE solver
    VEC xs(nODE, 0.0);              // sum of kMax time steps from ODE solver

    VEC xBp(nDrugs4, 0.0);          // drug resistant bacteria
    VEC xBf(nDrugs4, 0.0);          // drug resistant bacteria
    VEC xBs(nDrugs4, 0.0);          // drug resistant bacteria

    VEC pp(nPar, 0.0);              // ODE parameters for each patient
    VEC pt(nPar, 0.0);              // ODE parameters for each time step

    double ti(0.0), tf(0.0);        // time variables for ODE solver
    int iIndex(0);                  // integer counter
    VEC eKill;                      // external kill rate per drug
    VEC iKill;                      // internal kill rate per drug
    VEC eKillp;                     // external kill rate per drug - slow growing bacteria
    VEC iKillp;                     // internal kill rate per drug - slow growing bacteria
    VECI iPhase(activeDrugs);       // current kill phase per drug

    VECI ii(activeDrugs, 0);
    VEC mr(activeDrugs, 0.0);
    VEC gi(activeDrugs, 0.0);
    VEC ge(activeDrugs, 0.0);
    VEC tempV;

    // growth rate per bact population per compartment
    // index 0 = wild type, and 1..n for each mono drug resistant strain
    // initialize growth rate with 1.0
    VEC tempG(activeDrugs+1, 1.0);
    VEC2 growthRate(nComp, tempG);

    // data structure to transfer kill and growth factors to RK solver
    Factors f(activeDrugs);

    // parameters to filter bacteria below certain threshold
    // 0=initial growth; 1 = start filtering; 2=initial decline; 3=below threshold; 4=after minimum
    // bactMin is dummy starting value for lowest bacteria count
    int growthPhase1(0), growthPhase2(0);
    double bactMin1(1.0e10), bactMin2(1.0e10);

    // add variance to ODE initial parameters for wild type
    addVarianceNorm(xi, xp, nODE, PARA.initialValueStdv);

    // add variance to ODE initial parameters for for resistant strains
    addVarianceNorm(xBi, xBp, nDrugs4, PARA.initialValueStdv);

    // add variance to immune system parameters
    addVarianceNorm(p, pp, nPar, PARA.parameterStdv);

    // get indices, used for persistance calcs
    // get drug mutation rates
    // get drug growth inhibition factors - intra cellular
    // get drug growth inhibition factors - extra cellular
    for (int iD=0; iD<activeDrugs; iD++){
        ii[iD] = PARA.drugTable[iD];
        mr[iD] = DRUGLIST.get(iD).mutationRate;
        gi[iD] = DRUGLIST.get(iD).growIntra;
        ge[iD] = DRUGLIST.get(iD).growExtra;
    }
    // ODE integration using HOURLY time steps
    for (int iT=0; iT<nTime; iT++) {

        xs.assign (nODE,    0.0);           // clear calc vector
        xBs.assign(nDrugs4, 0.0);           // clear calc vector - resistant bacteria
        ti = double(iT);                    // current time value
        iIndex = iT * PARA.kMax;            // hourly index, used to save results

        // get 'kill phase' for each active drug, values 0 to 3
        for (int iD=0;iD<activeDrugs;iD++){
            iPhase[iD] = getKillPhase(DOSE.doseDays[iD][iT]);
        }

        // clear kill rate values
        eKill.assign (activeDrugs, 0.0);
        iKill.assign (activeDrugs, 0.0);
        eKillp.assign(activeDrugs, 0.0);
        iKillp.assign(activeDrugs, 0.0);

        // intra & extra cellular kill rates for each active drug
        for (int iD=0;iD<activeDrugs;iD++){
            int ii = PARA.drugTable[iD];
            // fast growing
            eKill[iD]= DRUGLIST.get(ii).kill_e[iPhase[iD]]  * DRUGLIST.get(ii).factorFast;  // extracellular
            iKill[iD]= DRUGLIST.get(ii).kill_i[iPhase[iD]]  * DRUGLIST.get(ii).factorFast;  // intracellular
            //slow growing
            eKillp[iD]= DRUGLIST.get(ii).kill_e[iPhase[iD]] * DRUGLIST.get(ii).factorSlow;  // extracellular
            iKillp[iD]= DRUGLIST.get(ii).kill_i[iPhase[iD]] * DRUGLIST.get(ii).factorSlow;  // intracellular
        }

        // add variance to kill rates - for each time step
        addVarianceLin(eKill,  eKill,  activeDrugs, PARA.timeStepStdv);
        addVarianceLin(iKill,  iKill,  activeDrugs, PARA.timeStepStdv);
        addVarianceLin(eKillp, eKillp, activeDrugs, PARA.timeStepStdv);
        addVarianceLin(iKillp, iKillp, activeDrugs, PARA.timeStepStdv);

        // add variance to ODE parameters - for each time step
        addVarianceLin(pp, pt, nPar, PARA.timeStepStdv);

        // iterate HOURLY time steps - for ONE day
        double dt = 1.0 / double(PARA.kMax);
        for (int k=0; k<PARA.kMax; k++){

            tf = ti + dt;               // tf = end time for ODE solver

            // calculate bacterial kill factors, per compartment and per bacterial strain - per active drugs
            tempV.assign(xBp.begin(), xBp.begin()+activeDrugs);
            bacterialKill(CONC.getKillIndex(0, iIndex), iIndex, eKill, eKillp,
                    1.0, PARA.isPersistance, PARA.isDrugEffect,
                    f.dB_I_w_k, f.dB_I_r_k, growthRate[0], MONITOR, 0, xp[18], tempV);

            tempV.assign(xBp.begin()+activeDrugs, xBp.begin()+activeDrugs*2);
            bacterialKill(CONC.getKillIndex(1, iIndex), iIndex, iKill, iKillp,
                    1.0, PARA.isPersistance, PARA.isDrugEffect,
                    f.dB_II_w_k, f.dB_II_r_k, growthRate[1], MONITOR, 1, xp[19], tempV);

            if (PARA.isGranuloma==1) {
                tempV.assign(xBp.begin()+activeDrugs*2,xBp.begin()+activeDrugs*3);
                bacterialKill(CONC.getKillIndex(2, iIndex), iIndex, eKill, eKillp,
                    PARA.granulomaKill, PARA.isPersistance, PARA.isDrugEffect,
                    f.dB_III_w_k, f.dB_III_r_k, growthRate[2], MONITOR, 2, xp[20], tempV);

                tempV.assign(xBp.begin()+activeDrugs*3,xBp.begin()+activeDrugs*4);
                bacterialKill(CONC.getKillIndex(3, iIndex), iIndex, iKill, iKillp,
                    PARA.granulomaKill, PARA.isPersistance, PARA.isDrugEffect,
                    f.dB_IV_w_k, f.dB_IV_r_k, growthRate[3], MONITOR, 3, xp[21], tempV);
            }
            // bacterial growth in each compartment
            double r = PARA.resistanceFitness;
            bacterialGrowth(CONC.getGrowIndex(0, iIndex), r, ge, f.dB_I_w_g,  f.dB_I_r_g);
            bacterialGrowth(CONC.getGrowIndex(1, iIndex), r, gi, f.dB_II_w_g, f.dB_II_r_g);

            if (PARA.isGranuloma==1) {
                bacterialGrowth(CONC.getGrowIndex(2, iIndex), r, ge, f.dB_III_w_g, f.dB_III_r_g);
                bacterialGrowth(CONC.getGrowIndex(3, iIndex), r, gi, f.dB_IV_w_g,  f.dB_IV_r_g);
            }

            // calculate bacterial mutations
            if (PARA.isResistance==1) {
                calcMutate(f.dB_I_w_g  * f.dB_I_BaseGrowth,  xp[18], mr, f.dB_I_w_m,  f.dB_I_r_m);
                calcMutate(f.dB_II_w_g * f.dB_II_BaseGrowth, xp[19], mr, f.dB_II_w_m, f.dB_II_r_m);

                if (PARA.isGranuloma==1){
                    calcMutate(f.dB_III_w_g * f.dB_III_BaseGrowth, xp[20],
                               mr, f.dB_III_w_m, f.dB_III_r_m);
                    calcMutate(f.dB_IV_w_g  * f.dB_IV_BaseGrowth,  xp[21],
                               mr, f.dB_IV_w_m,  f.dB_IV_r_m);
                }
            }
            // calculate bacteria sum per and across compartments
            f.B_I_tot   = calcB_tot(0, xp, xBp);
            f.B_II_tot  = calcB_tot(1, xp, xBp);
            f.B_III_tot = calcB_tot(2, xp, xBp);
            f.B_IV_tot  = calcB_tot(3, xp, xBp);
            f.B_12_tot  = f.B_I_tot   + f.B_II_tot;
            f.B_34_tot  = f.B_III_tot + f.B_IV_tot;
            f.B_tot     = f.B_12_tot  + f.B_34_tot;

            // calculate factors used to allocate immune system effect on bacteria
            double B_I_totDiv   = 1.0 / f.B_I_tot;
            double B_II_totDiv  = 1.0 / f.B_II_tot;
            double B_III_totDiv = 1.0 / f.B_III_tot;
            double B_IV_totDiv  = 1.0 / f.B_IV_tot;

            f.BIw  = xp[18] * B_I_totDiv;
            f.BIIw = xp[19] * B_II_totDiv;
            for (int iD=0; iD<activeDrugs; iD++){
                f.BIr[iD]  = xBp[iD] * B_I_totDiv;
                f.BIIr[iD] = xBp[iD+activeDrugs] * B_II_totDiv;
            }
            if (PARA.isGranuloma==1) {
                f.BIIIw = xp[20] * B_III_totDiv;
                f.BIVw  = xp[21] * B_IV_totDiv;
                for (int iD=0; iD<activeDrugs; iD++){
                    f.BIIIr[iD] = xBp[iD+activeDrugs*2] * B_III_totDiv;
                    f.BIVr[iD]  = xBp[iD+activeDrugs*3] * B_IV_totDiv;
                }
            }
            // calculate transfer of macrophages and bacteria into granuloma compartment
            if (PARA.isGranuloma==1) {
                double gr = GRAN.formationValue;
                double br = GRAN.breakupValue;

                // transfer of macrophages to granuloma
                double dMa_12_gran = xp[0] * gr;
                double dMr_12_gran = xp[1] * gr;
                double dMi_12_gran = xp[2] * gr;

                // transfer of macrophages to granuloma
                double dMa_34_gran = xp[3] * br;
                double dMr_34_gran = xp[4] * br;
                double dMi_34_gran = xp[5] * br;

                // net flow of macrophages due to granuloma formation and break up
                f.dMa_gran = dMa_34_gran - dMa_12_gran;
                f.dMr_gran = dMr_34_gran - dMr_12_gran;
                f.dMi_gran = dMi_34_gran - dMi_12_gran;

                // transfer of bacteria to granuloma
                double dB_I_w_gran   = xp[18] * gr;
                double dB_II_w_gran  = xp[19] * gr;

                // transfer of bacteria from granuloma
                double dB_III_w_gran = xp[20] * br;
                double dB_IV_w_gran  = xp[21] * br;

                f.dB_31_w_gran = dB_III_w_gran - dB_I_w_gran;
                f.dB_42_w_gran = dB_IV_w_gran  - dB_II_w_gran;

                VEC dB_I_r_gran(activeDrugs, 0.0),   dB_II_r_gran(activeDrugs, 0.0);
                VEC dB_III_r_gran(activeDrugs, 0.0), dB_IV_r_gran(activeDrugs, 0.0);
                VEC dB_31_r_gran(activeDrugs, 0.0),  dB_42_r_gran(activeDrugs, 0.0);

                for (int iD=0; iD<activeDrugs; iD++){
                    dB_I_r_gran[iD]   = xBp[iD]                    * gr;
                    dB_II_r_gran[iD]  = xBp[iD+activeDrugs]   * gr;
                    dB_III_r_gran[iD] = xBp[iD+activeDrugs*2] * br;
                    dB_IV_r_gran[iD]  = xBp[iD+activeDrugs*3] * br;
                    f.dB_31_r_gran[iD] = dB_III_r_gran[iD] - dB_I_r_gran[iD];
                    f.dB_42_r_gran[iD] = dB_IV_r_gran[iD]  - dB_II_r_gran[iD];
                }
            }
            // concatenate vector xp with vector xBp
            xpRK = xp;
            xpRK.insert(xpRK.end(), xBp.begin(), xBp.end());

            // ODE solver to integrate immune system and PD dynamics
            // uses 4th order Runge-Kutta method
            //std::cout << "\nPROCEEDING in SOLUTION 3.0::"<<immuneStatus<<std::endl;
            calcTB(ti, tf, xpRK, xfRK, nODEtot, pt, immuneStatus, PARA, f);
            //std::cout << "\nPROCEEDING in SOLUTION 3.9"<<std::endl;
            // extract sub vectors
            xf.assign (xfRK.begin(), xfRK.begin() + nODE);
            xBf.assign(xfRK.begin() + nODE, xfRK.begin() + nODE + nDrugs4);

            // save data on bacterial killing by IMMUNE system
            // apply (-) sign in order to match sign of drug factors
            MONITOR.setMonitor(activeDrugs, 0, iIndex, -f.dBeKill12);
            MONITOR.setMonitor(activeDrugs, 2, iIndex, -f.dBeKill34);
            // core variables
            for (int i=0; i<nODE; i++) {
                xf[i]  = std::max (xf[i],0.0); // apply "> zero" constraint
                xs[i] += xf[i];                // add to intermediate result sum
                xp[i]  = xf[i];                // prepare next ODE step
            }
            // resistant bacteria
            for (int i=0; i<nDrugs4; i++) {
                xBf[i]  = std::max (xBf[i],0.0); // apply "> zero" constraint
                xBs[i] += xBf[i];                // add to intermediate result sum
                xBp[i]  = xBf[i];                // prepare next ODE step
            }
            ti = tf;        // take next time step forward
            iIndex++;       // index used for kill and growth factors (hourly)
        }

        // multiply with delta time to get AVERAGE value for xs per DAY
        multVector (xs,  dt);
        multVector (xBs, dt);

        // filter bacterial after is below threshold - comp I and II
        filterBactData(iT, PARA.bactThreshold, PARA.bactThresholdRes,
                       PARA.drugStart, growthPhase1, bactMin1, xs[18],  xs[19], xBs, 0);

        // filter bacterial after is below threshold - comp III and IV
        if (PARA.isGranuloma==1){
            filterBactData(iT, PARA.bactThreshold, PARA.bactThresholdRes,
                           PARA.drugStart, growthPhase2, bactMin2, xs[20], xs[21], xBs, 1);
        }

        // save daily result values to IM results vector AND update totals
        copyXtoIM(iT, xs, xBs);

        // update granuloma formation parameters
        GRAN.calcGranuloma (iT, PARA.isGranuloma, PARA.granulomaFormation, PARA.granulomaBreakup,
                            B[1][0][iT], B[1][1][iT]);

        // calculate growth status of each bacteria strain and per compartment
        // note : should be updated to better reflect individual bact strains
        if (PARA.isPersistance==1) {
            growthRate[0] = calcGrowthStatus (f.dB_I_w_g  * f.dB_I_BaseGrowth,  PARA.growthLimit);
            growthRate[1] = calcGrowthStatus (f.dB_II_w_g * f.dB_II_BaseGrowth, PARA.growthLimit);
            if (PARA.isGranuloma==1){
                growthRate[2] = calcGrowthStatus (f.dB_III_w_g * f.dB_III_BaseGrowth,
                                                  PARA.growthLimit);
                growthRate[3] = calcGrowthStatus (f.dB_IV_w_g  * f.dB_IV_BaseGrowth,
                                                  PARA.growthLimit);
            }
        }
    }
}

// check for bacterial growth vs. previous time period
// low growth <for wild type!> => 0, high growth => 1
// keep in mind index=0 is wild type, and 1-to-n are for each of drugs
VEC SOLUTIONclass::calcGrowthStatus(double growthRate, double growthLimit)
{
    VEC rate(activeDrugs+1, 1.0);
    if (growthRate < growthLimit) {
        rate.assign(activeDrugs+1, 0.0);
    }
    return rate;
}

// Adjust bacterial vectors to check for end of infection vs. threshold level
// comp=0 is compartment I and II, comp=1 is compartment III and IV
void SOLUTIONclass::filterBactData(int iT, double bactThreshold, double bactThresholdRes,
                                   int drugStart, int& growthPhase, double& bactMin,
                                   double& x1, double& x2, VEC& Br, int iC)
{
    //int nDrugs = PARA.activeDrugs;
    double bactTotWild = x1 + x2;
    double bactTotRes = 0.0;
    double bactKilled = 1e-2;
    // add up resistant bacteria for selected compartment ('comp')
    for (int iD=0; iD<activeDrugs*2; iD++){
        bactTotRes += Br[iD+activeDrugs*2*iC];
    }
    double bactTot = bactTotWild + bactTotRes;

    // initial step
    if (iT>drugStart){
        if (growthPhase==0){
            growthPhase = 1;
        }
        // bacteria below threshold level
        else if ((growthPhase==1) && (bactTot<bactThreshold)){
            growthPhase = 2;
        }
        // bacteria after lowest level
        else if ((growthPhase==2) && (bactTot>bactMin)){
            growthPhase = 3;
        }
        // also resistant bact is low
        else if ((growthPhase==3) && (bactTotRes<bactThresholdRes)){
            growthPhase = 4;
        }

        // apply filter rules
        // update lowest bacteria level
        if (growthPhase==2){
            bactMin = std::min(bactMin, bactTot);  // save lowest point
        }
        // filter out wild-type bacteria
        else if (growthPhase>2){
            x1 = bactKilled;
            x2 = bactKilled;
            // filter out resistant bacteria
            if (growthPhase==4){
                for (int iD=0; iD<activeDrugs*2; iD++){
                    Br[iD+activeDrugs*2*iC] = 1e-10;
                }
            }
        }
    }
}

// get index for kill rate parameter
int SOLUTIONclass::getKillPhase (double daysOnDrug)
{
    int i(0);
    if (daysOnDrug < 1){        // no drug taken
        i=0;
    }
    else if (daysOnDrug < 3){   // drug taken for 1-2 days
        i=1;
    }
    else if (daysOnDrug < 15){  // drugs taken for 3-14 days
        i=2;
    }
    else {
        i=3;
    }
    return i;
}

void SOLUTIONclass::bacterialKill(VEC concKill, int iIndex, VEC& kill, VEC& killp,
                   double gran, int isPersistence, int isDrugEffect, double& w, VEC& r, VEC& rate,
                   MONITORclass& MONITOR, int iC, double Bw, VEC& Br)
{
    VEC k(activeDrugs, 0.0);
    // kill is kill rate for regular growing bacteria,
    // killp is kill rate for peristing bacteria (slow growing)
    for (int iD=0; iD<activeDrugs; iD++){
        k[iD] = concKill[iD]*kill[iD];
    }

    VEC kp(k);
    if (isPersistence==1)
    {
        for (int iD=0; iD<activeDrugs; iD++){
            kp[iD] = concKill[iD]*killp[iD];
        }
    }

    w = 0.0;
    if (rate[0]==1.0){
        for (int iD=0; iD<activeDrugs; iD++){
            w += k[iD];
        }
    }
    else {
        for (int iD=0; iD<activeDrugs; iD++){
            w += kp[iD];
        }
    }
    w *= gran;

    // drug resistant bacteria
    r.assign(activeDrugs, 0.0);
    for (int iD=0; iD<activeDrugs; iD++){
        if (rate[iD+1]==1.0){
            for (int jD=0; jD<activeDrugs; jD++){
                if (iD!=jD) {
                    r[iD] += k[jD];
                }
            }
        }
        else {
            for (int jD=0; jD<activeDrugs; jD++){
                if (iD!=jD){
                    r[iD] += kp[jD];
                }
            }
        }
        r[iD] *= gran;
    }

    if (isDrugEffect==1) {
        MONITOR.update(iC, iIndex, k, Bw, Br);
    }
    // NOTE : this does not track effect of persistance level
}

void SOLUTIONclass::bacterialGrowth(VEC concGrow, double fit, VEC& g, double& w, VEC& r)
{
    VEC c(concGrow);   // set default value

    for (int iD=0; iD<activeDrugs; iD++){
        c[iD] = 1.0 + g[iD] * (c[iD] - 1.0);
    }

    w = 1.0;
    r.assign(activeDrugs, fit);
    for (int iD=0; iD<activeDrugs; iD++){
        w *= c[iD];
        for (int jD=0; jD<activeDrugs; jD++){
            if (iD!=jD){
                r[iD] *= c[jD];
            }
        }
    }
}

// calculate mutated bacteria from wild type for each of the mono-resistant strains
void SOLUTIONclass::calcMutate(double w_netGrow, double w, VEC& mr, double& dw, VEC& dr)
{
    double B_delta = std::max(0.0, w_netGrow * w);  // abs of growth of wild type bacteria;

    dw = 0.0;
    for (int iD=0; iD<activeDrugs; iD++){
        dr[iD] = B_delta * mr[iD];
        dw -= dr[iD];
    }
}

// sum of bacteria in compartment iC
double SOLUTIONclass::calcB_tot(int iC, VEC& x, VEC& xB) {
    double s = 0.0;
    for (int iD=0; iD<activeDrugs; iD++){
        s += xB[iD+activeDrugs*iC];
    }
    return x[18+iC]+ s  + 1e-20; // the 1e-20 is to avoid div by zero
}


