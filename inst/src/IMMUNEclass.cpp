#include <vector>

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
