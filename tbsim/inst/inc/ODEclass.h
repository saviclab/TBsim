#ifndef SETODEINITIALVALUES_H
#define SETODEINITIALVALUES_H

#include "Global.h"

class ODEclass {
public:
    int getnODE();
    VEC getxi();
    VEC getxBi();
    void setInitialValues();
    void createInfection(double, double, double, double);
    void createResistanceStart(int, double);
private:
    int nODE;
    VEC xi;
    VEC xBi;
};

#endif // SETODEINITIALVALUES_H
