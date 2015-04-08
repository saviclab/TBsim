#ifndef DRUGCLASS_H
#define DRUGCLASS_H

#include <string>
#include "Global.h"

class DRUGclass {
public:
    void initialize();
    bool readDrugParameters(int, const std::string&, const std::string&);
    void printDrugParameters();

    double IOfactor;
    double GRfactor;
    double rise50, fall50;
    double multiplier;
    double decayFactor;
    std::string name;
    int number;
    double KaMean, KaStdv;
    double KeMean, KeStdv;
    double V1Mean, V1Stdv;
    double KeMult, KeTime;
    double EC50k,  ak;
    double EC50g,  ag;
    double ECStdv;

    double highAcetFactor;
    double mutationRate;
    VEC kill_e, kill_i;
    int killIntra, killExtra;
    int growIntra, growExtra;
    double factorFast, factorSlow;

private:
    double S2N(std::string);
};

#endif // DRUGCLASS_H
