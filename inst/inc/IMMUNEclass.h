#ifndef SETIMMUNEPARAMETERS_H
#define SETIMMUNEPARAMETERS_H

#include "Global.h"

class IMMUNEclass{
public:
    int getnPar();
    void setInitialValues(int);
    void setImmuneStatus(int, double, double);
    VEC getp();
    double getCalcI(int);
private:
    int nPar = 78;
    VEC p;
    VEC calcI;
};

#endif // SETIMMUNEPARAMETERS_H
