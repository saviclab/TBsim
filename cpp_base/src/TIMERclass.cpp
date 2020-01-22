#include <vector>
#include <iostream>
#include <cstdio>

#include "TIMERclass.h"

void TIMERclass::initialize(int nT){
    nThreads = nT;
    VECI tempI(nPoints, 0);
    timeSum.assign(nThreads, tempI);
    timeStart.assign(nThreads,tempI);
}

void TIMERclass::start(int thread, int point){
    timeStart[thread][point] = int(clock());
}

void TIMERclass::stop(int thread, int point){
    timeSum[thread][point] += int(clock()) - timeStart[thread][point];
}

void TIMERclass::printStatistics(){
    int totalTime(0);
    for (int iPoint=1; iPoint<nPoints; iPoint++){
        for (int iThread=0; iThread<nThreads; iThread++){
            timeSum[0][iPoint] += timeSum[iThread][iPoint];
        }
        timeSum[0][iPoint] /= nThreads; // normalize for number of threads used
        totalTime += timeSum[0][iPoint];
    }
    std::cout << "Run Timers" << std::endl;
    std::cout << "   Prep    Adh   Dose     PK     PD    Out   Stat   File  Total" << std::endl;
    for (int iPoint=1; iPoint<9; iPoint++){
        printf("  %5.1f", timeSum[0][iPoint]/(double) CLOCKS_PER_SEC);
    }
    printf("  %5.1f", totalTime/(double) CLOCKS_PER_SEC);
    std::cout << std::endl;
}
