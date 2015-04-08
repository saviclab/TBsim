#include <vector>
#include <cmath>

#include "GRANclass.h"

void GRANclass::initialize(int nT)
{
    nTime = nT;

    formationValue = 0.0;
    breakupValue   = 0.0;

    formationValueVector.assign(nTime, 0.0);
    breakupValueVector.assign(nTime, 0.0);
}

// Granuloma formation assumed to be influenced by bacterial load in compartment I and II
// note: SOLUTION.copyXtoIM(iT, xs) must have been run first
// this implementation does not include granuloma break-up process
void GRANclass::calcGranuloma(int iT, int isGranuloma, double granulomaFormation,
                              double granulomaBreakup, double B10iT, double B11iT)
{
    // get bacterial totals per compartment
    double BTot12 = B10iT + B11iT;
    //double BTot34 = SOLUTION.B_III[1][iT]+ SOLUTION.B_IV[1][iT];

    // if isGranuloma == 0 then make the factor = 0
    if (isGranuloma==0) {
        formationValue = 0.0;
        breakupValue = 0.0;
    }
    // else derive value based on total bacterial load outside of granuloma
    else {
        // formation factor
        if (BTot12>1.0) {
            formationValue = granulomaFormation * std::log(BTot12);
        }
        // avoid error due to log(x) when x<1
        else {
            formationValue = 0.0;
        }
        // breakup factor
        breakupValue = granulomaBreakup;
        // assumes fixed breakup rate, resulting in proportional leakage of granuloma contents
        // note this is break up rate per hour, thus should be a relatively low value
    }
    // store current values in vector
    formationValueVector[iT] = formationValue;
    breakupValueVector[iT]   = breakupValue;
}

