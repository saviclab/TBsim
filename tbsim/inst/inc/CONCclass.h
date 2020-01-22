#ifndef CONC_H
#define CONC_H

#include "Global.h"
#include "PARAMclass.h"
#include "DOSEclass.h"
#include "DRUGclass.h"
#include "DRUGLISTclass.h"

using namespace std;

class CONCclass{
public:
    void initialize(int, int, int, int, int);
    void setConc(PARAMclass&, DRUGLISTclass&, DOSEclass&);
    void setConcFactors(PARAMclass&, DRUGLISTclass&);

    VEC getKillIndex(int, int);
    VEC getGrowIndex(int, int);

    VEC3 concValue;
    VEC3 concGrow;
    VEC3 concKill;

private:
    int activeDrugs, nTime, nSteps, isGranuloma, nComp;
    void createConcFactors(int, int, VEC&, VEC&, VEC&, double,
                           double, double, double, double);
    void drugCompartmentTransfer(int, PARAMclass&, double, double, double, double, double, double);
    void drugDiffusion(PARAMclass&, VEC&, VEC&, double, double, double);
    double autoInduction(double, double, double, double);
};
#endif // CONC_H
