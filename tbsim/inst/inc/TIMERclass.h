#ifndef TIMERCLASS_H
#define TIMERCLASS_H

#include <ctime>

#include "Global.h"

// vector for simulation run time information
// 0=Begin,   1=Startup, 2=Adh,   3=Dose, 4=PK, 5=PD/Immune,
// 6=Summary, 7=Write,   8=Other, 9=End

class TIMERclass {
public:
    void initialize(int);
    void start(int, int);
    void stop(int, int);
    void printStatistics();

private:
    time_t timer;
    struct tm y2k;
    double seconds;
    int getTime();

    int nThreads;
    const int nPoints = 10;
    VEC2I timeStart;   // current time counters
    VEC2I timeSum;     // sum time counters
};





#endif // TIMERCLASS_H

