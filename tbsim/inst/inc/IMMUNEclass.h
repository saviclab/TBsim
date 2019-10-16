#ifndef SETIMMUNEPARAMETERS_H
#define SETIMMUNEPARAMETERS_H

#include <vector>

#include "Global.h"
class IMMUNEclass{
public:
    int getnPar();
    void setInitialValues(int);
    void setImmuneStatus(int, double, double);
    bool readImmuneParameters(int, const std::string&, VECS&);
    VEC getp();
    double getCalcI(int);
private:
    int nPar = 78;
    VEC p;
    VEC calcI;
    double S2N(std::string);
};

#endif // SETIMMUNEPARAMETERS_H
