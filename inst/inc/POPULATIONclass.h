#ifndef POPULATION_H
#define POPULATION_H

#include "Global.h"

class POPULATIONclass{
public:
    void initialize(int, int, int, int, int, int, int, int, int, int, int, int, int);
    void setDimensions1(VEC4&, int, int, int, int);
    void setDimensions2(VEC4&, int, int, int, int);
    void setDimensions3(VEC4&, int, int, int, int);
    void setDimensions4(VEC5&, int, int, int, int, int);
    void printAdherenceStat(int, int);
    void printOutcomeStat(int, int, int);

    void transfer(VEC4&, VEC&,  int, int, int, int);
    void transfer(VEC4&, VEC2&, int, int, int, int);
    void transfer(VEC4&, VEC3&, int, int, int, int);

    void savePopulation(VEC4&, VEC5&, int, int, int, int, int, int);
    void savePopulationOutcome(VEC4&, VEC5&, int, int, int, int, int, int);
    void finalizeStatistics(VEC4&, VEC4&, VEC4&, int, int, int, int, int);
    void finalizePopStat(VEC5&, VEC4&, int, int, int, int, int, int);

    VEC4 popAdherenceBase;
    VEC4 popAdherenceSamples;
    VEC4 popAdherenceStatistics;
    VEC5 popAdherencePops;

    VEC4 popDoseBase;
    VEC4 popDoseSamples;
    VEC4 popDoseStatistics;
    VEC5 popDosePops;

    VEC4 popConcBase;
    VEC4 popConcSamples;
    VEC4 popConcStatistics;
    VEC5 popConcPops;

    VEC4 popConcKillBase;
    VEC4 popConcKillSamples;
    VEC4 popConcKillStatistics;
    VEC5 popConcKillPops;

    VEC4 popConcGrowBase;
    VEC4 popConcGrowSamples;
    VEC4 popConcGrowStatistics;
    VEC5 popConcGrowPops;

    VEC4 popImmuneBase;
    VEC4 popImmuneSamples;
    VEC4 popImmuneStatistics;
    VEC5 popImmunePops;

    VEC4 popBactBase;
    VEC4 popBactSamples;
    VEC4 popBactStatistics;
    VEC5 popBactPops;

    VEC4 popBactResBase;
    VEC4 popBactResSamples;
    VEC4 popBactResStatistics;
    VEC5 popBactResPops;

    VEC4 popMacroBase;
    VEC4 popMacroSamples;
    VEC4 popMacroStatistics;
    VEC5 popMacroPops;

    VEC4 popMonitorBase;
    VEC4 popMonitorSamples;
    VEC4 popMonitorStatistics;
    VEC5 popMonitorPops;

    VEC4 popOutcomeBase;
    VEC4 popOutcomeSamples;
    VEC4 popOutcomeStatistics;
    VEC5 popOutcomePops;

private:

    int nPatients;
    int nPopulations;
    int nTime;
    int nComp;
    int nSteps;
    int activeDrugs;
    int nSamples;           // number of samples taken
    int nSize;              // sample size per sample
    int nStatistics;        // number of stats
    int nOutcome;           // number of outcome states
    int nBact;              // bact totals and wild type
    int nMacro;
    int nImmune;

    double getOneSampleAvg(VEC&);
    double makeSum(VEC&);
    VEC2 makeStatistics(VEC2&, int, int, int);
    VEC2 makeManySamples(VEC2&, int, int);
};

#endif // POPULATION_H
