#include <vector>

#include "ADHclass.h"
#include "statFunctions.h"

//=================================================================
// Initialize adherence parameters and vector
//=================================================================
void ADHclass::initialize(int nT){
    nTime = nT;
    adherenceValue.assign(nTime, 0.0);
};

//=================================================================
// Generate daily adherence vector per patient
// Allows for 2 periods with different adherence pattern
// based on parameters adherenceType1, and adherenceType2
// applied when T>adherenceSwitchDay
//
//          - adherenceType=0 normal distributed adherence (w/ time step)
//          - adherenceType=1 non-adherent periods of variable days duration
//          - adherenceType=9 perfect adherence, i.e., 100%
//
// Note:    for adherenceType=1, non-adherence is defined by 2 params:
//          - patientAdhRatio    => distribution of non-adherence
//          - numberOfDaysMissed => days non-adherent per event
//=================================================================
void ADHclass::setAdherence(PARAMclass& PARA)
{
    const double minAdh = 0.0;          // min adherence level
    const double maxAdh = 1.0;          // max adherence level
    double patientAdhMean(0.0), dayAdhStdv(0.0);
    double patientAdhDist(0.0), patientAdhRatio (0.0);
    int adherenceType(0);

    // if adherenceType==0
    // base adherence per patient and variability per day
    patientAdhMean = normDist(PARA.adherenceMean, PARA.adherenceMean*PARA.adherenceStdv, minAdh, maxAdh);
    dayAdhStdv = PARA.adherenceStdv * PARA.adherenceStdvDay;

    // if adherenceType==1
    // average number of days between non-adherence event
    patientAdhDist = tailDist(PARA.adherenceDaysBetween[PARA.iAdherence]);
    patientAdhRatio = 1.0/patientAdhDist;

    // generate daily adherence vector
    int iT(0);
    do {
        double lval = linDist(minAdh, maxAdh);

        // apply active adherenceType
        adherenceType = PARA.adherenceType1;
        if (iT>PARA.adherenceSwitchDay){
            adherenceType = PARA.adherenceType2;
        }
        // basic probability-based adherence
        if (adherenceType==0) {
            double nval = normDist(patientAdhMean, dayAdhStdv, minAdh, maxAdh);
            if (lval < nval){
                adherenceValue[iT] = maxAdh;
            }
            else {
                adherenceValue[iT] = minAdh;
            }
            iT++;
        }
        // intermittent non-adherence
        if (adherenceType==1) {
            if (lval > patientAdhRatio){
                // pt is adherent
                adherenceValue[iT] = maxAdh;
                iT++;
            }
            else {
                // pt is not adherent
                // find out how many days to miss
                int i(0);
                int daysMissed = numberOfDaysMissed(PARA.adherenceDaysMissed[PARA.iAdherence]);
                do {
                    adherenceValue[iT] = minAdh;
                    iT++;
                    i++;
                } while ((iT<PARA.nTime) && (i<daysMissed));
            }
        }
        // perfect adherence (100%)
        if (adherenceType==9) {
            adherenceValue[iT] = maxAdh;
            iT++;
        }
    }
    while (iT<PARA.nTime);
}

//=================================================================
// Calculate number of days missed when non-adherent
// Allows up to N input limits, and produces
// output value from 1 to N, where
// V[i] must be [0..1] in strictly increasing order
//=================================================================
int ADHclass::numberOfDaysMissed(VEC& V){
    double r = linDist(0.0, 1.0);
    int i(0);

    while ((r<V[i]) && (i<V.size())){
        i++;
    }

    return i;
}

//=================================================================
// Generates parameterized probability function
// Based on N equal intervals from 0 to 1,
// generates output value based on V[0..N]
//=================================================================
int ADHclass::tailDist(VEC& V) {
    double r = linDist(0.0, 1.0);
    unsigned int i(0);

    i = int(r * double(V.size()));

    return V[i];
}
