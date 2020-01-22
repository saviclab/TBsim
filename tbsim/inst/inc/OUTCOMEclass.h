#ifndef OUTCOMECLASS_H
#define OUTCOMECLASS_H

#include "Global.h"

class OUTCOMEclass
{
public:
    void initialize(int, int);
    void setOutcome(int, double, double, VEC3&);

    VEC2 outcome;     // vector of outcome types

private:
    int nTime;
    int nOutcome;
};

#endif // OUTCOMECLASS_H
