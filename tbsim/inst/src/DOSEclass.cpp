#include <vector>

#include "DOSEclass.h"
#include "Global.h"
#include "statFunctions.h"

//=================================================================
// Initialize DOSE object
//=================================================================
void DOSEclass::initialize(int nD, int nT){
    activeDrugs = nD;
    nTime = nT;

    VEC temp(nTime, 0.0);
    doseValue.assign(activeDrugs, temp);     // patient-specific dosing
    doseDays.assign(activeDrugs, temp);      // cumulative dose days for each day

    temp.clear();
}

//=================================================================
// Apply dose for each specific drug for each day
//=================================================================
void DOSEclass::setDose(VEC& temp, VEC2& doseFull)
{
    for (int iD=0; iD<activeDrugs; iD++){
        multTwoVectors(doseFull[iD], temp, doseValue[iD]);
    }
    // count cumulative days per drug at each point in time
    setDoseDays();
}

//=================================================================
// Calculate number of days of dosing preceeding each day
//=================================================================
void DOSEclass::setDoseDays()
{
    for (int iD=0; iD<activeDrugs; iD++){
        unsigned int iT(0);
        int days(0);   // counter of days on drug

        do{
            // check no of consecutive days
            if (doseValue[iD][iT]>0){
                days++;
            }
            else {
                days = 0;
            }
            doseDays[iD][iT] = days;
            iT++;
        } while (iT<doseValue[iD].size());
    }
}
