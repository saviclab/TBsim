#include <vector>
#include <sstream>
#include <iostream>
#include <fstream>
#include <algorithm>
#include <chrono>

#include "IMMUNEclass.h"
#include "statFunctions.h"

VEC IMMUNEclass::getp()
{
    return p;
}

double IMMUNEclass::getCalcI(int iP)
{
    return calcI[iP];
}

void IMMUNEclass::setImmuneStatus(int nPatients, double immuneMean, double immuneStdv)
{
    calcI.assign(nPatients, 0.0);
    const double minIm = 0.0;          // min immune level
    const double maxIm = 1.0;          // max immune level

    // randomize immune status per patient
    for (int iP=0; iP<nPatients; iP++)
    {
        calcI[iP] = normDist(immuneMean, immuneMean * immuneStdv, minIm, maxIm);
    }
}

int IMMUNEclass::getnPar()
{
    return nPar;
}

//=================================================================
// FUNCTION: setParameters
// set parameter values used for TB ODE equations
// first set default values for Latent disease per Kirschner model
// then adjust based on disease type selected
//=================================================================
void IMMUNEclass::setInitialValues (int disease)
{
    p.assign(nPar, 0.0);

    // Macrophages
    p[0] = 5000.0;      // sM
    p[1] = 0.04;        // a4
    p[2] = 0.14;        // w
    p[3] = 0.36;        // k4
    p[4] = 100.0;       // s8
    p[5] = 0.4;         // k2
    p[6] = 1.0e6;       // c9
    p[7] = 0.4;         // k3
    p[8] = 2.333;       // f3
    p[9] = 150.0;       // s3
    p[10] = 5.0e5;      // c8
    p[11] = 0.01;       // mu_r
    p[12] = 0.01;       // mu_a
    p[13] = 0.1;        // k17
    p[14] = 0.5;        // k14
    p[15] = 0.15;       // c4
    p[16] = 0.01;       // mu_i

    // Cytokines
    p[17] = 0.0008;     // a8
    p[18] = 2.75e-6;    // a23
    p[19] = 1.188;      // mu_IL12L
    p[20] = 700.0;      // sg
    p[21] = 5.0e3;      // c10
    p[22] = 50.0;       // s4
    p[23] = 0.02;       // a5
    p[24] = 1e5;        // c5
    p[25] = 3.0;        // mu_IFN
    p[26] = 6.0e-3;     // a14
    p[27] = 51.0;       // s6
    p[28] = 0.05;       // f6
    p[29] = 5.0e-5;     // a16
    p[30] = 1.0e-4;     // a17
    p[31] = 1.0e-4;     // a18
    p[32] = 1.0e-4;     // d7
    p[33] = 3.6968;     // mu_IL10
    p[34] = 0.0029;     // a11
    p[35] = 0.0218;     // a12
    p[36] = 2.77;       // mu_IL4

    // T cells
    p[37] = 1.5e4;      // d6
    p[38] = 4.0e-1;     // a2
    p[39] = 1.0e5;      // c15
    p[40] = 0.3333;     // mu_Tp
    p[41] = 0.1;        // k6
    p[42] = 4.1;        // f1
    p[43] = 4.8;        // f7
    p[44] = 30.0;       // s1
    p[45] = 0.05;       // k7
    p[46] = 0.12;       // f2
    p[47] = 2.0;        // s2
    p[48] = 0.3333;     // mu_T1
    p[49] = 0.3333;     // mu_T2

    // Bacteria
    p[50] = 0.005;      // a20
    p[51] = 1.25e-7;    // k15
    p[52] = 1.25e-8;    // k18
    p[53] = 0.1;        // a19
    p[54] = 50.0;       // N
    p[55] = 20.0;       // Ni

    // IL12 in DLN
    p[56] = 0.0035;     // d1
    p[57] = 1.188;      // mu_IL12LN

    // T cells in DLN
    p[58] = 1000;       // sT
    p[59] = 0.1;        // d2
    p[60] = 0.1;        // lambda1
    p[61] = 0.002;      // mu_T
    p[62] = 0.0001;     // d4
    p[63] = 0.9;        // d5
    p[64] = 3000.0;     // rho
    p[65] = 0.9;        // theta
    p[66] = 1.0;        // scale

    // Dendritic cells
    p[67] = 0.02;       // mu_MDC
    p[68] = 1.0e-7;     // d12
    p[69] = 500.0;      // sIDC
    p[70] = 0.02;       // d8
    p[71] = 1.5e5;      // d9
    p[72] = 0.2;        // d10
    p[73] = 1.0e4;      // d11
    p[74] = 0.01;       // mu_IDC
    p[75] = 1.5e9;      // Bemax

    if (disease == 1) // Primary TB (Kirschner)
    {
        p[14] = 1.6;    // k14
        p[41] = 1.0e-5; // k6
        p[45] = 0.7;    // k7
        p[50] = 0.005;  // a20
        p[53] = 0.1;    // a19
        p[73] = 100.0;  // d11
    }
    if (disease == 3) // Clearance (Kirschner)
    {
        p[38] = 0.14;   // a2
        p[56] = 0.035;  // d1
        p[72] = 0.2;    // d10
        p[41] = 1.0e-1; // k6
    }
    if (disease == 4) // Reactivation (Kirschner)
    {
        p[45] = 0.1;    // k7
        p[41] = 1.0e-3; // k6
        p[50] = 0.016;  // a20
        p[53] = 0.01;   // a19
        p[68] = 1.0e-5; // d12
        p[73] = 100.0;  // d11
        p[56] = 0.035;  // d1
        p[72] = 0.2;    // d10
    }
    if (disease == 5) // Primary TB (Goutelle)
    {
        p[14] = 1.6;    // k14
        p[41] = 1.0e-5; // k6
        p[45] = 0.7;    // k7
        p[50] = 0.05;   // a20
        p[53] = 0.09;   // a19 was 0.10
        p[68] = 1.0e-5; // d12
        p[73] = 100.0;  // d11
    }
    if (disease == 6) // Latent TB (Goutelle)
    {
        p[50] = 0.01;   // a20
    }
}

bool IMMUNEclass::readImmuneParameters(int disease, const std::string& folder, VECS& immuneFile)
{
    bool fileStatus (true);
    p.assign(nPar, 0.0);
    std::string noText, tagText, valueText;
    const char delim1 = '<';
    const char delim2 = '>';
    const std::string fullname = folder + immuneFile[0];
    std::ifstream myfile (fullname.c_str());

    if (myfile.is_open())
    {
        while (!myfile.eof())
        {
            std::getline (myfile, noText, delim1);
            std::getline (myfile, tagText, delim2);
            std::getline (myfile, valueText);

            // trim out any special characters at end of line
            // handle differences between Mac OS and Windows file format
            if ((valueText.back() == '\n') || (valueText.back() == '\r')){
                if (valueText.size()>0){
                    valueText.resize(valueText.size()-1);
                }
            }

            if (tagText == "sM")    {p[0] = S2N(valueText);}
            if (tagText == "a4")  {p[1] = S2N(valueText);}
            if (tagText == "w")   {p[2] = S2N(valueText);}
            if (tagText == "k4")  {p[3] = S2N(valueText);}
            if (tagText == "s8") {p[4] = S2N(valueText);}
            if (tagText == "k2")   {p[5] = S2N(valueText);}
            if (tagText == "c9") {p[6] = S2N(valueText);}
            if (tagText == "k3")   {p[7] = S2N(valueText);}
            if (tagText == "f3") {p[8] = S2N(valueText);}
            if (tagText == "s3") {p[9] = S2N(valueText);}
            if (tagText == "c8") {p[10] = S2N(valueText);}
            if (tagText == "mu_r")    {p[11] = S2N(valueText);}
            if (tagText == "mu_a")    {p[12] = S2N(valueText);}
            if (tagText == "k17")  {p[13] = S2N(valueText);}
            if (tagText == "k14")  {p[14] = S2N(valueText);}
            if (tagText == "c4")  {p[15] = S2N(valueText);}
            if (tagText == "mu_i")    {p[16] = S2N(valueText);}
            if (tagText == "a8")    {p[17] = S2N(valueText);}
            if (tagText == "a23")  {p[18] = S2N(valueText);}
            if (tagText == "mu_IL12L")   {p[19] = S2N(valueText);}
            if (tagText == "sg") {p[20] = S2N(valueText);}
            if (tagText == "c10")    {p[21] = S2N(valueText);}
            if (tagText == "s4")  {p[22] = S2N(valueText);}
            if (tagText == "a5")  {p[23] = S2N(valueText);}
            if (tagText == "c5")   {p[24] = S2N(valueText);}
            if (tagText == "mu_IFN")   {p[25] = S2N(valueText);}
            if (tagText == "a14")   {p[26] = S2N(valueText);}
            if (tagText == "s6")  {p[27] = S2N(valueText);}
            if (tagText == "f6")  {p[28] = S2N(valueText);}
            if (tagText == "a16")   {p[29] = S2N(valueText);}
            if (tagText == "a17")   {p[30] = S2N(valueText);}
            if (tagText == "a18")   {p[31] = S2N(valueText);}
            if (tagText == "d7")    {p[32] = S2N(valueText);}
            if (tagText == "mu_IL10")   {p[33] = S2N(valueText);}
            if (tagText == "a11")   {p[34] = S2N(valueText);}
            if (tagText == "a12")   {p[35] = S2N(valueText);}
            if (tagText == "mu_IL4")  {p[36] = S2N(valueText);}
            if (tagText == "d6") {p[37] = S2N(valueText);}
            if (tagText == "a2")    {p[38] = S2N(valueText);}
            if (tagText == "c15")    {p[39] = S2N(valueText);}
            if (tagText == "mu_Tp") {p[40] = S2N(valueText);}
            if (tagText == "k6")   {p[41] = S2N(valueText);}
            if (tagText == "f1")   {p[42] = S2N(valueText);}
            if (tagText == "f7")   {p[43] = S2N(valueText);}
            if (tagText == "s1")  {p[44] = S2N(valueText);}
            if (tagText == "k7")  {p[45] = S2N(valueText);}
            if (tagText == "f2")  {p[46] = S2N(valueText);}
            if (tagText == "s2")   {p[47] = S2N(valueText);}
            if (tagText == "mu_T1") {p[48] = S2N(valueText);}
            if (tagText == "mu_T2") {p[49] = S2N(valueText);}
            if (tagText == "a20")    {p[50] = S2N(valueText);}
            if (tagText == "k15")  {p[51] = S2N(valueText);}
            if (tagText == "k18")  {p[52] = S2N(valueText);}
            if (tagText == "a19")  {p[53] = S2N(valueText);}
            if (tagText == "N")   {p[54] = S2N(valueText);}
            if (tagText == "Ni")  {p[55] = S2N(valueText);}
            if (tagText == "d1")    {p[56] = S2N(valueText);}
            if (tagText == "mu_IL12LN")  {p[57] = S2N(valueText);}
            if (tagText == "sT")  {p[58] = S2N(valueText);}
            if (tagText == "d2")   {p[59] = S2N(valueText);}
            if (tagText == "lambda1")  {p[60] = S2N(valueText);}
            if (tagText == "mu_T")   {p[61] = S2N(valueText);}
            if (tagText == "d4")    {p[62] = S2N(valueText);}
            if (tagText == "d5")   {p[63] = S2N(valueText);}
            if (tagText == "rho")   {p[64] = S2N(valueText);}
            if (tagText == "theta")    {p[65] = S2N(valueText);}
            if (tagText == "scale")    {p[66] = S2N(valueText);}
            if (tagText == "mu_MDC")  {p[67] = S2N(valueText);}
            if (tagText == "d12")   {p[68] = S2N(valueText);}
            if (tagText == "sIDC")   {p[69] = S2N(valueText);}
            if (tagText == "d8")  {p[70] = S2N(valueText);}
            if (tagText == "d9") {p[71] = S2N(valueText);}
            if (tagText == "d10")  {p[72] = S2N(valueText);}
            if (tagText == "d11")    {p[73] = S2N(valueText);}
            if (tagText == "mu_IDC")  {p[74] = S2N(valueText);}
            if (tagText == "Bemax")  {p[75] = S2N(valueText);}
        }
        myfile.close();

        std::cout << "Loaded immune file "<<immuneFile[0]<<std::endl;
        // create final rise and fall factors to use in simulation
        // these represent change factors needed to reach 50% change
        //if (rise50>0.0){rise50 = std::log(2)/rise50;}
        //if (fall50>0.0){fall50 = std::log(2)/fall50;}
        fileStatus=true;
    }
    else{
        std::cout << "Error: unable to load immune file "<<fullname<<std::endl;
        fileStatus=false;
    }
    return fileStatus;
}


double IMMUNEclass::S2N(std::string text)
{
    double N;
    if ( ! (std::istringstream(text) >> N) ) N = 0.0;
    return N;
}
