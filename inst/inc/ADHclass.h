#ifndef ADHERENCE_H
#define ADHERENCE_H

#include "Global.h"
#include "PARAMclass.h"

class ADHclass{
public:
    void initialize(int);
    void setAdherence(PARAMclass&);
    VEC adherenceValue;

private:
    int nTime;
    int numberOfDaysMissed(VEC&);
    int tailDist(VEC&);
};

#endif // ADHERENCE_H
