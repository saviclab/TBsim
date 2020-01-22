#ifndef PARAMCLASS_H
#define PARAMCLASS_H

#include <string>
#include <vector>

#include "Global.h"

struct Therapy
{
    std::string name;
    std::string description;
    int nRecords;
    VECS drugName;
    VEC drugDose;
    VECI drugStart;
    VECI drugStop;
    VECI drugInt;

  Therapy():
    name(),
    description(),
    nRecords(),
    drugName (VECS()),
    drugDose (VEC()),
    drugStart(VECI()),
    drugStop (VECI()),
    drugInt  (VECI())
  {}
};

class PARAMclass
{
 public:
    void initialize();
    bool readInit(const std::string&, const std::string&);
    bool readTherapy(const std::string&);
    bool readAdherence(const std::string&);
    bool readMEMSAdherence(const std::string&);
    void updateParameter(int);
    void printParameters();

    unsigned short int batchMode;               // if==1, then run program with no user input
    unsigned short int nTime;
    unsigned short int nPatients;
    unsigned short int nPopulations;
    unsigned short int therapyStart;
    unsigned short int nSteps;
    unsigned short int nComp;                   // number of simulation compartments
    unsigned short int nODE;
    unsigned short int nThreads;                 // max number of processing threads to use
    unsigned short int disease;
    unsigned short int kMax;
    unsigned short int drugStart;               // calculated first day of drug therapy
    unsigned short int drugStop;                // calculated last day of drug therapy

    unsigned short int isSavePatientResults;    // if write patient-level results to file
    unsigned short int isSavePopulationResults; // if write population results to file
    unsigned short int isSaveAdhDose;           // if write adh & dose data to file
    unsigned short int isSaveConc;              // if write conc data to file
    unsigned short int isSaveConcKill;          // if write conc kill & grow data to file
    unsigned short int isSaveImmune;            // if write immune system data to file
    unsigned short int isSaveMacro;             // if write macro data to file
    unsigned short int isSaveBact;              // if write bact totals data to file
    unsigned short int isSaveBactRes;           // if write bact res data to file
    unsigned short int isSaveOutcome;           // if write outcome data to file
    unsigned short int isSaveEffect;            // if write drug effect data to file
    unsigned short int isBootstrap;             // if to run bootstrap routine

    unsigned short int isAdherence;             // if adherence vectors
    unsigned short int isDrugDose;              // if drug dose vectors
    unsigned short int isConcentration;         // if concentration vectors (PK)
    unsigned short int isSolution;              // if solver outputs for PD
    unsigned short int isOutcome;               // if outcome calc
    unsigned short int isDrugEffect;            // if drug effects vectors

    unsigned short int isResistance;            // if bacterial resistance
    unsigned short int isGranuloma;             // if granuloma creation
    unsigned short int isGranulomaInfec;        // if macrophage infection inside granuloma
    unsigned short int isImmuneKill;            // if immune system killing on bacteria
    unsigned short int isPersistance;           // if drug persistance mechanism
    unsigned short int isClearResist;           // if clear resistant bacteria when below threshold
    unsigned short int isGranImmuneKill;        // if immune killing inside granulome
    unsigned short int isGradualDiffusion;      // if dynamic drug diffusion in/out of granuloma lesions
    unsigned short int persistTime;             // time period for calculating persistence status
    std::string dataFolder;                     // location for data files generated

    unsigned short int nDrugs;          // number of drug files to load
    VECS drugFile;                      // name of individual drug file

    unsigned short int nTherapy;        // number of drug therapies to load
    unsigned short int defaultTherapy;  // default therapy
    unsigned short int iTherapy;        // current selected therapy
    VECS therapyFile;                   //name of individual therapy file
    std::vector<Therapy> drugList;      // description and list of drug records for each therapy

    unsigned short int nAdherence;      // number of adherence schedules to load
    unsigned short int defaultAdherence;// default adherence
    unsigned short int iAdherence;      // current selected adherence
    VECS adherenceFile;                 //name of individual therapy file

    unsigned short int nImmune;         // number of immunity initializations to load 
    VECS immuneFile;                    // name of individual immune file with initializations

    double initialValueStdv;            // variation applied to starting values
    double parameterStdv;               // variation applied to ODE parameters per patient
    double timeStepStdv;                // variation applied tp ODE parameters per day
    int adherenceType1;                 // 0=simple % based, 1=days inbetween missed doses method
    int adherenceType2;                 // 0=simple % based, 1=days inbetween missed doses method
    int adherenceMEMS;                 // MEMS adherence
    std::vector<std::vector<double> > adherenceMEMSvec; // MEMS vector of vectors
    int adherenceSwitchDay;             // day of therapy when switch from Type 1 to Type 2 adherence
    double adherenceMean;               // mean adherence level per patient
    double adherenceStdv;               // standard dev for patients adherence
    double adherenceStdvDay;            // standard dev for daily adherence as ratio of pt adherence
    VEC2 adherenceDaysBetween;          // days between missed dose, per each 10%-ile of patients
    VEC2 adherenceDaysMissed;           // probability of missing N days, for N=1..10 (cum percent)
    VECS adherenceName;                 // description of custom adherence pattern

    double shareLowAcetylators;         // portion of population that are slow acetylators
    double immuneMean;                  // average immune performance per patient
    double immuneStdv;                  // standard dev for immune performance per patient
    double infI;                        // starting infection in compartment I
    double infII;                       // starting infection in compartment II
    double infIII;                      // starting infection in compartment III
    double infIV;                       // starting infection in compartment IV
    double resistanceRatio;             // ratio of naturally occuring resistant strains
    double resistanceFitness;           // relative fitness for drug resistant bacteria strains [0..1]
    double granulomaKill;               // reduced kill effect in granuloma
    double granulomaGrowth;             // reduced bacterial growth rate in granuloma
    double granulomaGrowthInh;          // reduced growth inhibition by DRUGS in granuloma (defined as 1/factor)
    double granulomaFormation;          // constant affecting granuloma formation rate
    double granulomaInfectionRate;      // factor defining rate of macrophage infection inside granuloma [0..1]
    double granulomaBreakup;            // constant affecting granuloma breakup rate
    double bactThreshold;               // limit used to filter out bact data in Bi/Be curves
    double bactThresholdRes;            // limit used to filter out bact data in Bi/Be curves - for resistant bact
    double growthLimit;                 // limit for considered non-persisting, i.e., growing bacteria

    double freeBactLevel;               // max bacteria level outside granuloma to be considered cleared TB
    double latentBactLevel;             // max bacteria threshold outside of granuloma to consider Latent TB
    int nIterations;                    // number of outcome iterations

    VECI drugActive;                    // flag set = 1 if drug is included in simulation
    VECS drugID;                        // ID for active drugs
    VECI drugTable;                     // resulting list of drug INDEXES included in simulation
    int activeDrugs;                    // count of active drugs in current simulation instance

    int seed;                           // Simulation seed

 private:
    VEC readArray(std::string&);
    double S2N(std::string);
};

#endif // PARAMCLASS_H
