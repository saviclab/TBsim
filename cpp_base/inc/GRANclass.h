#ifndef GRANCLASS_H
#define GRANCLASS_H

#include "Global.h"

// data structure to hold granuloma status, formation and breakup
class GRANclass {
public:
    void initialize(int);

    double formationValue;
    double breakupValue;

    VEC formationValueVector;
    VEC breakupValueVector;

    void calcGranuloma(int, int, double, double, double, double);

private:
    int nTime;
};

#endif // GRANCLASS_H
