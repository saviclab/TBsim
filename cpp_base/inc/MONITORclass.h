#ifndef MONITORCLASS_H
#define MONITORCLASS_H

#include "Global.h"

class MONITORclass{
public:
    void initialize(int, int, int, int);
    void update(int, int, VEC&, double, VEC&);
    void aggregate(int, double);
    void finalize(double, VEC3&);
    void setMonitor(int, int, int, double);
    VEC3 monitorDaily;

private:
    int nTime;
    int nSteps;
    int nComp;
    int activeDrugs;

    // vector to track of kill contribution of each drug & immune system
    // index 0 to (n-1): effect from drugs 0 to n
    // index n: immune system, and index n+1: total effect
    VEC3 monitor;
};
#endif // MONITORCLASS_H
