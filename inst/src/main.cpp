//================================================================================
// Simulation of tuberculosis infection and drug treatment dynamics
//
// - flexible patient adherence patterns
// - flexible drug dosing, and combinations
// - multi-drug drug PK/PD effects
// - immune system effects
// - bacterial resistance (single drug)
// - granuloma formation and breakdown linked to bacterial load
// - dynamic drug diffusion in/out of granuloma and macrophages
// - monitoring of bacterial killing per compartment and drug
// - interactive or batch execution mode
//
// Author: John Fors
// Last revision: March 2, 2015
// Compiler: GNU GCC
// ================================================================================

#include <string>
#include <iostream>
#include <vector>
//#include <omp.h>
#include <fstream>
#include <cstdlib>
#include <random>

#include "Global.h"
#include "ADHclass.h"
#include "CONCclass.h"
#include "DOSEclass.h"
#include "DRUGclass.h"
#include "DRUGLISTclass.h"
#include "GRANclass.h"
#include "IMMUNEclass.h"
#include "SOLUTIONclass.h"
#include "MONITORclass.h"
#include "ODEclass.h"
#include "OUTCOMEclass.h"
#include "PARAMclass.h"
#include "printFunctions.h"
#include "csvFunctions.h"
#include "writeFunctions.h"
#include "TIMERclass.h"
#include "POPULATIONclass.h"

int main(int argc, char* argv[])
{

    // object for simulation parameters
    PARAMclass PARA;
    PARA.initialize();

    // Set seed
    std::default_random_engine generator (PARA.seed);

    // object for drug parameters
    DRUGLISTclass DRUGLIST;

    // thread id, and number of threads set
    int id(0), numberOfThreads;

    // timer used for run statistics
    TIMERclass TIMER;
    int showTime = 0;

    const std::string version = "2.4";

    // parse run-time parameters
    std::string configFolder, initFileName;
    if (argc>1) {
        configFolder = argv[1];
    }
    if (argc>2) {
        initFileName = argv[2];
    }

    // check folder and file name are valid, else stop program
    bool validFile = true;
    std::ifstream ifs (configFolder+initFileName);
    if (!ifs.is_open()) {
        std::cout << "Invalid config file parameters provided" << std::endl;
        validFile = false;
    }

    // set error variables used in file read process
    bool configStatus(true), therapyStatus(true), adherenceStatus(true), MEMSStatus(true), drugStatus(true);

    // load init file with model parameters, therapy definitions, and drug definitions
    if (validFile) {
        configStatus = PARA.readInit(configFolder, initFileName);
        printGreeting(version);
        std::cout << "Config folder : " << configFolder      << std::endl;
        std::cout << "Config file   : " << initFileName      << std::endl;
        std::cout << "Data folder   : " << PARA.dataFolder   << std::endl;
        printLine();

        if (configStatus) {
            // load therapy files with drug dose combinations for each therapy
            therapyStatus = PARA.readTherapy(configFolder);
            if(PARA.adherenceMEMS) {
                // load MEMS data from CSV file
                adherenceStatus = PARA.readMEMSAdherence(configFolder);
            } else {
                // load adherence files with patient adherence patterns (not MEMS)
                adherenceStatus = PARA.readAdherence(configFolder);
            }
            std::cout << "Done reading MEMS data." << std::endl;

            // load drug files with PK/PD/mutation parameters per drug
            drugStatus = DRUGLIST.initialize(PARA.nDrugs, configFolder, PARA.drugFile);
        }
    }
    // debug
    //configStatus = false;

    // run main program if no major errors in reading config files
    if ((validFile)&&(configStatus)) {
        if ((!adherenceStatus)||(!therapyStatus)||(!drugStatus)) {
            std::cout << "Note: some config files were not loaded"<<std::endl;
        }
        // set list of valid user inputs
        std::list<int> validInputs = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9};
        int inputValue(0);

        do {
            printLine();
            PARA.printParameters();

            // if NOT in batch mode then get user input
            if (PARA.batchMode==0) {
                printLine();
                // get valid input from user
                inputValue = getUserInput(validInputs);
            }
            // update PARA values
            PARA.updateParameter(inputValue);

            // if saving patient-level data then only use 1 thread, to avoid file access conflict
            if (PARA.isSavePatientResults==1) {
                numberOfThreads = 1;
            } else {
                numberOfThreads = PARA.nThreads;
            }

            // simulation - outer loop (multiple iterations)
            if ((PARA.batchMode==1) || (inputValue==0)) {
                TIMER.initialize(numberOfThreads);
                TIMER.start(0, 1);

                // parameters used for immune & bacterial differential equations
                ODEclass ODE;
                ODE.setInitialValues();
                PARA.nODE = ODE.getnODE();

                // initialize immune system status for population
                IMMUNEclass IMM;
                IMM.setInitialValues(PARA.disease);
                IMM.setImmuneStatus(PARA.nPatients, PARA.immuneMean, PARA.immuneStdv);

                // select drugs included in active therapy, and set key parameter values
                DRUGLIST.selectActiveDrugs(PARA);
                VEC2 doseFull = DRUGLIST.setDoseFullAdherence(PARA);

                // check if drug therapy extends beyond end of similation time
                if (!DRUGLIST.checkDrugStop(PARA)) {
                    std::cout << "WARNING: drug end point beyond simulation time" << std::endl;
                }
                // set drug start and stop time parameters (with limits applied)
                PARA.drugStart = DRUGLIST.getDrugStart();
                PARA.drugStop  = DRUGLIST.getDrugStop();

                // print list of active drugs in selected therapy
                DRUGLIST.printDrugList(PARA.activeDrugs, PARA.drugTable, PARA.drugID);

                POPULATIONclass POPULATION;
                int nSamples    = PARA.nIterations;
                int nSize       = PARA.nPatients;
                int nStat       = 3;        // median, and 95% confidence limits
                int nOutcome    = 4;        // no infection, acute, latent, cleared
                int nBact       = 2;        // wild type, resistant
                int nMacro      = 3;        // three states of macrophages
                int nImmune     = 12;       // 12 other immune system components

                // initialize vectors used to track simulation outcome
                POPULATION.initialize(PARA.nPatients, PARA.nTime, PARA.nSteps, PARA.activeDrugs,
                                      PARA.nComp, nSamples, nSize, nStat, nOutcome, nBact, nMacro,
                                      nImmune, PARA.nPopulations);

                if (PARA.nPopulations>1){
                    std::cout << "Generating " << PARA.nPopulations << " populations"<<std::endl;
                }
                else {
                    if (PARA.isBootstrap==1){
                        std::cout << "Generating base population for bootstrap processing"<<std::endl;
                    }
                }

                // initialize object to store population statistics
                // only used when NO bootstrap method
                if (PARA.isBootstrap==0) {
                    if ((PARA.isAdherence==1)&&(PARA.isSaveAdhDose==1)) {
                        POPULATION.setDimensions4(POPULATION.popAdherencePops,
                                                  PARA.nTime, 1, 1, 1, PARA.nPopulations);
                    }
                    if ((PARA.isDrugDose==1)&&(PARA.isSaveAdhDose==1)) {
                        POPULATION.setDimensions4(POPULATION.popDosePops,
                                                  PARA.nTime, PARA.activeDrugs, 1, 1, PARA.nPopulations);
                    }
                    if ((PARA.isConcentration==1)&&(PARA.isSaveConc==1)) {
                        POPULATION.setDimensions4(POPULATION.popConcPops,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1, PARA.nPopulations);
                    }
                    if ((PARA.isConcentration==1)&&(PARA.isSaveConcKill==1)) {
                        POPULATION.setDimensions4(POPULATION.popConcKillPops,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1, PARA.nPopulations);
                        POPULATION.setDimensions4(POPULATION.popConcGrowPops,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1, PARA.nPopulations);
                    }
                    if ((PARA.isSolution==1)&&(PARA.isSaveImmune==1)) {
                        POPULATION.setDimensions4(POPULATION.popImmunePops,
                                                  PARA.nTime, nImmune, 1, 1, PARA.nPopulations);
                    }
                    if ((PARA.isSolution==1)&&(PARA.isSaveBact==1)) {
                        POPULATION.setDimensions4(POPULATION.popBactPops,
                                                  PARA.nTime, nBact, PARA.nComp, nStat, PARA.nPopulations);
                    }
                    if ((PARA.isSolution==1)&&(PARA.isSaveBactRes==1)) {
                        POPULATION.setDimensions4(POPULATION.popBactResPops,
                                                  PARA.nTime, PARA.activeDrugs, PARA.nComp, nStat, PARA.nPopulations);
                    }
                    if ((PARA.isSolution==1)&&(PARA.isSaveMacro==1)) {
                        POPULATION.setDimensions4(POPULATION.popMacroPops,
                                                  PARA.nTime, nMacro, 2, 1, PARA.nPopulations);
                    }
                    if ((PARA.isDrugEffect==1)&&(PARA.isSaveEffect==1)) {
                        POPULATION.setDimensions4(POPULATION.popMonitorPops,
                                                  PARA.nTime, PARA.activeDrugs+2, PARA.nComp, 1, PARA.nPopulations);
                    }
                    if ((PARA.isOutcome==1)&&(PARA.isSaveOutcome==1)) {
                        POPULATION.setDimensions4(POPULATION.popOutcomePops,
                                                  PARA.nTime, nOutcome, 1, nStat, PARA.nPopulations);
                    }
                }

                // outer loop for population interations - used when NO bootstrap processing
                int iPop;
                for (iPop=0; iPop<PARA.nPopulations; iPop++) {
                    // set infection starting conditions, used for ALL patients
                    ODE.createInfection(PARA.infI, PARA.infII, PARA.infIII, PARA.infIV);
                    ODE.createResistanceStart(PARA.activeDrugs, PARA.resistanceRatio);

                    // simulation - inner loop - per patient
                    // initialize data objects used for transient data per patient
                    // note: these vectors are replicated for each omp thread
                    int iP;
                    ADHclass ADH;
                    DOSEclass DOSE;
                    CONCclass CONC;
                    GRANclass GRAN;
                    SOLUTIONclass SOLUTION;
                    MONITORclass MONITOR;
                    OUTCOMEclass OUTCOME;

                    TIMER.stop(0, 1);
                    std::cout << "Population generation : " << iPop << " ";
                    int oldiP=0;
                    // set step to be 10% of population, and adjust for number of threads
                    int iStep = int(0.1*PARA.nPatients/numberOfThreads);
                    // distribute patient population across available processing cores
#pragma omp parallel for private(ADH, DOSE, CONC, GRAN, SOLUTION, MONITOR, OUTCOME) num_threads(numberOfThreads)
                    for (iP=0; iP<PARA.nPatients; iP++) {
                        int id=0;
                        //id = omp_get_thread_num();
                        // display simulation progress, note: ONLY done by thread 0
                        if ((id==0)&&((iP-oldiP)>iStep)) {
                            oldiP=iP;
                            std::cout << ".";
                        }

                        // generate pt adherence with variation per day
                        std::cout << "Patient:" << iP << std::endl;
                        if (PARA.isAdherence==1) {
                            TIMER.start(id, 2);
                            ADH.initialize(PARA.nTime);
                            std::cout << "Loading adherence" << std::endl;
                            ADH.setAdherence(PARA, iP);
                            std::cout << "Done" << std::endl;
                            if (PARA.isSaveAdhDose==1) {
                                POPULATION.transfer(POPULATION.popAdherenceBase,
                                                    ADH.adherenceValue, iP, 1, 1, PARA.nTime);
                            }

                            TIMER.stop(id, 2);
                        }
                        // generate pt dose, per drug, by multiplying base dose with pt adherence
                        if (PARA.isDrugDose==1) {
                            TIMER.start(id, 3);
                            DOSE.initialize(PARA.activeDrugs, PARA.nTime);
                            DOSE.setDose(ADH.adherenceValue, doseFull);
                            if (PARA.isSaveAdhDose==1) {
                                POPULATION.transfer(POPULATION.popDoseBase, DOSE.doseValue,
                                                    iP, PARA.activeDrugs, 1, PARA.nTime);
                            }
                            TIMER.stop(id, 3);
                        }
                        // generate pt drug concentration and concetration grow & kill factors, per drug
                        if (PARA.isConcentration==1) {
                            TIMER.start(id, 4);
                            CONC.initialize(PARA.activeDrugs, PARA.nTime,
                                            PARA.nSteps, PARA.nComp, PARA.isGranuloma);
                            CONC.setConc(PARA, DRUGLIST, DOSE);
                            CONC.setConcFactors(PARA, DRUGLIST);
                            if (PARA.isSaveConc==1) {
                                POPULATION.transfer(POPULATION.popConcBase, CONC.concValue,
                                                    iP, PARA.activeDrugs, PARA.nComp, PARA.nSteps);
                            }
                            if (PARA.isSaveConcKill==1) {
                                POPULATION.transfer(POPULATION.popConcKillBase, CONC.concKill,
                                                    iP, PARA.activeDrugs, PARA.nComp, PARA.nSteps);
                                POPULATION.transfer(POPULATION.popConcGrowBase, CONC.concGrow,
                                                    iP, PARA.activeDrugs, PARA.nComp, PARA.nSteps);
                            }
                            TIMER.stop(id, 4);
                        }
                        // generate current infection status, and kill contribution for each drug
                        if (PARA.isSolution==1) {
                            TIMER.start(id, 5);
                            GRAN.initialize(PARA.nTime);
                            MONITOR.initialize(PARA.activeDrugs, PARA.nTime, PARA.nSteps, PARA.nComp);
                            SOLUTION.initialize(PARA.activeDrugs, PARA.nTime, PARA.isGranuloma,
                                                PARA.nComp, nBact, nMacro, nImmune);
                            // prepare solver initial conditions
                            VEC tempp = IMM.getp();
                            VEC tempxi = ODE.getxi();
                            VEC tempxBi = ODE.getxBi();
                            // run main PD and immune system simulation solver
                            SOLUTION.simulateInfection(PARA, IMM.getnPar(), tempp, IMM.getCalcI(iP),
                                                       ODE.getnODE(), tempxi, tempxBi,
                                                       DRUGLIST, CONC, DOSE, GRAN, MONITOR);
                            // immune system, 1 compartment, i.e., same across all tissues
                            if(PARA.isSaveImmune==1) {
                                POPULATION.transfer(POPULATION.popImmuneBase, SOLUTION.immune,
                                                    iP, nImmune, 1, PARA.nTime);
                            }
                            // macrophages, 2 compartments (inside and outside granuloma)
                            if(PARA.isSaveMacro==1) {
                                POPULATION.transfer(POPULATION.popMacroBase, SOLUTION.M,
                                                    iP, nMacro, 2, PARA.nTime);
                            }
                            // wild type and total bacteria (for each of 4 compartments)
                            if(PARA.isSaveBact==1) {
                                POPULATION.transfer(POPULATION.popBactBase, SOLUTION.B,
                                                    iP, nBact, PARA.nComp, PARA.nTime);
                            }
                            // resistant bacteria
                            if(PARA.isSaveBactRes==1) {
                                POPULATION.transfer(POPULATION.popBactResBase, SOLUTION.Br,
                                                    iP, PARA.activeDrugs, PARA.nComp, PARA.nTime);
                            }
                            // track drug effect, i.e., share of killing per drug, per compartment
                            if ((PARA.isSaveEffect==1) && (PARA.isDrugEffect==1)) {
                                //cout << "start finalize"<<endl;
                                MONITOR.finalize(PARA.granulomaKill, SOLUTION.B);
                                POPULATION.transfer(POPULATION.popMonitorBase, MONITOR.monitorDaily,
                                                    iP, PARA.activeDrugs+2, PARA.nComp, PARA.nTime);
                            }
                            TIMER.stop(id, 5);
                        }
                        // update patient therapy outcome vector, 1 compartment (obviously)
                        if ((PARA.isOutcome==1) && (PARA.isSolution==1)) {
                            TIMER.start(id, 6);
                            OUTCOME.initialize(PARA.nTime, nOutcome);
                            OUTCOME.setOutcome(PARA.isGranuloma, PARA.freeBactLevel,
                                               PARA.latentBactLevel, SOLUTION.B);
                            if(PARA.isSaveOutcome==1) {
                                POPULATION.transfer(POPULATION.popOutcomeBase, OUTCOME.outcome,
                                                    iP, nOutcome, 1, PARA.nTime);
                            }
                            TIMER.stop(id, 6);
                        }

                        // write individual patient results to file
                        // note: do not use for large-scale simulation size, since creates big overhead
                        if (PARA.isSavePatientResults==1) {
                            TIMER.start(id, 8);
                            writeDetails(iP, PARA, SOLUTION, CONC, ADH, version);
                            TIMER.stop(id, 8);
                        }
                    } // patients loop

                    // create population statistics and save to storage vector
                    // note: only used when NO bootstrap processing
                    if (PARA.isBootstrap==0) {
                        if ((PARA.isAdherence==1)&&(PARA.isSaveAdhDose==1)) {
                            POPULATION.savePopulation(POPULATION.popAdherenceBase,
                                                      POPULATION.popAdherencePops,
                                                      iPop, 1, 1, PARA.nTime, PARA.therapyStart, 1);
                        }
                        if ((PARA.isDrugDose==1)&&(PARA.isSaveAdhDose==1)) {
                            POPULATION.savePopulation(POPULATION.popDoseBase,
                                                      POPULATION.popDosePops,
                                                      iPop, PARA.activeDrugs, 1, PARA.nTime, PARA.therapyStart, 1);
                        }
                        if ((PARA.isConcentration==1)&&(PARA.isSaveConc==1)) {
                            POPULATION.savePopulation(POPULATION.popConcBase,
                                                      POPULATION.popConcPops,
                                                      iPop, PARA.activeDrugs, PARA.nComp,
                                                      PARA.nSteps, PARA.therapyStart*24, 1);
                        }
                        if ((PARA.isConcentration==1)&&(PARA.isSaveConcKill==1)) {
                            POPULATION.savePopulation(POPULATION.popConcKillBase,
                                                      POPULATION.popConcKillPops,
                                                      iPop, PARA.activeDrugs, PARA.nComp,
                                                      PARA.nSteps, PARA.therapyStart*24, 1);
                            POPULATION.savePopulation(POPULATION.popConcGrowBase,
                                                      POPULATION.popConcGrowPops,
                                                      iPop, PARA.activeDrugs, PARA.nComp,
                                                      PARA.nSteps, PARA.therapyStart*24, 1);
                        }
                        if ((PARA.isSolution==1)&&(PARA.isSaveImmune==1)) {
                            POPULATION.savePopulation(POPULATION.popImmuneBase,
                                                      POPULATION.popImmunePops,
                                                      iPop, nImmune, 1, PARA.nTime, 0, 1);
                        }
                        if ((PARA.isSolution==1)&&(PARA.isSaveBact==1)) {
                            POPULATION.savePopulation(POPULATION.popBactBase,
                                                      POPULATION.popBactPops,
                                                      iPop, nBact, PARA.nComp, PARA.nTime, 0, nStat);
                        }
                        if ((PARA.isSolution==1)&&(PARA.isSaveBactRes==1)) {
                            POPULATION.savePopulation(POPULATION.popBactResBase,
                                                      POPULATION.popBactResPops,
                                                      iPop, PARA.activeDrugs, PARA.nComp, PARA.nTime, 0, 1);
                        }
                        if ((PARA.isSolution==1)&&(PARA.isSaveMacro==1)) {
                            POPULATION.savePopulation(POPULATION.popMacroBase,
                                                      POPULATION.popMacroPops,
                                                      iPop, nMacro, 2, PARA.nTime, 0, 1);
                        }
                        if ((PARA.isDrugEffect==1)&&(PARA.isSaveEffect==1)) {
                            POPULATION.savePopulation(POPULATION.popMonitorBase,
                                                      POPULATION.popMonitorPops,
                                                      iPop, PARA.activeDrugs+2, PARA.nComp, PARA.nTime, 0, 1);
                        }
                        if ((PARA.isOutcome==1)&&(PARA.isSaveOutcome==1)) {
                            POPULATION.savePopulationOutcome(POPULATION.popOutcomeBase,
                                                             POPULATION.popOutcomePops,
                                                             iPop, nOutcome, 1, PARA.nTime, 0, nStat);
                        }

                        //cout << iPop <<endl;
                        //cout << "No TB      "<<POPULATION.popOutcomePops[0][0][0][360][iPop]<<endl;
                        //cout << "Acute TB   "<<POPULATION.popOutcomePops[1][0][0][360][iPop]<<endl;
                        //cout << "Latent TB  "<<POPULATION.popOutcomePops[2][0][0][360][iPop]<<endl;
                        //cout << "Cleared TB "<<POPULATION.popOutcomePops[3][0][0][360][iPop]<<endl;
                    }
                    std::cout<<std::endl;
                }  // multiple populations loop

                TIMER.start(id, 7);

                // post-processing of patient population - when NO bootstrap
                if (PARA.isBootstrap==0) {
                    std::cout << "Statistics for multiple populations";
                    if ((PARA.isAdherence==1)&&(PARA.isSaveAdhDose==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popAdherenceStatistics,
                                                  PARA.nTime, 1, 1, 1);
                        POPULATION.finalizePopStat(POPULATION.popAdherencePops,
                                                   POPULATION.popAdherenceStatistics,
                                                   1, 1, PARA.nTime, PARA.therapyStart, 1, PARA.nPopulations);
                        POPULATION.popAdherencePops.clear();
                    }
                    //================================================
                    if ((PARA.isDrugDose==1)&&(PARA.isSaveAdhDose==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popDoseStatistics,
                                                  PARA.nTime, PARA.activeDrugs, 1, 1);
                        POPULATION.finalizePopStat(POPULATION.popDosePops,
                                                   POPULATION.popDoseStatistics,
                                                   PARA.activeDrugs, 1, PARA.nTime, PARA.therapyStart, 1,
                                                   PARA.nPopulations);
                        POPULATION.popDosePops.clear();
                    }
                    //================================================
                    if ((PARA.isConcentration==1)&&(PARA.isSaveConc==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popConcStatistics,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1);
                        POPULATION.finalizePopStat(POPULATION.popConcPops,
                                                   POPULATION.popConcStatistics,
                                                   PARA.activeDrugs, PARA.nComp,
                                                   PARA.nSteps, PARA.therapyStart*24, 1, PARA.nPopulations);
                        POPULATION.popConcPops.clear();
                    }
                    //================================================
                    if ((PARA.isConcentration==1)&&(PARA.isSaveConcKill==1)) {
                        std::cout << ".";
                        // concentration kill factors
                        POPULATION.setDimensions3(POPULATION.popConcKillStatistics,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1);
                        POPULATION.finalizePopStat(POPULATION.popConcKillPops,
                                                   POPULATION.popConcKillStatistics,
                                                   PARA.activeDrugs, PARA.nComp,
                                                   PARA.nSteps, PARA.therapyStart*24, 1, PARA.nPopulations);
                        POPULATION.popConcKillPops.clear();

                        // concentration growth factors
                        POPULATION.setDimensions3(POPULATION.popConcGrowStatistics,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1);
                        POPULATION.finalizePopStat(POPULATION.popConcGrowPops,
                                                   POPULATION.popConcGrowStatistics,
                                                   PARA.activeDrugs, PARA.nComp,
                                                   PARA.nSteps, PARA.therapyStart*24, 1, PARA.nPopulations);
                        POPULATION.popConcGrowPops.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveImmune==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popImmuneStatistics,
                                                  PARA.nTime, nImmune, 1, 1);
                        POPULATION.finalizePopStat(POPULATION.popImmunePops,
                                                   POPULATION.popImmuneStatistics,
                                                   nImmune, 1, PARA.nTime, 0, 1, PARA.nPopulations);
                        POPULATION.popImmunePops.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveBact==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popBactStatistics,
                                                  PARA.nTime, nBact, PARA.nComp, nStat);
                        POPULATION.finalizePopStat(POPULATION.popBactPops,
                                                   POPULATION.popBactStatistics,
                                                   nBact, PARA.nComp, PARA.nTime, 0, nStat, PARA.nPopulations);
                        POPULATION.popBactPops.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveBactRes==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popBactResStatistics,
                                                  PARA.nTime, PARA.activeDrugs, PARA.nComp, nStat);
                        POPULATION.finalizePopStat(POPULATION.popBactResPops,
                                                   POPULATION.popBactResStatistics,
                                                   PARA.activeDrugs, PARA.nComp,
                                                   PARA.nTime, 0, 1, PARA.nPopulations);
                        POPULATION.popBactResPops.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveMacro==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popMacroStatistics,
                                                  PARA.nTime, nMacro, 2, 1);
                        POPULATION.finalizePopStat(POPULATION.popMacroPops,
                                                   POPULATION.popMacroStatistics,
                                                   nMacro, 2, PARA.nTime, 0, 1, PARA.nPopulations);
                        POPULATION.popMacroPops.clear();
                    }
                    //================================================
                    if ((PARA.isDrugEffect==1)&&(PARA.isSaveEffect==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popMonitorStatistics,
                                                  PARA.nTime, PARA.activeDrugs+2, PARA.nComp, 1);
                        POPULATION.finalizePopStat(POPULATION.popMonitorPops,
                                                   POPULATION.popMonitorStatistics,
                                                   PARA.activeDrugs+2, PARA.nComp,
                                                   PARA.nTime, 0, 1, PARA.nPopulations);
                        POPULATION.popMonitorPops.clear();
                    }
                    //================================================
                    if ((PARA.isOutcome==1)&&(PARA.isSaveOutcome==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions3(POPULATION.popOutcomeStatistics,
                                                  PARA.nTime, nOutcome, 1, nStat);
                        POPULATION.finalizePopStat(POPULATION.popOutcomePops,
                                                   POPULATION.popOutcomeStatistics,
                                                   nOutcome, 1, PARA.nTime, 0, nStat, PARA.nPopulations);
                        POPULATION.popOutcomePops.clear();
                    }
                    std::cout << std::endl;
                    // end regular statistics statistics
                }

                // post processing of patient population
                // used for bootstrap processing
                if (PARA.isBootstrap==1) {
                    std::cout << "Bootstrap sampling";
                    if ((PARA.isAdherence==1)&&(PARA.isSaveAdhDose==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popAdherenceSamples,
                                                  PARA.nTime, 1, nSamples, 1);
                        POPULATION.setDimensions3(POPULATION.popAdherenceStatistics,
                                                  PARA.nTime, 1, 1, 1);
                        POPULATION.finalizeStatistics(POPULATION.popAdherenceBase,
                                                      POPULATION.popAdherenceSamples,
                                                      POPULATION.popAdherenceStatistics,
                                                      1, 1, PARA.nTime, PARA.therapyStart, 1);
                        POPULATION.popAdherenceBase.clear();
                        POPULATION.popAdherenceSamples.clear();
                    }
                    //================================================
                    if ((PARA.isDrugDose==1)&&(PARA.isSaveAdhDose==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popDoseSamples,
                                                  PARA.nTime, PARA.activeDrugs, nSamples, 1);
                        POPULATION.setDimensions3(POPULATION.popDoseStatistics,
                                                  PARA.nTime, PARA.activeDrugs, 1, 1);
                        POPULATION.finalizeStatistics(POPULATION.popDoseBase,
                                                      POPULATION.popDoseSamples,
                                                      POPULATION.popDoseStatistics,
                                                      PARA.activeDrugs, 1, PARA.nTime, PARA.therapyStart, 1);
                        POPULATION.popDoseBase.clear();
                        POPULATION.popDoseSamples.clear();
                    }
                    //================================================
                    if ((PARA.isConcentration==1)&&(PARA.isSaveConc==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popConcSamples,
                                                  PARA.nSteps, PARA.activeDrugs, nSamples, PARA.nComp);
                        POPULATION.setDimensions3(POPULATION.popConcStatistics,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1);
                        POPULATION.finalizeStatistics(POPULATION.popConcBase,
                                                      POPULATION.popConcSamples,
                                                      POPULATION.popConcStatistics,
                                                      PARA.activeDrugs, PARA.nComp,
                                                      PARA.nSteps, PARA.therapyStart*24, 1);
                        POPULATION.popConcBase.clear();
                        POPULATION.popConcSamples.clear();
                    }
                    //================================================
                    if ((PARA.isConcentration==1)&&(PARA.isSaveConcKill==1)) {
                        std::cout << ".";
                        // concentration kill factors
                        POPULATION.setDimensions2(POPULATION.popConcKillSamples,
                                                  PARA.nSteps, PARA.activeDrugs, nSamples, PARA.nComp);
                        POPULATION.setDimensions3(POPULATION.popConcKillStatistics,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1);
                        POPULATION.finalizeStatistics(POPULATION.popConcKillBase,
                                                      POPULATION.popConcKillSamples,
                                                      POPULATION.popConcKillStatistics,
                                                      PARA.activeDrugs, PARA.nComp,
                                                      PARA.nSteps, PARA.therapyStart*24, 1);
                        POPULATION.popConcKillBase.clear();
                        POPULATION.popConcKillSamples.clear();

                        // concentration growth factors
                        POPULATION.setDimensions2(POPULATION.popConcGrowSamples,
                                                  PARA.nSteps, PARA.activeDrugs, nSamples, PARA.nComp);
                        POPULATION.setDimensions3(POPULATION.popConcGrowStatistics,
                                                  PARA.nSteps, PARA.activeDrugs, PARA.nComp, 1);
                        POPULATION.finalizeStatistics(POPULATION.popConcGrowBase,
                                                      POPULATION.popConcGrowSamples,
                                                      POPULATION.popConcGrowStatistics,
                                                      PARA.activeDrugs, PARA.nComp,
                                                      PARA.nSteps, PARA.therapyStart*24, 1);
                        POPULATION.popConcGrowBase.clear();
                        POPULATION.popConcGrowSamples.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveImmune==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popImmuneSamples,
                                                  PARA.nTime, nImmune, nSamples, 1);
                        POPULATION.setDimensions3(POPULATION.popImmuneStatistics,
                                                  PARA.nTime, nImmune, 1, 1);
                        POPULATION.finalizeStatistics(POPULATION.popImmuneBase,
                                                      POPULATION.popImmuneSamples,
                                                      POPULATION.popImmuneStatistics,
                                                      nImmune, 1, PARA.nTime, 0, 1);
                        POPULATION.popImmuneBase.clear();
                        POPULATION.popImmuneSamples.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveBact==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popBactSamples,
                                                  PARA.nTime, nBact, nSamples, PARA.nComp);
                        POPULATION.setDimensions3(POPULATION.popBactStatistics,
                                                  PARA.nTime, nBact, PARA.nComp, nStat);
                        POPULATION.finalizeStatistics(POPULATION.popBactBase,
                                                      POPULATION.popBactSamples,
                                                      POPULATION.popBactStatistics,
                                                      nBact, PARA.nComp, PARA.nTime, 0, nStat);
                        POPULATION.popBactBase.clear();
                        POPULATION.popBactSamples.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveBactRes==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popBactResSamples,
                                                  PARA.nTime, PARA.activeDrugs, nSamples, PARA.nComp);
                        POPULATION.setDimensions3(POPULATION.popBactResStatistics,
                                                  PARA.nTime, PARA.activeDrugs, PARA.nComp, nStat);
                        POPULATION.finalizeStatistics(POPULATION.popBactResBase,
                                                      POPULATION.popBactResSamples,
                                                      POPULATION.popBactResStatistics,
                                                      PARA.activeDrugs, PARA.nComp,
                                                      PARA.nTime, 0, 1);
                        POPULATION.popBactResBase.clear();
                        POPULATION.popBactResSamples.clear();
                    }
                    //================================================
                    if ((PARA.isSolution==1)&&(PARA.isSaveMacro==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popMacroSamples,
                                                  PARA.nTime, nMacro, nSamples, 2);
                        POPULATION.setDimensions3(POPULATION.popMacroStatistics,
                                                  PARA.nTime, nMacro, 2, 1);
                        POPULATION.finalizeStatistics(POPULATION.popMacroBase,
                                                      POPULATION.popMacroSamples,
                                                      POPULATION.popMacroStatistics,
                                                      nMacro, 2, PARA.nTime, 0, 1);
                        POPULATION.popMacroBase.clear();
                        POPULATION.popMacroSamples.clear();
                    }
                    //================================================
                    if ((PARA.isDrugEffect==1)&&(PARA.isSaveEffect==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popMonitorSamples,
                                                  PARA.nTime, PARA.activeDrugs+2, nSamples, PARA.nComp);
                        POPULATION.setDimensions3(POPULATION.popMonitorStatistics,
                                                  PARA.nTime, PARA.activeDrugs+2, PARA.nComp, 1);
                        POPULATION.finalizeStatistics(POPULATION.popMonitorBase,
                                                      POPULATION.popMonitorSamples,
                                                      POPULATION.popMonitorStatistics,
                                                      PARA.activeDrugs+2, PARA.nComp,
                                                      PARA.nTime, 0, 1);
                        POPULATION.popMonitorBase.clear();
                        POPULATION.popMonitorSamples.clear();
                    }
                    //================================================
                    if ((PARA.isOutcome==1)&&(PARA.isSaveOutcome==1)) {
                        std::cout << ".";
                        POPULATION.setDimensions2(POPULATION.popOutcomeSamples,
                                                  PARA.nTime, nOutcome, nSamples, 1);
                        POPULATION.setDimensions3(POPULATION.popOutcomeStatistics,
                                                  PARA.nTime, nOutcome, 1, nStat);
                        POPULATION.finalizeStatistics(POPULATION.popOutcomeBase,
                                                      POPULATION.popOutcomeSamples,
                                                      POPULATION.popOutcomeStatistics,
                                                      nOutcome, 1, PARA.nTime, 0, nStat);
                        POPULATION.popOutcomeBase.clear();
                        POPULATION.popOutcomeSamples.clear();
                    }
                    std::cout << std::endl;
                    // end bootstrap statistics
                }

                TIMER.stop(id, 7);
                // write patient population simulation results to file
                if (PARA.isSavePopulationResults==1) {
                    TIMER.start(id, 8);
                    std::cout << "Writing results"<<std::endl;
                    writeResults(version, PARA,
                                 POPULATION.popAdherenceStatistics,
                                 POPULATION.popDoseStatistics,
                                 POPULATION.popConcStatistics,
                                 POPULATION.popConcKillStatistics,
                                 POPULATION.popConcGrowStatistics,
                                 POPULATION.popImmuneStatistics,
                                 POPULATION.popMacroStatistics,
                                 POPULATION.popBactStatistics,
                                 POPULATION.popBactResStatistics,
                                 POPULATION.popOutcomeStatistics,
                                 POPULATION.popMonitorStatistics);
                    TIMER.stop(id, 8);
                }
                if (!DRUGLIST.checkDrugStop(PARA)) {
                    // repeat warning message - if applicable
                    std::cout << "WARNING: therapy end point beyond simulation time" << std::endl;
                }

                // display simulation adherence statistics
                if ((PARA.isSaveAdhDose==1) && (PARA.isAdherence==1)) {
                    printLine();
                    POPULATION.printAdherenceStat(PARA.drugStart, PARA.drugStop);
                }

                //display simulation outcome statistics
                if ((PARA.isSaveOutcome==1) && (PARA.isOutcome==1)) {
                    printLine();
                    POPULATION.printOutcomeStat(PARA.drugStop, PARA.isBootstrap, PARA.nPopulations);
                }
                // display simulation time statistics
                if (showTime==1) {
                    printLine();
                    TIMER.printStatistics();
                }
            }

            // loop until user selects EXIT(9)
        } while ((inputValue!=9) && (PARA.batchMode==0));

        std::cout << "Program end" << std::endl;
        return 0;
    } else {
        std::cout << "Program stopped" << std::endl;
        //if (PARA.batchMode==0) std::system("pause");
        return 1;
    }
}
