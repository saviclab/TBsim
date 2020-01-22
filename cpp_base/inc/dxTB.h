#ifndef DXTB_H
#define DXTB_H

#include "Global.h"
#include "PARAMclass.h"

void dxTB(double, VEC&, VEC&, VEC&, double, PARAMclass&, Factors& f);

double calcIFN(VEC&, double, double, double, double, double);
double calcIL12L(VEC&, double, double, double);
double calcIL10(VEC&, double, double, double, double, double, double, double);
double calcIL4(VEC&, double, double, double);
double calcTp(VEC&, double, double, double, double, double, double, double, double);
double calcT1(VEC&, double, double, double, double, double, double);
double calcT2(VEC&, double, double, double, double);
double calcMa(VEC&, double, double, double, double, double, double);
double calcMi(VEC&, double, double, double, double, double);
double calcMr(VEC&, double, double, double, double, double, double, double, double);
double calcIL12LN(VEC&, double, double);
double calcTLN(VEC&, double, double);
double calcTpLN(VEC&, double, double, double);
double calcMDC(VEC&, double, double, double);
double calcIDC(VEC&, double, double);

void getMacrophageData(VEC&, double&, double&, double&, double&, double&, double&);
void getImmuneData(VEC&, double&, double&, double&, double&, double&, double&,
                   double&, double&, double&, double&, double&, double&);

double calcBaseBiGrowth(VEC&, double, double);
double calcBaseBeGrowth(VEC&, double);

double calcMacro(VEC&, double, double);
double calcBurst(VEC&, double, double);
double calcInfec(VEC&, double, double);
double calcBeKill(VEC&, double, double, double);

#endif // DXTB_H


