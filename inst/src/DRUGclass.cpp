#include <cmath>
#include <fstream>
#include <iostream>
#include <sstream>
#include <vector>

#include "DRUGclass.h"

void DRUGclass::initialize(){
        name    = "";
        number  = 0;
        KaMean  = 0.0;
        KaStdv  = 0.0;
        KeMean  = 0.0;
        KeStdv  = 0.0;
        V1Mean  = 0.0;
        V1Stdv  = 0.0;
        KeMult  = 0.0;
        KeTime  = 0.0;
        EC50k   = 0.0;
        ak      = 0.0;
        EC50g   = 0.0;
        ag      = 0.0;
        ECStdv  = 0.0;
        IOfactor        = 0.0;
        GRfactor        = 0.0;
        highAcetFactor  = 0.0;
        mutationRate    = 0.0;
        kill_e.assign(4, 0.0); // 4 is the number of periods in kill profile
        kill_i.assign(4, 0.0);
        killIntra   = 0;
        killExtra   = 0;
        growIntra   = 0;
        growExtra   = 0;
        factorFast  = 1.0;
        factorSlow  = 1.0;
        rise50      = 0.0;
        fall50      = 0.0;
        multiplier  = 0.0;
        decayFactor = 0.0;
}

bool DRUGclass::readDrugParameters(int nn, const std::string& folder, const std::string& filename)
{
    bool fileStatus (true);
    std::string noText, tagText, valueText;
    const char delim1 = '<';
    const char delim2 = '>';
    const std::string fullname = folder + filename;
    std::ifstream myfile (fullname.c_str());

    if (myfile.is_open())
    {
        while (!myfile.eof())
        {
            std::getline (myfile, noText, delim1);
            std::getline (myfile, tagText, delim2);
            std::getline (myfile, valueText);
            if (tagText == "name")   {name = valueText;
                                      number = nn;}
            if (tagText == "KaMean") {KaMean = S2N(valueText);}
            if (tagText == "KaStdv") {KaStdv = S2N(valueText);}
            if (tagText == "KeMean") {KeMean = S2N(valueText);}
            if (tagText == "KeStdv") {KeStdv = S2N(valueText);}
            if (tagText == "V1Mean") {V1Mean = S2N(valueText);}
            if (tagText == "V1Stdv") {V1Stdv = S2N(valueText);}
            if (tagText == "KeMult") {KeMult = S2N(valueText);}
            if (tagText == "KeTime") {KeTime = S2N(valueText);}
            if (tagText == "highAcetFactor") {highAcetFactor = S2N(valueText);}
            if (tagText == "IOfactor")  {IOfactor = S2N(valueText);}
            if (tagText == "GRfactor")  {GRfactor = S2N(valueText);}
            if (tagText == "EC50k")     {EC50k = S2N(valueText);}
            if (tagText == "EC50g")     {EC50g = S2N(valueText);}
            if (tagText == "ak")        {ak = S2N(valueText);}
            if (tagText == "ag")        {ag = S2N(valueText);}
            if (tagText == "ECStdv")    {ECStdv = S2N(valueText);}
            if (tagText == "mutationRate") {mutationRate = S2N(valueText);}
            if (tagText == "kill_e0")   {kill_e[0] = S2N(valueText);}
            if (tagText == "kill_e1")   {kill_e[1] = S2N(valueText);}
            if (tagText == "kill_e2")   {kill_e[2] = S2N(valueText);}
            if (tagText == "kill_e3")   {kill_e[3] = S2N(valueText);}
            if (tagText == "kill_i0")   {kill_i[0] = S2N(valueText);}
            if (tagText == "kill_i1")   {kill_i[1] = S2N(valueText);}
            if (tagText == "kill_i2")   {kill_i[2] = S2N(valueText);}
            if (tagText == "kill_i3")   {kill_i[3] = S2N(valueText);}
            if (tagText == "killIntra") {killIntra = int(S2N(valueText));}
            if (tagText == "killExtra") {killExtra = int(S2N(valueText));}
            if (tagText == "growIntra") {growIntra = int(S2N(valueText));}
            if (tagText == "growExtra") {growExtra = int(S2N(valueText));}
            if (tagText == "factorFast") {factorFast = S2N(valueText);}
            if (tagText == "factorSlow") {factorSlow = S2N(valueText);}
            if (tagText == "rise50")    {rise50 = S2N(valueText);}
            if (tagText == "fall50")    {fall50 = S2N(valueText);}
            if (tagText == "multiplier") {multiplier = S2N(valueText);}
            if (tagText == "decayFactor") {decayFactor = S2N(valueText);}
        }
        myfile.close();
        std::cout << "Loaded drug file "<<filename<<std::endl;
        // create final rise and fall factors to use in simulation
        // these represent change factors needed to reach 50% change
        if (rise50>0.0){rise50 = std::log(2)/rise50;}
        if (fall50>0.0){fall50 = std::log(2)/fall50;}
        fileStatus=true;
    }
    else{
        std::cout << "Error: unable to load drug file "<<fullname<<std::endl;
        fileStatus=false;
    }
    return fileStatus;
}

void DRUGclass::printDrugParameters()
{
    std::cout << "name    : " << name <<std::endl;
    std::cout << "number  : " << number << std::endl;
    std::cout << "KaMean  : " << KaMean <<std::endl;
    std::cout << "KaStdv  : " << KaStdv <<std::endl;
    std::cout << "KeMean  : " << KeMean <<std::endl;
    std::cout << "KeStdv  : " << KeStdv <<std::endl;
    std::cout << "V1Mean  : " << V1Stdv <<std::endl;
    std::cout << "V1Stdv  : " << V1Stdv <<std::endl;
    std::cout << "KeMult  : " << KeMult <<std::endl;
    std::cout << "KeTime  : " << KeTime <<std::endl;
    std::cout << "highAcetFactor: " << highAcetFactor <<std::endl;
    std::cout << "IOfactor: " << IOfactor <<std::endl;
    std::cout << "EC50k   : " << EC50k <<std::endl;
    std::cout << "EC50g   : " << EC50g <<std::endl;
    std::cout << "ak      : " << ak <<std::endl;
    std::cout << "ag      : " << ag <<std::endl;
    std::cout << "ECStdv  : " << ECStdv <<std::endl;
    std::cout << "mutationRate: " << mutationRate <<std::endl;
    std::cout << "killIntra: " << killIntra <<std::endl;
    std::cout << "killExtra: " << killExtra <<std::endl;
    std::cout << "growIntra: " << growIntra <<std::endl;
    std::cout << "growExtra: " << growExtra <<std::endl;
    std::cout << "factorFast: " << factorFast <<std::endl;
    std::cout << "factorSlow: " << factorSlow <<std::endl;
}

double DRUGclass::S2N(std::string text)
{
    double N;
    if (!(std::istringstream(text) >> N)){
        N = 0.0;
    }
    return N;
}
