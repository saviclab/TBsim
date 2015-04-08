#include <iostream>
#include <cmath>

#include "DRUGLISTclass.h"
#include "printFunctions.h"

bool DRUGLISTclass::initialize(int nD, const std::string& configFolder, VECS& drugFile){
    bool fileStatus(true);
    nDrugs = nD;
    DRUGLIST.resize(nDrugs);
    for (int iD=0;iD<nDrugs; iD++) {
        DRUGLIST[iD].initialize();
        fileStatus = fileStatus && DRUGLIST[iD].readDrugParameters(iD, configFolder, drugFile[iD]);
    }
    return fileStatus;
}

DRUGclass DRUGLISTclass::get(int n){
    return DRUGLIST[n];
}

void DRUGLISTclass::printDrugList(int activeDrugs, VECI& drugTable, VECS& drugID)
{
    printLine();
    std::cout << "Active Drugs" << std::endl;
    std::cout << "Index" <<"\t"<<"Drug #"<<"\t"<<"x Macro"<<"\t"<<"x Gran"<<"\t"<<
            "EC50k"<<"\t"<<"ak"<<"\t"<<"Start"<<std::endl;
    if (activeDrugs>0){
        for (int i=0; i<activeDrugs; i++) {
            std::cout << i << "\t"
             << drugID[i] << "\t"
             << DRUGLIST[drugTable[i]].IOfactor << "\t"
             << DRUGLIST[drugTable[i]].GRfactor << "\t"
             << DRUGLIST[drugTable[i]].EC50k    << "\t"
             << DRUGLIST[drugTable[i]].ak       << "\t"
             << getDrugStart(i)
             << std::endl;
        }
    }
    printLine();
}

// check which drugs are included in current simulation
void DRUGLISTclass::selectActiveDrugs(PARAMclass& PARA)
{
    int i = PARA.iTherapy;  // index to simplify code
    PARA.drugActive.assign(PARA.nDrugs, 0);

    // iterate over all drugs 0..nDrugs
    for (int k=0;k<PARA.nDrugs; k++) {
        // iterate over all drugs in current Therapy
        for (int j=0; j<PARA.drugList[i].nRecords; j++){
            // if the specific drug is found - then set status = 1
            if (PARA.drugList[i].drugName[j]== get(k).name){
                PARA.drugActive[k] = 1;
            }
        }
    }
    // clear the drug list
    PARA.drugTable.clear();
    PARA.drugID.clear();

    // second pass through drug list to generate net list of active drugs
    // this will ensure a drug does not get listed twice
    PARA.activeDrugs = 0;      // counter of active drugs
    for (int k=0; k<PARA.nDrugs; k++){
        if (PARA.drugActive[k]==1){
            PARA.drugTable.push_back(k);           // drug number
            PARA.drugID.push_back(get(k).name);    // drug name
            PARA.activeDrugs++;                    // increment drug counter
        }
    }
    // update local variables
    nTime = PARA.nTime;
    activeDrugs = PARA.activeDrugs;
    //std::cout << "activeDrugs : " << activeDrugs << std::endl;
}

//=================================================================
// drug dose with full adherence
//=================================================================
VEC2 DRUGLISTclass::setDoseFullAdherence(PARAMclass& PARA)
{
    VEC tempT(nTime, 0.0);
    VEC2 temp(activeDrugs, tempT);

    for (int iD=0; iD<activeDrugs; iD++){
        // helper variable to keep code easier to read
        int i = PARA.iTherapy;

        int t1(0), t2(0), i1(0);
        double d1(0.0);

        // iterate through each of the dose records for active therapy
        for (int nn=0; nn<PARA.drugList[i].nRecords; nn++){
        // select therapy entries matching the drugID
            if (PARA.drugList[i].drugName[nn]==PARA.drugID[iD]) {
                // extract dose parameters for each record
                t1 = PARA.drugList[i].drugStart[nn];
                t2 = PARA.drugList[i].drugStop[nn];
                i1 = PARA.drugList[i].drugInt[nn];
                d1 = PARA.drugList[i].drugDose[nn];

                // update dose vector
                for (int iT=t1; iT<t2; iT += i1){
                    // add offset based on start of drug therapy
                    int t=iT+PARA.therapyStart;
                    t = std::min(t, PARA.nTime-1);
                    // uses ADD to DOSE for multiple records of same drug
                    temp[iD][t] += d1;
                }
            }
        }
    }
    doseFullAdherence = temp;
    return temp;
}
//=================================================================
// Find time of first drug administration (across ALL drugs)
//=================================================================
int DRUGLISTclass::getDrugStart(){
    int drugStart = nTime-1;
    for (int iD=0; iD<activeDrugs; iD++){
        for (int iT=0; iT<nTime; iT++){
            if (doseFullAdherence[iD][iT]>0.0) {
                drugStart = std::min(iT, drugStart);
            }
        }
    }
    if (activeDrugs==0){
        drugStart=0;
    }
    return drugStart;
}
//=================================================================
// Get start time of one specific drug
//=================================================================
int DRUGLISTclass::getDrugStart(int iD){
    int drugStart = nTime-1;
    for (int iT=0; iT<nTime; iT++){
        if (doseFullAdherence[iD][iT]>0.0) {
            drugStart = std::min(iT, drugStart);
        }
    }
    if (activeDrugs==0){
        drugStart=0;
    }
    //std::cout << "getDrugStart(i): "<<drugStart<<std::endl;
    return drugStart;
}
//=================================================================
// Find time of last drug administration
// Iterates over ALL drugs to find time of last dose
//=================================================================
int DRUGLISTclass::getDrugStop()
{
    int drugStop = 1;
    for (int iD=0; iD<activeDrugs; iD++){
        for (int iT=nTime-1; iT>0; iT--){
            if (doseFullAdherence[iD][iT]>0.0) {
                drugStop = std::max(iT, drugStop);
            }
        }
    }
    if (activeDrugs==0) {
        drugStop=1;
    }
    return drugStop;
}

bool DRUGLISTclass::checkDrugStop(PARAMclass& PARA)
{
    VEC tempT(nTime, 0.0);
    VEC2 temp(activeDrugs, tempT);

    int t1(0);

    for (int iD=0; iD<activeDrugs; iD++){
        // helper variable to keep code easier to read
        int i = PARA.iTherapy;
        // iterate through each of the dose records for active therapy
        for (int nn=0; nn<PARA.drugList[i].nRecords; nn++){
        // select therapy entries matching the drugID
            if (PARA.drugList[i].drugName[nn]==PARA.drugID[iD]) {
                // update max drugStop value
                t1 = std::max(t1, int(PARA.drugList[i].drugStop[nn]+PARA.therapyStart));
            }
        }
    }
    return (t1<(PARA.nTime+1));
}
