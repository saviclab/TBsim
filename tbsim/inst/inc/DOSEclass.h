#ifndef DRUGDOSE_H
#define DRUGDOSE_H

#include "Global.h"

class DOSEclass{
public:
    void initialize(int, int);
    void setDose(VEC&, VEC2&);

    VEC2 doseValue;     // patient-specific dosing
    VEC2 doseDays;      // cumulative dose days for each day

    VEC getDose(int);

private:
    int nTime;
    int activeDrugs;
    void setDoseDays();
};

#endif // DRUGDOSE_H
