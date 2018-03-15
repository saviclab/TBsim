#include <sstream>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <chrono>

#include "PARAMclass.h"
#include "printFunctions.h"
#include "csvFunctions.h"

void PARAMclass::initialize(){
    // default values
    batchMode               = 0;
    nTime                   = 500;
    nPatients               = 100;
    nPopulations            = 1;
    therapyStart            = 180;
    kMax                    = 24;
    nSteps                  = nTime * kMax;
    nComp                   = 4;
    nODE                    = 38;
    nThreads                = 1;
    disease                 = 5;
    drugStart               = 0;
    drugStop                = 1;

    isSavePatientResults    = 0;
    isSavePopulationResults = 1;
    isSaveAdhDose           = 1;
    isSaveConc              = 1;
    isSaveConcKill          = 0;
    isSaveImmune            = 0;
    isSaveMacro             = 0;
    isSaveBact              = 1;
    isSaveBactRes           = 0;
    isSaveOutcome           = 1;
    isSaveEffect            = 0;
    isBootstrap             = 1;

    isAdherence             = 1;
    isDrugDose              = 1;
    isConcentration         = 1;
    isSolution              = 1;
    isOutcome               = 1;
    isDrugEffect            = 0;
    isResistance            = 1;
    isGranuloma             = 1;
    isGranulomaInfec        = 0;
    isImmuneKill            = 1;
    isPersistance           = 0;
    isClearResist           = 0;
    isGranImmuneKill        = 0;
    isGradualDiffusion      = 0;
    persistTime             = 7;
    dataFolder              = "";

    nDrugs                  = 1;
    drugFile                = VECS();

    nTherapy                = 1;
    defaultTherapy          = 0;
    iTherapy                = defaultTherapy;
    therapyFile             = VECS();
    drugList                = std::vector<Therapy>();

    nAdherence              = 1;
    defaultAdherence        = 0;
    iAdherence              = 0;
    adherenceFile           = VECS();

    initialValueStdv        = 0.20;
    parameterStdv           = 0.20;
    timeStepStdv            = 0.05;
    adherenceType1          = 0;
    adherenceType2          = 0;
    adherenceMEMS          = 0;
    adherenceSwitchDay      = 1000;
    adherenceMean           = 0.99;
    adherenceStdv           = 0.001;
    adherenceStdvDay        = 0.10;
    adherenceDaysBetween    = VEC2();
    adherenceDaysMissed     = VEC2();
    adherenceName           = VECS();

    shareLowAcetylators     = 0.5;
    immuneMean              = 0.9;
    immuneStdv              = 0.05;
    infI                    = 100.0;
    infII                   = 0.0;
    infIII                  = 0.0;
    infIV                   = 0.0;
    resistanceRatio         = 1e-10;
    resistanceFitness       = 0.5;
    granulomaKill           = 1.0;
    granulomaGrowth         = 1.0;
    granulomaGrowthInh      = 1.0;
    granulomaFormation      = 1e-4;
    granulomaInfectionRate  = 0.0;
    granulomaBreakup        = 4e-5;
    bactThreshold           = 1.0;
    bactThresholdRes        = 1.0;
    growthLimit             = 0.01;
    freeBactLevel           = 1.0;
    latentBactLevel         = 20.0;
    nIterations             = 1;

    drugActive              = VECI();
    drugID                  = VECS();
    drugTable               = VECI();
    activeDrugs             = 0;

    seed = std::chrono::system_clock::now().time_since_epoch().count();

}

bool PARAMclass::readInit (const std::string& folder, const std::string& filename)
{
    bool fileStatus(true);
    std::string tagText, valueText, fullname;
    const char delim1 = '<';
    const char delim2 = '>';

    fullname = folder + filename;
    std::ifstream myfile (fullname);
    nDrugs = 0;         // clear counter of drug files
    nTherapy = 0;       // clear counter of therapy files
    nAdherence = 0;     // clear counter of adherence files

    //std::cout << "file:"<<fullname<<"|"<<std::endl;

    if (myfile.is_open())
    {
        while (!myfile.eof())
        {
            getline (myfile, tagText, delim1);
            getline (myfile, tagText, delim2);
            getline (myfile, valueText);

            // trim out any special characters at end of line
            // handle differences between Mac OS and Windows file format
            if ((valueText.back() == '\n') || (valueText.back() == '\r')){
                if (valueText.size()>0){
                    valueText.resize(valueText.size()-1);
                }
            }

            if (tagText == "batchMode")         {batchMode = (int)S2N(valueText);}
            if (tagText == "nTime")             {nTime = (int)S2N(valueText);}
            if (tagText == "nPatients")         {nPatients = (int)S2N(valueText);}
            if (tagText == "nPopulations")      {nPopulations = (int)S2N(valueText);}
            if (tagText == "nThreads")          {nThreads = (int)S2N(valueText);}
            if (tagText == "therapyStart")      {therapyStart = (int)S2N(valueText);}
            if (tagText == "disease")           {disease = (int)S2N(valueText);}
            if (tagText == "kMax")              {kMax = (int)S2N(valueText);}
            if (tagText == "defaultTherapy")    {defaultTherapy = (int)S2N(valueText);}

            if (tagText == "isSavePatientResults") {isSavePatientResults = (int)S2N(valueText);}
            if (tagText == "isSavePopulationResults") {isSavePopulationResults = (int)S2N(valueText);}
            if (tagText == "isSaveAdhDose")     {isSaveAdhDose  = (int)S2N(valueText);}
            if (tagText == "isSaveConc")        {isSaveConc     = (int)S2N(valueText);}
            if (tagText == "isSaveConcKill")    {isSaveConcKill = (int)S2N(valueText);}
            if (tagText == "isSaveImmune")      {isSaveImmune   = (int)S2N(valueText);}
            if (tagText == "isSaveMacro")       {isSaveMacro    = (int)S2N(valueText);}
            if (tagText == "isSaveBact")        {isSaveBact     = (int)S2N(valueText);}
            if (tagText == "isSaveBactRes")     {isSaveBactRes  = (int)S2N(valueText);}
            if (tagText == "isSaveOutcome")     {isSaveOutcome  = (int)S2N(valueText);}
            if (tagText == "isSaveEffect")      {isSaveEffect   = (int)S2N(valueText);}
            if (tagText == "isBootstrap")       {isBootstrap    = (int)S2N(valueText);}

            if (tagText == "isAdherence") {isAdherence = (int)S2N(valueText);}
            if (tagText == "isDrugDose") {isDrugDose = (int)S2N(valueText);}
            if (tagText == "isConcentration") {isConcentration = (int)S2N(valueText);}
            if (tagText == "isSolution") {isSolution = (int)S2N(valueText);}
            if (tagText == "isOutcome") {isOutcome = (int)S2N(valueText);}
            if (tagText == "isDrugEffect") {isDrugEffect = (int)S2N(valueText);}

            if (tagText == "isResistance") {isResistance = (int)S2N(valueText);}
            if (tagText == "isGranuloma") {isGranuloma = (int)S2N(valueText);}
            if (tagText == "isImmuneKill") {isImmuneKill = (int)S2N(valueText);}
            if (tagText == "isPersistance") {isPersistance = (int)S2N(valueText);}
            if (tagText == "isGranulomaInfec") {isGranulomaInfec = (int)S2N(valueText);}
            if (tagText == "isClearResist") {isClearResist = (int)S2N(valueText);}
            if (tagText == "isGranImmuneKill") {isGranImmuneKill = (int)S2N(valueText);}
            if (tagText == "isGradualDiffusion") {isGradualDiffusion = (int)S2N(valueText);}
            if (tagText == "persistTime") {persistTime = (int)S2N(valueText);}

            if (tagText == "dataFolder") {dataFolder = valueText;}

            if (tagText == "initialValueStdv") {initialValueStdv = S2N(valueText);}
            if (tagText == "parameterStdv") {parameterStdv = S2N(valueText);}
            if (tagText == "timeStepStdv") {timeStepStdv = S2N(valueText);}

            if (tagText == "adherenceType1") {adherenceType1 = S2N(valueText);}
            if (tagText == "adherenceType2") {adherenceType2 = S2N(valueText);}
            if (tagText == "adherenceMEMS") {adherenceMEMS = S2N(valueText);}
            if (tagText == "adherenceSwitchDay") {adherenceSwitchDay = S2N(valueText);}
            if (tagText == "adherenceMean") {adherenceMean = S2N(valueText);}
            if (tagText == "adherenceStdv") {adherenceStdv = S2N(valueText);}
            if (tagText == "adherenceStdvDay") {adherenceStdvDay = S2N(valueText);}
            if (tagText == "defaultAdherence") {defaultAdherence = (int)S2N(valueText);}

            if (tagText == "shareLowAcetylators") {shareLowAcetylators = S2N(valueText);}
            if (tagText == "immuneMean") {immuneMean = S2N(valueText);}
            if (tagText == "immuneStdv") {immuneStdv = S2N(valueText);}

            if (tagText == "infI") {infI = S2N(valueText);}
            if (tagText == "infII") {infII = S2N(valueText);}
            if (tagText == "infIII") {infIII = S2N(valueText);}
            if (tagText == "infIV") {infIV = S2N(valueText);}
            if (tagText == "resistanceRatio") {resistanceRatio = S2N(valueText);}
            if (tagText == "resistanceFitness") {resistanceFitness = S2N(valueText);}

            if (tagText == "granulomaKill")         {granulomaKill = S2N(valueText);}
            if (tagText == "granulomaGrowth")       {granulomaGrowth = S2N(valueText);}
            if (tagText == "granulomaGrowthInh")    {granulomaGrowthInh = S2N(valueText);}
            if (tagText == "granulomaFormation")    {granulomaFormation = S2N(valueText);}
            if (tagText == "granulomaBreakup")      {granulomaBreakup = S2N(valueText);}
            if (tagText == "granulomaInfectionRate"){granulomaInfectionRate = S2N(valueText);}
            if (tagText == "bactThreshold")         {bactThreshold = S2N(valueText);}
            if (tagText == "bactThresholdRes")      {bactThresholdRes = S2N(valueText);}
            if (tagText == "growthLimit")           {growthLimit = S2N(valueText);}
            if (tagText == "freeBactLevel")         {freeBactLevel = S2N(valueText);}
            if (tagText == "latentBactLevel")       {latentBactLevel = S2N(valueText);}
            if (tagText == "nIterations")           {nIterations = S2N(valueText);}

            if (tagText == "seed")                  {seed = S2N(valueText);}

            if (tagText == "drugFile") {
                drugFile.push_back(valueText);
                nDrugs++;
            }
            if (tagText == "therapyFile") {
                therapyFile.push_back(valueText);
                nTherapy++;
            }
            if (tagText == "adherenceFile") {
                adherenceFile.push_back(valueText);
                nAdherence++;
            }
        }
        myfile.close();
        std::cout << "Config file loaded"<<std::endl;
        fileStatus = true;
    }
    else {
        std::cout << "Error: unable to load config file"<<std::endl;
        fileStatus = false;
    }
    return fileStatus;
}

bool PARAMclass::readMEMSAdherence (const std::string& folder)
{
    bool fileStatus(true);
    std::string fullname;
    fullname = folder + "mems.csv";
    std::cout << "Reading MEMS data: " << fullname << "\n";
    adherenceMEMSvec = readCSV(fullname);
    std::cout << "  " << adherenceMEMSvec.size() << " patient(s)\n";
    std::cout << "  " << adherenceMEMSvec[0].size() << " days of MEMS data per patient\n";
    return fileStatus;
}

bool PARAMclass::readAdherence (const std::string& folder)
{
    bool fileStatus(true);
    std::string tagText, valueText, fullname;
    const char delim1 = '<';
    const char delim2 = '>';

    for (int i=0;i<nAdherence;i++)
    {
        fullname = folder + adherenceFile[i];
        std::ifstream myfile (fullname);

        if (myfile.is_open())
        {
            while (!myfile.eof())
            {
                getline (myfile, tagText, delim1);
                getline (myfile, tagText, delim2);
                getline (myfile, valueText);

                if (tagText == "adherenceName") { adherenceName.push_back(valueText);}
                if (tagText == "adherenceDaysBetween") {adherenceDaysBetween.push_back(readArray(valueText));}
                if (tagText == "adherenceDaysMissed") {adherenceDaysMissed.push_back(readArray(valueText));}
            }
            myfile.close();
            std::cout << "Loaded adherence file "<< adherenceFile[i] <<std::endl;
            fileStatus = true;
        }
        else {
            std::cout << "Error: unable to load adherence file "<< adherenceFile[i] <<std::endl;
            // remove the item that could not be opened from vector
            adherenceFile.erase(adherenceFile.begin()+i);
            nAdherence--;
            fileStatus = false;
        }
    }
    return fileStatus;
}

bool PARAMclass::readTherapy (const std::string& folder)
{
    bool fileStatus(true);
    std::string tagText, valueText, temp, fullname;
    const char delim1 = '<';
    const char delim2 = '>';
    const char pipe = '|';

    for (int i=0;i<nTherapy;i++)
    {
        fullname = folder + therapyFile[i];
        std::ifstream myfile (fullname, std::ifstream::in);

        if (myfile.is_open())
        {
            //std::cout<<"opened file"<<std::endl;
            while (!myfile.eof())
            {
                //std::cout<<"read line"<<std::endl;

                getline (myfile, tagText, delim1);
                getline (myfile, tagText, delim2);
                getline (myfile, valueText);

                if (tagText == "name") {drugList.push_back(Therapy()); // add one more member to list of drugs
                                        drugList[i].name = valueText;}
                if (tagText == "description") {drugList[i].description = valueText;}

                if (tagText == "drug") {
                    temp = valueText;
                    int p1 = int(temp.find(pipe));
                    int p2 = int(temp.find(pipe, p1+1));
                    int p3 = int(temp.find(pipe, p2+1));
                    int p4 = int(temp.find(pipe, p3+1));
                    int p5 = int(temp.find(pipe, p4+1));

                    drugList[i].drugName.push_back(temp.substr(0, p1));
                    drugList[i].drugDose.push_back((double)S2N(temp.substr(p1+1, p2-p1)));
                    drugList[i].drugStart.push_back((int)S2N(temp.substr(p2+1, p3-p2)));
                    drugList[i].drugStop.push_back((int)S2N(temp.substr(p3+1, p4-p3)));
                    drugList[i].drugInt.push_back((int)S2N(temp.substr(p4+1, p5-p4)));
                    drugList[i].nRecords++;
                }
            }
            myfile.close();
            std::cout << "Loaded therapy file "<< therapyFile[i] <<std::endl;
            fileStatus = true;
        }
        else {
            std::cout << "Error: unable to load therapy file "<< therapyFile[i] <<std::endl;
            // remove the item that could not be opened
            therapyFile.erase(therapyFile.begin()+i);
            nTherapy--;
            fileStatus = false;
        }
    }
    return fileStatus;
}

double PARAMclass::S2N(std::string text)
{
    double N;
    if ( ! (std::istringstream(text) >> N) ) N = 0.0;
    return N;
}

VEC PARAMclass::readArray(std::string& valueText){
    const char pipe = '|';
    std::string temp;
    VEC tempA(10, 0.0);

    temp = valueText;
    int p1 = int(temp.find(pipe));
    int p2 = int(temp.find(pipe, p1+1));
    int p3 = int(temp.find(pipe, p2+1));
    int p4 = int(temp.find(pipe, p3+1));
    int p5 = int(temp.find(pipe, p4+1));
    int p6 = int(temp.find(pipe, p5+1));
    int p7 = int(temp.find(pipe, p6+1));
    int p8 = int(temp.find(pipe, p7+1));
    int p9 = int(temp.find(pipe, p8+1));
    int p10 = int(temp.find(pipe, p9+1));

    tempA[0] = (double)S2N(temp.substr(0, p1));
    tempA[1] = (double)S2N(temp.substr(p1+1, p2-p1));
    tempA[2] = (double)S2N(temp.substr(p2+1, p3-p2));
    tempA[3] = (double)S2N(temp.substr(p3+1, p4-p3));
    tempA[4] = (double)S2N(temp.substr(p4+1, p5-p4));
    tempA[5] = (double)S2N(temp.substr(p5+1, p6-p5));
    tempA[6] = (double)S2N(temp.substr(p6+1, p7-p6));
    tempA[7] = (double)S2N(temp.substr(p7+1, p8-p7));
    tempA[8] = (double)S2N(temp.substr(p8+1, p9-p8));
    tempA[9] = (double)S2N(temp.substr(p9+1, p10-p9));

    return tempA;
}

//=================================================================
// Print key simulation parameters
//=================================================================
void PARAMclass::printParameters()
{
    std::cout << "Patients              : " << nPatients << std::endl;
    std::cout << "Number of days        : " << nTime << std::endl;
    std::cout << "Number of populations : " << nPopulations << std::endl;
    std::cout << "Number of iterations  : " << nIterations << std::endl;
    std::cout << "Bootstrap processing  : " << printYesNo(isBootstrap) << std::endl;
    std::cout << "Therapy start day     : " << therapyStart << std::endl;
    if(adherenceMEMS) {
        std::cout << "Adherence pattern     : MEMS" << std::endl;
    } else {
        std::cout << "Adherence pattern     : " << adherenceType1 <<" / "
                                         << adherenceType2 <<" Day: "
                                         << adherenceSwitchDay << std::endl;
        std::cout << "Adherence mean/stdv   : " << adherenceMean << " / "
                                         << adherenceStdv << std::endl;
    }

    std::cout << "Bacterial start pop   : I(" << infI   <<"), II(" << infII << "), III("
                                       << infIII <<"), IV(" << infIV << ")" << std::endl;
    std::cout << "Bacterial resistance  : " << printYesNo(isResistance)  << std::endl;
    std::cout << "Persistance effect    : " << printYesNo(isPersistance) << std::endl;
    std::cout << "Immune kill effect    : " << printYesNo(isImmuneKill)<<std::endl;
    std::cout << "Immune system level   : " << immuneMean << std::endl;
    if (iTherapy>0) {
        std::cout << "Drug therapy          : " << "("<<iTherapy<<") "<<drugList[iTherapy].name << std::endl;
        std::cout << "Dosing schedule       : " << drugList[iTherapy].description << std::endl;
    }
    std::cout << "Drug start/stop       : " << drugStart << " / "
                                     << drugStop  << std::endl;
    std::cout << "Gran effect/infect.   : " << printYesNo(isGranuloma) << " / " <<
                                        printYesNo(isGranulomaInfec) << std::endl;
    std::cout << "Gran form./break-up   : " << granulomaFormation << " / " << granulomaBreakup<<std::endl;
    std::cout << "Filter wild/resist.   : " << bactThreshold << " / "
                                     << bactThresholdRes << std::endl;
    std::cout << "Limit free/granuloma  : " << freeBactLevel << " / "
                                     << latentBactLevel << std::endl;

    std::cout << "Simulation seed       : " << seed << std::endl;
}


//=================================================================
// Name   : updateParameters
// Type   : void
// Purpose: update program parameters at run time
// Inputs : int inputValue
// Outputs: PARA
// Methods: uses secondary prompts to get more inputs
// Note   : inputValue must be in range [1-4]
//          no error checking is performed on the secondary inputs!
// Error  :
// Revised: June 12, 2014
// Author : John Fors, UCSF
//=================================================================
void PARAMclass::updateParameter(int inputValue)
{
    // minimal error checking is performed of user inputs

    int inputValue2(0);

    if (inputValue==1){
        std::cout << "1. Patients          : " << nPatients << std::endl;
        std::cout << "2. Time              : " << nTime << std::endl;
        std::cout << "3. Iterations        : " << nIterations << std::endl;
        std::cout << "4. Populations       : " << nPopulations << std::endl;
        std::cout << "5. Run Bootstrap     : " << printYesNo(isBootstrap) << std::endl;
        std::cout << "6. Therapy start     : " << therapyStart << std::endl;
        std::cout << "7. Run Adherence     : " << printYesNo(isAdherence) << std::endl;
        std::cout << "8. Run Dose          : " << printYesNo(isDrugDose) << std::endl;
        std::cout << "9. Run Concentration : " << printYesNo(isConcentration) << std::endl;
        std::cout << "10.Run PD solver     : " << printYesNo(isSolution) << std::endl;
        std::cout << "11.Run Outcome calc  : " << printYesNo(isOutcome) << std::endl;
        std::cout << "12.Run Drug effect   : " << printYesNo(isDrugEffect) << std::endl;
        std::cout << "13.Number of threads : " << nThreads << std::endl;
        std::cout << "0. Cancel" << std::endl;
        std::cout << " : ";
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {std::cout << "Number of patients [1-1000] : ";   std::cin >> nPatients;     break;}
            case 2: {std::cout << "Total time [10-1000] : ";          std::cin >> nTime;         break;}
            case 3: {std::cout << "Number of iterations [1-1000] : "; std::cin >> nIterations;   break;}
            case 4: {std::cout << "Number of populations [1-100] : "; std::cin >> nPopulations;  break;}
            case 5: {std::cout << "Run bootstrap [0,1] : ";           std::cin >> isBootstrap;   break;}
            case 6: {std::cout << "Therapy start day [1...] : ";      std::cin >> therapyStart;  break;}
            case 7: {std::cout << "Run adherence [0,1] : ";           std::cin >> isAdherence;   break;}
            case 8: {std::cout << "Run drug dose [0,1] : ";           std::cin >> isDrugDose;    break;}
            case 9: {std::cout << "Run concentration [0,1] : ";       std::cin >> isConcentration; break;}
            case 10: {std::cout << "Run PD solver [0,1] : ";          std::cin >> isSolution;    break;}
            case 11: {std::cout << "Run outcome calc [0,1] : ";       std::cin >> isOutcome;     break;}
            case 12: {std::cout <<"Run drug effect analysis [0,1] : ";std::cin >> isDrugEffect;  break;}
            case 13: {std::cout <<"Number of threads [1..N] : ";      std::cin >> nThreads;      break;}
            default: { break;}
        }
    }
    else if (inputValue==2){
        std::cout << "1. Adherence type #1    : " << adherenceType1 << std::endl;
        std::cout << "2. Adherence type #2    : " << adherenceType2 << std::endl;
        std::cout << "3. Adherence switch day : " << adherenceSwitchDay << std::endl;
        std::cout << "4. Adherence mean       : " << adherenceMean << std::endl;
        std::cout << "5. Adherence stdv       : " << adherenceStdv << std::endl;
        std::cout << "9. Cancel" << std::endl;
        std::cout << " : ";
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {std::cout << "Adherence type period 1 [0,1,9] : "; std::cin >> adherenceType1; break;}
            case 2: {std::cout << "Adherence type period 2 [0,1,9] : "; std::cin >> adherenceType2; break;}
            case 3: {std::cout << "Adherence switch day [1-...] : "; std::cin >> adherenceSwitchDay; break;}
            case 4: {std::cout << "Adherence mean [0.0-1.0] : "; std::cin >> adherenceMean; break;}
            case 5: {std::cout << "Adherence stdv [0.0-1.0] : "; std::cin >> adherenceStdv; break;}
            default: {break;}
        }
    }
    else if (inputValue==3) {
        std::cout << "1. Bacteria in compartment I   : " << infI << std::endl;
        std::cout << "2. Bacteria in compartment III : " << infIII << std::endl;
        std::cout << "9. Cancel" << std::endl;
        std::cout << " : ";
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {std::cout << "Bacteria in compartment I [0-10000] : "; std::cin >> infI; break;}
            case 2: {std::cout << "Bacteria in compartment III [0-10000] : ";std::cin >> infIII; break;}
            default: {break;}
        }
    }
    else if (inputValue==4) {
        std::cout << "1. Immune system effect : " << printYesNo(isImmuneKill) << std::endl;
        std::cout << "2. Immune system level  : " << immuneMean << std::endl;
        std::cout << "9. Cancel";
        std::cout << " : ";
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {std::cout << "Immune system effects [0,1] : "; std::cin >> isImmuneKill; break;}
            case 2: {std::cout << "Immune system level [0..1] : ";  std::cin >> immuneMean;   break;}
            default: {break;}
        }
    }
    else if (inputValue==5) {
        std::cout << "Drug therapy descr. : " << iTherapy<<" "<<drugList[iTherapy].name << std::endl;
        std::cout << "Dosing schedule     : " << drugList[iTherapy].description << std::endl;
        std::cout << "1. Select drug therapy" << std::endl;
        std::cout << "9. Cancel" << std::endl;
        std::cout << " : ";
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {
                for (int i=0;i<nTherapy;i++){
                    std::cout << i << " " << drugList[i].name << " " << drugList[i].description << std::endl;
                }
                std::cout << std::endl;
                std::cout << "Enter therapy alternative [0-"<<nTherapy-1<<"] : "; std::cin >> iTherapy;
                break;
            }
            default: {break;}
        }
    }
    else if (inputValue==6) {
        std::cout << "1. Granuloma effect    : " << printYesNo(isGranuloma) << std::endl;
        std::cout << "2. Granuloma infection : " << printYesNo(isGranulomaInfec) << std::endl;
        std::cout << "3. Granuloma imm. kill : " << printYesNo(isGranImmuneKill) << std::endl;
        std::cout << "4. Granuloma formation coefficient : " << granulomaFormation << std::endl;
        std::cout << "5. Granuloma breakup coefficient : " << granulomaBreakup << std::endl;
        std::cout << "6. Granuloma gradual drug diffusion: " << printYesNo(isGradualDiffusion) << std::endl;
        std::cout << "9. Cancel"<<std::endl;
        std::cout << " : ";
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {std::cout << "Granuloma effect [0,1] : "; std::cin >> isGranuloma; break;}
            case 2: {std::cout << "Granuloma infection [0,1] : "; std::cin >> isGranulomaInfec; break;}
            case 3: {std::cout << "Granuloma immune kill [0,1] : "; std::cin >> isGranImmuneKill; break;}
            case 4: {std::cout << "Granuloma formation coeff : "; std::cin >> granulomaFormation; break;}
            case 5: {std::cout << "Granuloma breakup coeff : "; std::cin >> granulomaBreakup; break;}
            case 6: {std::cout << "Granuloma gradual drug diffusion [0,1] : "; std::cin >> isGradualDiffusion; break;}
            default: {break;}
        }
    }
    else if (inputValue==7) {
        std::cout << "1. Bacterial resistance         : " << printYesNo(isResistance) << std::endl;
        std::cout << "2. Bacterial persistence        : " << printYesNo(isPersistance) << std::endl;
        std::cout << "3. Bacteria threshold           : " << bactThreshold <<std::endl;
        std::cout << "4. Resistant bacteria threshold : " << bactThresholdRes << std::endl;
        std::cout << "5. Free bacteria limit          : " << freeBactLevel << std::endl;
        std::cout << "6. Granuloma bacteria limit     : " << latentBactLevel << std::endl;
        std::cout << "9. Cancel" << std::endl;
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {std::cout << "Bacterial resistance [0,1] : ";            std::cin >> isResistance;     break;}
            case 2: {std::cout << "Persistance effect [0,1] : ";              std::cin >> isPersistance;    break;}
            case 3: {std::cout << "Bacteria threshold [0-1000] : ";           std::cin >> bactThreshold;    break;}
            case 4: {std::cout << "Resistant bacteria threshold [0-1000] : "; std::cin >> bactThresholdRes; break;}
            case 5: {std::cout << "Free bacteria limit [0-1000] : ";          std::cin >> freeBactLevel;    break;}
            case 6: {std::cout << "Granuloma bacteria limit [0-1000] : ";     std::cin >> latentBactLevel;  break;}
            default: {break;}
        }
    }
    else if (inputValue==8) {
        std::cout << "1. Save patient results    : " << printYesNo(isSavePatientResults) << std::endl;
        std::cout << "2. Save population results : " << printYesNo(isSavePopulationResults) << std::endl;
        std::cout << "3. Save adh & dose data    : " << printYesNo(isSaveAdhDose) << std::endl;
        std::cout << "4. Save conc data          : " << printYesNo(isSaveConc) << std::endl;
        std::cout << "5. Save conc kill/grow     : " << printYesNo(isSaveConcKill) << std::endl;
        std::cout << "6. Save immune system data : " << printYesNo(isSaveImmune) << std::endl;
        std::cout << "7. Save macro data         : " << printYesNo(isSaveMacro) << std::endl;
        std::cout << "8. Save bact totals data   : " << printYesNo(isSaveBact) << std::endl;
        std::cout << "9. Save bact resistant data: " << printYesNo(isSaveBactRes) << std::endl;
        std::cout << "10.Save outcome data       : " << printYesNo(isSaveOutcome) << std::endl;
        std::cout << "11.Save drug effect data   : " << printYesNo(isSaveEffect) << std::endl;
        std::cout << "0. Cancel"<<std::endl;
        std::cout << " : ";
        std::cin >> inputValue2;
        switch (inputValue2) {
            case 1: {std::cout << "Save patient results [0,1] : ";       std::cin >> isSavePatientResults; break;}
            case 2: {std::cout << "Save population results [0,1] : ";    std::cin >> isSavePopulationResults; break;}
            case 3: {std::cout << "Save adh & dose data [0,1] : ";       std::cin >> isSaveAdhDose; break;}
            case 4: {std::cout << "Save conc data [0,1] : ";             std::cin >> isSaveConc; break;}
            case 5: {std::cout << "Save conc kill & grow data [0,1] : "; std::cin >> isSaveConcKill; break;}
            case 6: {std::cout << "Save immune data [0,1] : ";           std::cin >> isSaveImmune; break;}
            case 7: {std::cout << "Save macro data [0,1] : ";            std::cin >> isSaveMacro; break;}
            case 8: {std::cout << "Save bact totals data [0,1] : ";      std::cin >> isSaveBact; break;}
            case 9: {std::cout << "Save bact res data [0,1] : ";         std::cin >> isSaveBactRes; break;}
            case 10:{std::cout << "Save outcome system data [0,1] : ";   std::cin >> isSaveOutcome; break;}
            case 11:{std::cout << "Save drug effect data [0,1] : ";      std::cin >> isSaveEffect; break;}
            default: {break;}
        }
    }
    // adjust bootstrap setting
    if (isBootstrap==1)     {nPopulations =1;}

    // update settings based on highest level selected to reduce user effort
    if (isDrugDose==1)      {isAdherence=1;}
    if (isConcentration==1) {isDrugDose=1; isAdherence=1;}
    if (isSolution==1)      {isConcentration=1; isDrugDose=1; isAdherence=1;}
    if (isOutcome==1)       {isSolution=1; isConcentration=1; isDrugDose=1; isAdherence=1;}

    // ensure solution is enabled when selecting drugEffect
    if ((isDrugEffect==1)&&(isSolution==0)) {isDrugEffect=0;}

    // do some basic checks of input parameters
    if (therapyStart<0) {therapyStart=0;}
    if (therapyStart>nTime) {therapyStart=0;}

    if (nTime<1) {nTime=1;}
    if (nTime>1000) {nTime=1000;}

    if (nPatients<1) {nPatients=1;}
    if (nPatients>5000) {nPatients=5000;}

    if (nIterations<1) {nIterations=1;}
    if (nIterations>5000) {nIterations=5000;}

    if (nThreads<1) {nThreads=1;}

    if (nPatients*nTime*nIterations>(1000*500*1000)) {
        std::cout << "Warning: very large simulation size"<<std::endl;
    }
    // number of time steps used in ODE calculations
    nSteps = nTime * kMax;
}
