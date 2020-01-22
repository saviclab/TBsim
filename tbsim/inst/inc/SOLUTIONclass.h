#ifndef SOLUTIONCLASS_H
#define SOLUTIONCLASS_H

#include "Global.h"
#include "PARAMclass.h"
#include "DRUGLISTclass.h"
#include "CONCclass.h"
#include "MONITORclass.h"
#include "DOSEclass.h"
#include "GRANclass.h"

class SOLUTIONclass
{
public:
    void initialize(int, int, int, int, int, int, int);
    void simulateInfection(PARAMclass&, int, VEC&, double, int, VEC&, VEC&,
                           DRUGLISTclass&, CONCclass&, DOSEclass&,
                           GRANclass&, MONITORclass&);

    // primary vectors for bacteria and macrophages during ODE solving
                // [type][compartment][time]
    VEC3 M;     // comp=0: I + II, 1= III+IV, type: 0=Ma, 1=Mr, 2=Mi
    VEC3 B;     // 0=wild type, 1=total bacteria
    VEC3 Br;    // resistant bacteria 0=r1, 1=r2, ...

    // immune system variables
    VEC2 immune;

private:
    int nTime;
    int nSteps;
    int activeDrugs;
    int nImmune;
    int isGranuloma;
    int nMacro;
    int nBact;
    int nComp;

    void copyXtoIM(int, VEC&, VEC&);
    int getKillPhase (double);
    void filterBactData(int, double, double, int, int&, double&,
                        double&, double&, VEC&, int);
    void bacterialKill(VEC, int, VEC&, VEC&, double, int, int,
                       double&, VEC&, VEC&, MONITORclass&, int, double, VEC&);
    void bacterialGrowth(VEC, double, VEC&, double&, VEC&);
    void calcMutate(double, double, VEC&, double&, VEC&);
    VEC calcGrowthStatus(double, double);
    double calcB_tot(int, VEC&, VEC&);
};

#endif // SOLUTIONCLASS_H
