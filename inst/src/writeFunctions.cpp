#include <sstream>
#include <fstream>
#include <ios>
#include <iostream>

#include "writeFunctions.h"
#include "printFunctions.h"

namespace patch {
    template < typename T > std::string to_string( const T& n )
    {
        std::ostringstream stm ;
        stm << n ;
        return stm.str() ;
    }
}

//=================================================================
// Write simulation results to text file
// for later visualization using R
//=================================================================
void writeResults(const string& version, PARAMclass& PARA,
                  VEC4& adherenceStat,  VEC4& doseStat,     VEC4& concStat,
                  VEC4& concKillStat,   VEC4& concGrowStat, VEC4& immuneStat,
                  VEC4& macroStat,      VEC4& bactStat,     VEC4& bactResStat,
                  VEC4& outcomeStat,    VEC4& monitorStat)
{
    // output file naming
    string filetype         = ".txt";        // suffix for output files
    string fileHeader       = "header";
    string fileAdh          = "adherence";
    string fileDose         = "calcDose";
    string fileConc         = "calcConc";
    string fileKill         = "calcKill";
    string fileGrow         = "calcGrow";
    string fileImmune       = "immune";
    string fileOutcome      = "outcome";
    string fileGranuloma    = "granuloma";
    string fileBactTotals   = "bactTotals";
    string fileBactRes      = "bactRes";
    string fileMacro        = "macro";
    string fileEffect       = "effect";

    int iIteration = 0;

    string tag = "";
    const int nImmune(12);    // number of immune cell types
    std::vector<std::string> immuneText(nImmune);
    immuneText[0]   = "Tp";
    immuneText[1]   = "T1";
    immuneText[2]   = "T2";
    immuneText[3]   = "MDC";
    immuneText[4]   = "IDC";
    immuneText[5]   = "TLN";
    immuneText[6]   = "TpLN";
    immuneText[7]   = "IL10";
    immuneText[8]   = "IL4";
    immuneText[9]   = "IFN";
    immuneText[10]  = "IL12L";
    immuneText[11]  = "IL12LN";

    const int nEffect(PARA.activeDrugs+2);

    const int nAdh(1);
    std::vector<std::string> adhText(nAdh);
    adhText[0] = "all";

    const int nBact(2);
    std::vector<std::string> bactText(nBact);
    bactText[0] = "wild";
    bactText[1] = "total";

    const int nMacro(3);
    std::vector<std::string> macroText(nMacro);
    macroText[0] = "Ma";
    macroText[1] = "Mr";
    macroText[2] = "Mi";

    const int nStat(3);   // number of statistics metrics
    std::vector<std::string> statText(nStat);
    statText[0] = "median";
    statText[1] = "p05";
    statText[2] = "p95";

    const int nOutcome(4);
    std::vector<std::string> outcomeText(nOutcome);
    outcomeText[0] = "NoTB";
    outcomeText[1] = "AcuteTB";
    outcomeText[2] = "LatentTB";
    outcomeText[3] = "ClearedTB";

    VECS drugText(PARA.activeDrugs);
    for (int iD=0; iD<PARA.activeDrugs; iD++){
        drugText[iD] = patch::to_string(iD);
    }

    VECS effectText(PARA.activeDrugs+2);
    for (int iD=0; iD<PARA.activeDrugs; iD++){
        effectText[iD] = patch::to_string(iD);
    }
    effectText[PARA.activeDrugs]   = patch::to_string(PARA.activeDrugs);
    effectText[PARA.activeDrugs+1] = patch::to_string(-1);

    // used for daily data
    int startDay = 0;
    int nDays = PARA.nTime;

    // used for hourly data
    int startHour = PARA.drugStart * 24;
    int nHours  = 720;     // 30*24;

    std::string fileName;

    fileName = fileHeader + filetype;
    writeHeader (PARA.dataFolder, fileName, PARA, version);

    // ============================================================
    // adherence
    if ((PARA.isSaveAdhDose==1)&&(PARA.isAdherence==1)){
        fileName = fileAdh + filetype;
        writeVector(adherenceStat, PARA.dataFolder, fileName,
                    fileAdh, adhText, statText, 1, 1, 1, 0,
                    PARA.nTime, PARA.nTime);
    }
    // ============================================================
    //drug dose
    if ((PARA.isSaveAdhDose==1)&&(PARA.isDrugDose==1)) {
        fileName = fileDose + filetype;
        writeVector(doseStat, PARA.dataFolder, fileName,
                    fileDose, drugText, statText, PARA.activeDrugs, 1, 1, 0,
                    PARA.nTime, PARA.nTime);
    }
    // ============================================================
    // concentration profiles
    if ((PARA.isSaveConc==1)&&(PARA.isConcentration==1)) {
        fileName = fileConc + filetype;
        writeVector(concStat, PARA.dataFolder, fileName,
                    fileConc, drugText, statText, PARA.activeDrugs, PARA.nComp, 1, -1,
                    nHours, PARA.nTime);
    }
    // ============================================================
    // concentration kill profiles
    if ((PARA.isSaveConcKill==1)&&(PARA.isConcentration==1)) {
        fileName = fileKill + filetype;
        writeVector(concKillStat, PARA.dataFolder, fileName,
                    fileKill, drugText, statText, PARA.activeDrugs, PARA.nComp, 1, -1,
                    nHours, PARA.nTime);
    }
    // ============================================================
    // concentration grow profiles
    if ((PARA.isSaveConcKill==1)&&(PARA.isConcentration==1)) {
        fileName = fileGrow + filetype;
        writeVector(concGrowStat, PARA.dataFolder, fileName,
                    fileGrow, drugText, statText, PARA.activeDrugs, PARA.nComp, 1, -1,
                    nHours, PARA.nTime);
    }
    // ============================================================
    // macro data
    if ((PARA.isSaveMacro==1)&&(PARA.isSolution==1)) {
        fileName = fileMacro + filetype;
        writeVector(macroStat, PARA.dataFolder, fileName,
                    fileMacro, macroText, statText, nMacro, 2, 1, 0,
                    PARA.nTime, PARA.nTime);
    }
    // ============================================================
    // immune data
    if ((PARA.isSaveImmune==1)&&(PARA.isSolution==1)) {
        fileName = fileImmune + filetype;
        writeVector(immuneStat, PARA.dataFolder, fileName,
                    fileImmune, immuneText, statText, nImmune, 1, 1, 0,
                    PARA.nTime, PARA.nTime);
    }
    // ============================================================
    // bact totals data
    if ((PARA.isSaveBact==1)&&(PARA.isSolution==1)) {
        fileName = fileBactTotals + filetype;
        writeVector(bactStat, PARA.dataFolder, fileName,
                    fileBactTotals, bactText , statText, nBact, PARA.nComp, nStat, 0,
                    PARA.nTime, PARA.nTime);
    }
    // ============================================================
    // bact res data
    if ((PARA.isSaveBactRes==1)&&(PARA.isSolution==1)) {
        fileName = fileBactRes + filetype;
        writeVector(bactResStat, PARA.dataFolder, fileName,
                    fileBactRes, drugText, statText, PARA.activeDrugs, PARA.nComp, 1, 0,
                    PARA.nTime, PARA.nTime);
    }
    // ============================================================
    // bacterial and immune effect
    if ((PARA.isSaveEffect==1)&&(PARA.isDrugEffect==1)) {
        fileName = fileEffect + filetype;
        writeVector(monitorStat, PARA.dataFolder, fileName,
                    fileEffect, effectText, statText, PARA.activeDrugs+2, PARA.nComp, 1, 0,
                    PARA.nTime, PARA.nTime);
    }
    // ============================================================
    // outcome data
    if ((PARA.isSaveOutcome==1)&&(PARA.isOutcome==1)) {
        fileName = fileOutcome + filetype;
        writeVector(outcomeStat, PARA.dataFolder, fileName,
                    fileOutcome, outcomeText, statText, nOutcome, 1, nStat, 0,
                    PARA.nTime, PARA.nTime);
    }
}

void writeVector(VEC4& dataVector, std::string& folderName, std::string& fileName, std::string& fileText,
                 std::vector<std::string>& typeText, std::vector<std::string>& statText,
                 int nItems, int nComp, int nStat, int startTime, int nPeriods, int nTime)
{
    std::string tag =  "<fileType>" + fileText;
    writeDataFileHeader(folderName, fileName, tag);
    int startPeriod;

    for (int iI=0; iI<nItems; iI++) {
        if (startTime==-1){
            startPeriod = getConcStart(nTime, dataVector[iI][0][0]); // get startHour
        }
        else {
            startPeriod = startTime;    // is startDay
        }
        for (int iC=0; iC<nComp; iC++) {
            for (int iS=0; iS<nStat; iS++){
                tag  = "<type>"        + typeText[iI] + "\n";
                tag += "<startTime>"   + patch::to_string(startPeriod) + "\n";
                tag += "<compartment>" + patch::to_string(iC) + "\n";
                tag += "<stat>"        + statText[iS];
                writeFileIncData(folderName, fileName, tag,
                                 dataVector[iI][iC][iS], startPeriod, nPeriods);
            }
        }
    }
}

void writeFile (const std::string& dataFolder, VEC& x, int nStart, int nTime,
                const std::string& filename, const std::string& version)
{

    std::ofstream myfile;
    const std::string fullname = dataFolder + filename;

    myfile.open (fullname.c_str());

    if(myfile.good())
        myfile << version << std::endl;

    for (int iT=nStart; iT<(nStart+nTime); iT++) {
        if(myfile.good()) {
            myfile << x[iT] << "\t";
        }
    }
    if (myfile.good()) {
        myfile << std::endl;
    }
    myfile.close();
}

void writeDataFileHeader(const std::string& dataFolder,
                         const std::string& fileName, const std::string& tag)
{
    std::ofstream myfile;
    const std::string fullname = dataFolder + fileName;

    // clear file and write file header
    myfile.open (fullname.c_str(), ios::out | ios::trunc);

    if(myfile.good()) {
        myfile << tag << std::endl;
    }

    // close file for now
    myfile.close();
}

void writeFileIncData (const std::string& dataFolder, const std::string& fileName, const std::string& tag,
                       VEC x, int nStart, int nPeriods)
{
    // this function assumes the target file exists and has been accessed

    std::ofstream myfile;
    const std::string fullname = dataFolder + fileName;

    // open file to append data
    myfile.open (fullname.c_str(), ios::out | ios::app);

    // write tag
    if(myfile.good()) {
        myfile << tag << std::endl;
        myfile << "<data>";
    }

    // write data
    for (int iT=nStart; iT<(nStart+nPeriods); iT++) {
        if(myfile.good()) {
            myfile << x[iT] << "\t";
        }
    }

    // write EOL
    if (myfile.good()) {
        myfile << std::endl;
    }

    // close file for now
    myfile.close();
}

void writeFileIncV (int iF, const std::string& dataFolder, VEC x, int nStart, int nPeriods,
                    const std::string& filename, const std::string& version)
{

    std::ofstream myfile;
    const std::string fullname = dataFolder + filename;

    if (iF == 0) {    // clear file and write header file
        myfile.open (fullname.c_str(), ios::out | ios::trunc);
        myfile << version << std::endl;
    } else {         // append data to file
        myfile.open (fullname.c_str(), ios::out | ios::app);
    }

    for (int iT=nStart; iT<(nStart+nPeriods); iT++) {
        if(myfile.good()) {
            myfile << x[iT] << "\t";
        }
    }
    if (myfile.good()) {
        myfile << std::endl;
    }

    myfile.close();
}

void writeHeader (const std::string& dataFolder, const std::string& filename, PARAMclass& PARA,
                  const std::string& version)
{
    std::ofstream myfile;
    const std::string fullname = dataFolder + filename;
    myfile.open (fullname.c_str());

    if (myfile.is_open()) {
        myfile << version << std::endl;                  // version number
        myfile << PARA.nTime << std::endl;               // number of time steps
        myfile << PARA.nSteps << std::endl;              // number of concentration data points
        myfile << PARA.drugStart << std::endl;           // time for drug admin started
        myfile << PARA.nPatients << std::endl;           // number population size

        myfile << PARA.isResistance << std::endl;
        myfile << PARA.isImmuneKill << std::endl;
        myfile << PARA.isGranuloma  << std::endl;
        myfile << PARA.isPersistance << std::endl;

        myfile << printModel(PARA.disease) << std::endl;

        myfile << PARA.activeDrugs << std::endl;

        myfile << PARA.drugList[PARA.iTherapy].description << std::endl;

        myfile << PARA.nIterations << std::endl;

        for (int i=0; i<PARA.activeDrugs; i++) {
            myfile << PARA.drugID[i] << std::endl;
        }

        myfile.close();
    } else {
        std::cout << "unable to open file"<<std::endl;
    }
}

void writeDetails(int iP, PARAMclass& PARA, SOLUTIONclass& SOLUTION,
                  CONCclass& CONC, ADHclass& ADH, const std::string& version)
{
    std::string fileName;
    std::string filetype = ".txt";

    writeFileIncV(iP, PARA.dataFolder, ADH.adherenceValue, 0, PARA.nTime,
                  "adh_d.txt", version);

    // compartment I
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[1][0], 0,
                   PARA.nTime, "B_I_t.txt", version);
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[0][0], 0,
                   PARA.nTime, "B_I_w.txt", version);
    for (int iD=0; iD<PARA.activeDrugs; iD++) {
        fileName ="B_I_" + patch::to_string(iD) + filetype;
        writeFileIncV (iP, PARA.dataFolder, SOLUTION.Br[iD][0], 0,
                       PARA.nTime, fileName, version);
    }

    //compartment II
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[1][1], 0,
                   PARA.nTime, "B_II_t.txt", version);
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[0][1], 0,
                   PARA.nTime, "B_II_w.txt", version);
    for (int iD=0; iD<PARA.activeDrugs; iD++) {
        fileName ="B_II_" + patch::to_string(iD) + filetype;
        writeFileIncV (iP, PARA.dataFolder, SOLUTION.Br[iD][1], 0,
                       PARA.nTime, fileName, version);
    }

    //compartment III
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[1][2], 0,
                   PARA.nTime, "B_III_t.txt", version);
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[0][2], 0,
                   PARA.nTime, "B_III_w.txt", version);
    for (int iD=0; iD<PARA.activeDrugs; iD++) {
        fileName ="B_III_" + patch::to_string(iD) + filetype;
        writeFileIncV (iP, PARA.dataFolder, SOLUTION.Br[iD][2], 0,
                       PARA.nTime, fileName, version);
    }

    //compartment IV
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[1][3], 0, PARA.nTime,
                   "B_IV_t.txt", version);
    writeFileIncV (iP, PARA.dataFolder, SOLUTION.B[0][3], 0, PARA.nTime,
                   "B_IV_w.txt", version);
    for (int iD=0; iD<PARA.activeDrugs; iD++) {
        fileName ="B_IV_" + patch::to_string(iD) + filetype;
        writeFileIncV (iP, PARA.dataFolder, SOLUTION.Br[iD][3], 0,
                       PARA.nTime, fileName, version);
    }
}

int getConcStart(int nTime, VEC& v){
// find time index when first concentration of each drug
// only checks in compartment I
// if no concentration value found then returns 0;

    bool found = false;
    int first (0);
    int iIndex(0);

    while ((found==false) && (iIndex<nTime*24)){
        if (v[iIndex]>0.0) {
            found = true;
            first = iIndex;
        }
        iIndex++;
    }

    return first;
}


