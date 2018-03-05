#include <random>
#include <vector>
//#include <omp.h>
#include <algorithm>
#include <cstdio>
#include <string>
#include <iostream>

#include "POPULATIONclass.h"
#include "statFunctions.h"

namespace random3
{
    std::random_device rd;
    std::mt19937 engine(rd());
}

void POPULATIONclass::initialize(int nP, int nT, int nN, int nD, int nC,
                                 int nSamp, int nSi, int nStat, int nO, int nB,
                                 int nM, int nI, int nPop){
    nPatients = nP;
    nTime = nT;
    nSteps = nN;
    activeDrugs = nD;
    nComp = nC;
    nSamples = nSamp;       // number of samples taken
    nSize = nSi;            // sample size per sample
    nStatistics = nStat;    // number of stats
    nOutcome = nO;          // number of outcome states
    nBact = nB;             // total bact vs wild type bact
    nMacro = nM;
    nImmune = nI;
    nPopulations = nPop;

    // item=1, comp=1, time=nTime, stat=1, samples=nSamples   , start = 100
    setDimensions1(popAdherenceBase, nPatients, nTime, 1, 1);

    // item=activeDrugs, comp=1, time=nTime, stat=1, samples=nSamples, start = 100
    setDimensions1(popDoseBase, nPatients, nTime, activeDrugs, 1);

    // item=activeDrugs, comp=nComp, time=nSteps, stat=1, samples=nSamples, start = 100*24
    setDimensions1(popConcBase, nPatients, nSteps, activeDrugs, nComp);

    setDimensions1(popConcKillBase, nPatients, nSteps, activeDrugs, nComp);

    setDimensions1(popConcGrowBase, nPatients, nSteps, activeDrugs, nComp);

    // item=nBact, comp=nComp, time=nTime, stat=nStat, samples=nSamples, start = 0
    setDimensions1(popBactBase, nPatients, nTime, nBact, nComp);

    // item=activeDrugs, comp=nComp, time=nTime, stat=1, samples=nSamples, start = 0
    setDimensions1(popBactResBase, nPatients, nTime, activeDrugs, nComp);

    // item=nMacro, comp=2, time=nTime, stat=1, samples=nSamples, start = 0
    setDimensions1(popMacroBase, nPatients, nTime, nMacro, 2);

    // item=nImmune, comp=1, time=nTime, stat=1, samples=nSamples, start = 0
    setDimensions1(popImmuneBase, nPatients, nTime, nImmune, 1);

    // item=nOutcome, comp=1, time=nTime, stat=nStat, samples=nSamples, start = 0
    setDimensions1(popOutcomeBase, nPatients, nTime, nOutcome, 1);

    // item=activeDrugs+2, comp=nComp, time=nTime, stat=1, samples=nSamples, start = 0
    setDimensions1(popMonitorBase, nPatients, nTime, activeDrugs+2, nComp);
};

void POPULATIONclass::setDimensions1(VEC4& popBase, int nPatients, int nTime, int nItems, int nComp)
{
    VEC  tempP(nPatients, 0.0);
    VEC2 tempTP(nTime, tempP);
    VEC3 tempCTP(nComp, tempTP);
    popBase.assign(nItems, tempCTP);
}
void POPULATIONclass::setDimensions2(VEC4& popSamples,
                                     int nTime, int nItems, int nSamples, int nComp)
{
    VEC  tempS(nSamples, 0.0);
    VEC2 tempTS(nTime, tempS);
    VEC3 tempCTS(nComp, tempTS);
    popSamples.assign(nItems, tempCTS);
}

void POPULATIONclass::setDimensions3(VEC4& popStatistics,
                                     int nTime, int nItems, int nComp, int nStat)
{
    VEC  tempT(nTime, 0.0);
    VEC2 tempStT(nStat, tempT);
    VEC3 tempCStT(nComp, tempStT);
    popStatistics.assign(nItems, tempCStT);
}

void POPULATIONclass::setDimensions4(VEC5& popStatisticsPop,
                                     int nTime, int nItems, int nComp, int nStat, int nPopulations)
{
    VEC  tempP(nPopulations, 0.0);
    VEC2 tempTP(nTime, tempP);
    VEC3 tempStTP(nStat, tempTP);
    VEC4 tempCStTP(nComp, tempStTP);
    popStatisticsPop.assign(nItems, tempCStTP);
}

void POPULATIONclass::transfer(VEC4& popBase, VEC& value,
                               int iP, int nItems, int nComp, int nPeriods)
{
    for (int i=0; i<nItems; i++){
        for (int j=0; j<nComp; j++){
            for (int k=0; k<nPeriods; k++){
                popBase[i][j][k][iP] = value[k]; // no comp, no items
            }
        }
    }
}

void POPULATIONclass::transfer(VEC4& popBase, VEC2& value,
                               int iP, int nItems, int nComp, int nPeriods)
{
    for (int i=0; i<nItems; i++){
        for (int j=0; j<nComp; j++){
            for (int k=0; k<nPeriods; k++){
                popBase[i][j][k][iP] = value[i][k]; // no comp
            }
        }
    }
}

void POPULATIONclass::transfer(VEC4& popBase, VEC3& value,
                               int iP, int nItems, int nComp, int nPeriods)
{
    for (int i=0; i<nItems; i++){
        for (int j=0; j<nComp; j++){
            for (int k=0; k<nPeriods; k++){
                popBase[i][j][k][iP] = value[i][j][k];
            }
        }
    }
}

inline double POPULATIONclass::getOneSampleAvg(VEC& V)
{
    std::uniform_int_distribution<unsigned int> dis(0, nPatients-1);
    double sum(0.0);
    for (int iS=0;iS<nSize; iS++){
        // int iP = linDistInt(0, nPatients-1);
        // int iP = rand() % nPatients;
        // int iP = fastrand() % nPatients;

        int iP = dis(random3::engine);
        sum += V[iP];
    }
    return sum/nSize;
}

VEC2 POPULATIONclass::makeManySamples(VEC2& V2, int nPeriods, int nStart)
{
    VEC tempS(nSamples, 0.0);
    VEC2 temp(nPeriods, tempS);
#pragma omp parallel for
    for (int iT=nStart; iT<nPeriods; iT++){
        for (int iS=0;iS<nSamples; iS++){
            temp[iT][iS] = getOneSampleAvg(V2[iT]);
        }
    }
    return temp;
}

VEC2 POPULATIONclass::makeStatistics(VEC2& V, int nPeriods, int nStart, int nStat)
{
    VEC tempT(nPeriods, 0.0);
    VEC2 temp(nStat, tempT);
    int i025 = int(V[0].size() * 0.025);
    int i500 = int(V[0].size() * 0.500);
    int i975 = int(V[0].size() * 0.975);

    if (nStat==1){
#pragma omp parallel for
        for (int iT=nStart;iT<nPeriods; iT++){
            std::sort(V[iT].begin(), V[iT].end());
            temp[0][iT] = V[iT][i500];
        }
    }
    else {
#pragma omp parallel for
        for (int iT=nStart;iT<nPeriods; iT++){
            std::sort(V[iT].begin(), V[iT].end());
            temp[0][iT] = V[iT][i500];
            temp[1][iT] = V[iT][i025];
            temp[2][iT] = V[iT][i975];
        }
    }
    return temp;
}

double POPULATIONclass::makeSum(VEC& V)
{
    double init =0.0;
    double temp = std::accumulate(V.begin(), V.end(), init);

    return temp/nPatients;
}

// used for saving population iterations when NOT using bootstrap processing
void POPULATIONclass::savePopulation(VEC4& popBase,
                                     VEC5& popPops,
                                     int iPop, int nItems, int nComp, int nPeriods, int nStart, int nStat)
{
    VEC tempT(nPeriods, 0.0);
    VEC2 temp(nStat, tempT);

    for (int i=0; i<nItems; i++){
        for (int j=0; j<nComp; j++){
            // make statistics for current population, this assumes nPatients is 100 or more
            temp = makeStatistics(popBase[i][j], nPeriods, nStart, nStat);
            // save population stats into storage vector
            for (int k=0; k<nStat; k++){
#pragma omp parallel for
                for (int m=0; m<nPeriods; m++){
                    popPops[i][j][k][m][iPop] = temp[k][m];
                }
            }
        }
    }
}

// used for saving population iterations when NOT using bootstrap processing - for Outcome metric only
void POPULATIONclass::savePopulationOutcome(VEC4& popBase,
                                            VEC5& popPops,
                                            int iPop, int nItems, int nComp, int nPeriods, int nStart, int nStat)
{
    VEC tempT(nPeriods, 0.0);
    VEC2 temp(nStat, tempT);

    for (int i=0; i<nItems; i++){
        for (int j=0; j<nComp; j++){
            //for (int k=0; k<nStat; k++){
            int k=0;
#pragma omp parallel for
                for (int m=0; m<nPeriods; m++){
                    popPops[i][j][k][m][iPop] = makeSum(popBase[i][j][m]);
                }
            //}
        }
    }
}

// only applicable for bootstrap processing
void POPULATIONclass::finalizePopStat(VEC5& popPops, VEC4& popStatistics,
                                      int nItems, int nComp, int nPeriods, int nStart,
                                      int nStat, int nPopulations)
{
    // median index

    int i50 = int(nPopulations / 2) ;  // note integer division

    for (int i=0; i<nItems; i++) {
        for (int j=0; j<nComp; j++) {
            VEC saveAverage(nPeriods, 0.0); // temporary variable for average
            VEC saveMedian(nPeriods, 0.0);  // temporary variable for median
            VEC saveCIhigh(nPeriods, 0.0);  // temp
            VEC saveCIlow(nPeriods, 0.0);   // temp
            // calculate median
            for (int m=0; m<nPeriods; m++) {
                int k=0;
                // sort vector
                std::sort(popPops[i][j][k][m].begin(), popPops[i][j][k][m].end());
                // get median value
                saveMedian[m] = popPops[i][j][k][m][i50];
                // check if odd number of entries
                if (nPopulations % 2) {
                    saveMedian[m] = (popPops[i][j][k][m][i50] + popPops[i][j][k][m][i50+1])/2;
                }
            }
            // calculate average
            for (int m=0; m<nPeriods; m++) {
                double init = 0.0;
                int len = int(popPops[i][j][0][m].size());
                saveAverage[m] = 0.0;
                if (len>0) {
                    saveAverage[m] = std::accumulate(popPops[i][j][0][m].begin(),
                                                     popPops[i][j][0][m].end(), init) / double(len);
                }
            }
            // calculate standard deviation and confidence intervalls (2.5% and 97.5% limits)
            double sqdiff;
            for (int m=0; m<nPeriods; m++) {
                int k=0;
                // if nPopulations>1 then calculate standard deviation and set confidence limits
                if (nPopulations>1) {
                    sqdiff = 0.0;
                    for (int s=0; s<nPopulations; s++) {
                        sqdiff += (popPops[i][j][k][m][s] - saveAverage[m]) *
                                  (popPops[i][j][k][m][s] - saveAverage[m]);
                    }
                    // lower range
                    // note this assumes sufficient sample size (z parameter 1.96)
                    saveCIlow[m] = saveAverage[m] -
                                   1.96 * std::sqrt(sqdiff/(nPopulations-1.0)) /
                                   std::sqrt(nPopulations);
                    // make sure not less than 0
                    saveCIlow[m] = std::max(saveCIlow[m], 0.0);
                    // upper range
                    // note this assumes sufficient sample size (z parameter 1.96)
                    saveCIhigh[m] = saveAverage[m] +
                                    1.96 * std::sqrt(sqdiff/(nPopulations-1.0)) /
                                    std::sqrt(nPopulations);
                }
            }
            // assign values
            // if just nPopulations==1 then set confidence interval to zero, and outcome as AVERAGE
            if (nPopulations==1) {
                for (int m=0; m<nPeriods; m++) {
                    popStatistics[i][j][0][m] = saveAverage[m];
                    //popStatistics[i][j][1][m] = 0.0;
                    //popStatistics[i][j][2][m] = 0.0;
                }
            }
            // if nPopulations>1 then set confidence intervall values
            if (nPopulations>1) {
                for (int m=0; m<nPeriods; m++) {
                    popStatistics[i][j][0][m] = saveMedian[m];
                    popStatistics[i][j][1][m] = saveCIlow[m];
                    popStatistics[i][j][2][m] = saveCIhigh[m];
                }
            }
        }
    }
}

// for bootstrap processing
void POPULATIONclass::finalizeStatistics(VEC4& popBase,
                                         VEC4& popSamples,
                                         VEC4& popStatistics,
                                         int nItems, int nComp, int nPeriods, int nStart, int nStat)
{
    for (int i=0; i<nItems; i++){
        for (int j=0; j<nComp; j++){
            popSamples[i][j]    = makeManySamples(popBase[i][j], nPeriods, nStart);
            popStatistics[i][j] = makeStatistics(popSamples[i][j], nPeriods, nStart, nStat);
        }
    }
}

void POPULATIONclass::printAdherenceStat(int drugStart, int drugStop)
{
    std::cout << "Adherence" << std::endl;
    int t1 = std::max(drugStart, 0);
    int t2 = std::min(drugStop, nTime-1);

    printf("Overall: %4.2f",     vectorAvg(popAdherenceStatistics[0][0][0], t1, t2));
    printf(", Min daily: %4.2f", vectorMin(popAdherenceStatistics[0][0][0], t1, t2));
    printf(", Max daily: %4.2f", vectorMax(popAdherenceStatistics[0][0][0], t1, t2));
    std::cout << std::endl;
}

void POPULATIONclass::printOutcomeStat(int drugStop, int isBootstrap, int nPopulations)
{
    if ((isBootstrap==0)&&(nPopulations==1)){
        std::cout << "Population Therapy Outcome [average (5% - 95%)]" << std::endl;
    }
    else {
        std::cout << "Population Therapy Outcome [medium (5% - 95%)]" << std::endl;
    }
    std::cout << "             Last drug day       "
              << "   End of simulation" << std::endl;
    int t1 = std::min(drugStop, nTime-1);
    int t2 = nTime-1;
    std::vector<std::string> outText(nOutcome);
    outText[0] = "No TB     ";
    outText[1] = "Acute TB  ";
    outText[2] = "Latent TB ";
    outText[3] = "Cleared TB";

    for (int iO=0; iO<nOutcome; iO++){
        std::cout << outText[iO];
        printf(" : %5.3f (%5.3f - %5.3f) \t",       popOutcomeStatistics[iO][0][0][t1],
                                                    popOutcomeStatistics[iO][0][1][t1],
                                                    popOutcomeStatistics[iO][0][2][t1]);

        printf("%5.3f (%5.3f - %5.3f) \n",          popOutcomeStatistics[iO][0][0][t2],
                                                    popOutcomeStatistics[iO][0][1][t2],
                                                    popOutcomeStatistics[iO][0][2][t2]);
    }
}
