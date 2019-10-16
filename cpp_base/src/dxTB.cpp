#include <vector>

#include "dxTB.h"

//=================================================================
// Differential equations dynamics based on immune cell and PD
//=================================================================
void dxTB(double t, VEC& x, VEC& dx, VEC& p, double immuneStatus,
          PARAMclass& PARA, Factors& f)
{
    //int nDrugs = PARA.activeDrugs;
    int nODE   = PARA.nODE;
    VEC xB, dxB;

    //extract x and xB vectors
    xB.assign(x.begin() + nODE, x.begin() + nODE + PARA.activeDrugs*4);
    dxB.assign(PARA.activeDrugs*4, 0.0);

    double Ma_12(0.0), Mr_12(0.0), Mi_12(0.0), Ma_34(0.0), Mr_34(0.0), Mi_34(0.0);
    double IL10(0.0), IL12L(0.0), IL4(0.0), IFN(0.0), Tp(0.0), T1(0.0), T2(0.0);
    double IL12LN(0.0), TLN(0.0), MDC(0.0), IDC(0.0), TpLN(0.0);

    // get current macrophage values for intra/extra granuloma compartments
    getMacrophageData(x, Ma_12, Mr_12, Mi_12, Ma_34, Mr_34, Mi_34);

    // calculate macrophage totals across all compartments
    double Ma_tot = Ma_12 + Ma_34;
    double Mi_tot = Mi_12 + Mi_34;
    double Mr_tot = Mr_12 + Mr_34;

    // get current immune system values
    getImmuneData(x, IL10, IL12L, IL4, IFN, Tp, T1, T2, IL12LN, TLN, MDC, IDC, TpLN);

    // macrophages
    double dMr_12 = calcMr(p, Ma_12, Mr_12, Mi_12, IL10, IFN, IL4, f.B_I_tot, f.B_II_tot);
    double dMa_12 = calcMa(p, Ma_12, Mr_12, IL10, IL4, IFN, f.B_12_tot);
    double dMi_12 = calcMi(p, Mr_12, Mi_12, T1, f.B_I_tot, f.B_II_tot);

    double dMr_34(0.0), dMa_34(0.0), dMi_34(0.0);
    if (PARA.isGranuloma==1) {
        dMr_34 = calcMr(p, Ma_34, Mr_34, Mi_34, IL10, IFN, IL4, f.B_III_tot, f.B_IV_tot);
        dMa_34 = calcMa(p, Ma_34, Mr_34, IL10, IL4, IFN, f.B_34_tot);
        dMi_34 = calcMi(p, Mr_34, Mi_34, T1, f.B_III_tot, f.B_IV_tot);
        //cout << "Macro done"<<endl;
    }

    // Cytokines
    double dIFN   = calcIFN(p, Ma_tot, IL12L, IFN, T1, f.B_tot);
    double dIL12L = calcIL12L(p, Ma_tot, Mr_tot, IL12L);
    double dIL10  = calcIL10(p, Ma_tot, Mi_tot, IL10, IFN, T1, T2, Tp);
    double dIL4   = calcIL4(p, Tp, T2, IL4);

    // Lymphocytes
    double dTp = calcTp(p, Ma_tot, IL10, IL12L, IL4, IFN, IL12LN, Tp, TpLN);
    double dT1 = calcT1(p, IL10, IL12L, IL4, T1, IL12LN, Tp);
    double dT2 = calcT2(p, IL4, IFN, T2, Tp);

    // Lymph node cytokines and lymphocytes
    double dIL12LN = calcIL12LN(p, IL12LN, MDC);
    double dTLN    = calcTLN(p, TLN, MDC);
    double dTpLN   = calcTpLN(p, TLN, MDC, TpLN);
    double dMDC    = calcMDC(p, MDC, IDC, f.B_I_tot + f.B_III_tot);
    double dIDC    = calcIDC(p, IDC, f.B_I_tot + f.B_III_tot);

    // base growth rate per bacteria population
    // slower growth rate in granuloma,
    // note: growthInhibition factor is defined as 1/factor => increases growth rate
    double granulomaGrowthFactor = PARA.granulomaGrowth * PARA.granulomaGrowthInh;
    f.dB_I_BaseGrowth   = calcBaseBeGrowth(p, f.B_I_tot);
    f.dB_II_BaseGrowth  = calcBaseBiGrowth(p, Mi_12, f.B_II_tot);
    f.dB_III_BaseGrowth = calcBaseBeGrowth(p, f.B_III_tot)       * granulomaGrowthFactor;
    f.dB_IV_BaseGrowth  = calcBaseBiGrowth(p, Mi_34, f.B_IV_tot) * granulomaGrowthFactor;

    // immune facilitated bacterial killing, bursting, and transfer
    double dB_I_w_IM(0.0), dB_II_w_IM(0.0), dB_III_w_IM(0.0), dB_IV_w_IM(0.0);
    VEC dB_I_r_IM(PARA.activeDrugs, 0.0), dB_II_r_IM(PARA.activeDrugs, 0.0),
        dB_III_r_IM(PARA.activeDrugs, 0.0), dB_IV_r_IM(PARA.activeDrugs, 0.0);

    double dInfec12(0.0), dInfec34(0.0), dBurst12(0.0),  dBurst34(0.0);
    double dMacro12(0.0), dMacro34(0.0), dBeKill12(0.0), dBeKill34(0.0);

    if (PARA.isImmuneKill==1) {
        dMacro12  = calcMacro(p, Mi_12, T1);            // macrophage apoptosis
        dBurst12  = calcBurst(p, Mi_12, f.B_II_tot);    // Bi to Be bursting
        dInfec12  = calcInfec(p, Mr_12, f.B_I_tot);     // Be to Bi chronic infection
        dBeKill12 = calcBeKill(p, Ma_12, Mr_12, IDC);   // Immune system killing

        if (PARA.isGranuloma==1) {
            dMacro34 = calcMacro(p, Mi_34, T1);         // macrophage apoptosis
            dBurst34 = calcBurst(p, Mi_34, f.B_IV_tot); // Bi to Be bursting
            // if no infection of macrophages in granuloma then dInfec34 = 0.0
            if (PARA.isGranulomaInfec==1) {              // macrophage infection (Be to Bi)
                dInfec34  = PARA.granulomaInfectionRate * calcInfec(p, Mr_34, f.B_III_tot);
            }
            if (PARA.isGranImmuneKill==1){
                dBeKill34 = calcBeKill(p, Ma_34, Mr_34, IDC);  // Immune system killing
            }
        }

        // allocate immune system effect on bacteria
        // non-granuloma compartment helper variables
        double dBeKill12immuneStatus = dBeKill12 * immuneStatus;
        double dBurst12dMacro12 = dBurst12 + dMacro12;
        double dBurst12dMacro12fBIIwdInfec12fBIw = dBurst12dMacro12 * f.BIIw - dInfec12 * f.BIw;

        VEC dBurst12dMacro12fBII0dInfec12fBI(PARA.activeDrugs, 0.0);
        for (int iD=0; iD<PARA.activeDrugs; iD++){
            dBurst12dMacro12fBII0dInfec12fBI[iD] = dBurst12dMacro12 * f.BIIr[iD] - dInfec12 * f.BIr[iD];
        }

        dB_I_w_IM  = x[18]  * dBeKill12immuneStatus + dBurst12dMacro12fBIIwdInfec12fBIw;
        for (int iD=0; iD<PARA.activeDrugs; iD++){
            dB_I_r_IM[iD] = xB[iD]  * dBeKill12immuneStatus + dBurst12dMacro12fBII0dInfec12fBI[iD];
        }

        dB_II_w_IM  = - dBurst12dMacro12fBIIwdInfec12fBIw;
        for (int iD=0; iD<PARA.activeDrugs; iD++){
            dB_II_r_IM[iD] = - dBurst12dMacro12fBII0dInfec12fBI[iD];
        }

        // granuloma compartment helper variables
        double dBeKill34immuneStatus = dBeKill34 * immuneStatus;
        double dBurst34dMacro34 = dBurst34 + dMacro34;
        double dBurst34dMacro34fBIVwdInfec34fBIIIw = dBurst34dMacro34 * f.BIVw - dInfec34 * f.BIIIw;

        VEC dBurst34dMacro34fBIV0dInfec34fBIII(PARA.activeDrugs, 0.0);
        for (int iD=0; iD<PARA.activeDrugs; iD++){
            dBurst34dMacro34fBIV0dInfec34fBIII[iD] = dBurst34dMacro34 * f.BIVr[iD] - dInfec34 * f.BIIIr[iD];
        }

        // bacteria gained due to bursting of macrophages in granuloma
        dB_III_w_IM = x[20] * dBeKill34immuneStatus + dBurst34dMacro34fBIVwdInfec34fBIIIw;
        for (int iD=0; iD<PARA.activeDrugs; iD++){
            dB_III_r_IM[iD] = xB[2*PARA.activeDrugs+iD] * dBeKill34immuneStatus +
                              dBurst34dMacro34fBIV0dInfec34fBIII[iD];
        }

        // bacteria lost due to bursting of macrophages in granuloma
        dB_IV_w_IM = - dBurst34dMacro34fBIVwdInfec34fBIIIw;
        for (int iD=0; iD<PARA.activeDrugs; iD++){
            dB_IV_r_IM[iD] = - dBurst34dMacro34fBIV0dInfec34fBIII[iD];
        }
    }

    // transfer immune system effects back to be used in MON array
    f.dBeKill12 = dBeKill12;
    f.dBeKill34 = dBeKill34;

    // save back results
    // macrophages
    dx[0] = dMa_12 + f.dMa_gran;    // (- dMa_12_gran + dMa_34_gran);
    dx[1] = dMr_12 + f.dMr_gran;
    dx[2] = dMi_12 + f.dMi_gran;

    dx[3] = dMa_34 - f.dMa_gran;
    dx[4] = dMr_34 - f.dMr_gran;
    dx[5] = dMi_34 - f.dMi_gran;

    // dx =           growth      killing      granuloma out   & in          immune sys   mutation
    //=============================================================================================
    // bacteria compartment I
    dx[18]  = x[18]  * (f.dB_I_w_g * f.dB_I_BaseGrowth - f.dB_I_w_k) + f.dB_31_w_gran + dB_I_w_IM + f.dB_I_w_m;
    for (int iD=0; iD<PARA.activeDrugs; iD++){
        dxB[iD] = xB[iD]  * (f.dB_I_r_g[iD] * f.dB_I_BaseGrowth - f.dB_I_r_k[iD])
                + f.dB_31_r_gran[iD] + dB_I_r_IM[iD] + f.dB_I_r_m[iD];
    }
    // bacteria compartment II
    dx[19] = x[19] * (f.dB_II_w_g * f.dB_II_BaseGrowth - f.dB_II_w_k) + f.dB_42_w_gran + dB_II_w_IM + f.dB_II_w_m;
    for (int iD=0; iD<PARA.activeDrugs; iD++){
        dxB[iD+PARA.activeDrugs] = xB[iD+PARA.activeDrugs] * (f.dB_II_r_g[iD] * f.dB_II_BaseGrowth - f.dB_II_r_k[iD])
                                   + f.dB_42_r_gran[iD] + dB_II_r_IM[iD]  + f.dB_II_r_m[iD];
    }
    // bacteria compartment III
    dx[20] = x[20] * (f.dB_III_w_g * f.dB_III_BaseGrowth - f.dB_III_w_k) - f.dB_31_w_gran + dB_III_w_IM + f.dB_III_w_m;
    for (int iD=0; iD<PARA.activeDrugs; iD++){
        dxB[iD+PARA.activeDrugs*2] = xB[iD+PARA.activeDrugs*2] * (f.dB_III_r_g[iD] * f.dB_III_BaseGrowth - f.dB_III_r_k[iD])
                                     - f.dB_31_r_gran[iD] + dB_III_r_IM[iD] +   f.dB_III_r_m[iD];
    }
    // bacteria compartment IV
    dx[21] = x[21] * (f.dB_IV_w_g * f.dB_IV_BaseGrowth - f.dB_IV_w_k) - f.dB_42_w_gran + dB_IV_w_IM + f.dB_IV_w_m;
    for (int iD=0; iD<PARA.activeDrugs; iD++){
        dxB[iD+PARA.activeDrugs*3] = xB[iD+PARA.activeDrugs*3] * (f.dB_IV_r_g[iD] * f.dB_IV_BaseGrowth - f.dB_IV_r_k[iD])
                                     - f.dB_42_r_gran[iD] + dB_IV_r_IM[iD] +  f.dB_IV_r_m[iD];
    }
    // immune system variables
    dx[6]  = dIL10; dx[7]  = dIL12L; dx[8]  = dIL4;  dx[9] = dIFN;
    dx[10] = dTp;   dx[11] = dT1;    dx[12] = dT2;  dx[13] = dIL12LN;
    dx[14] = dTLN;  dx[15] = dMDC;   dx[16] = dIDC; dx[17] = dTpLN;

    // merge dx and dxB to form return value
    for (int iD=0; iD<PARA.activeDrugs*4; iD++){
        dx[iD+nODE] = dxB[iD];
    }
    //dxTemp.assign(dx.begin(), dx.begin() + nODE);
    //dxTemp.insert(dxTemp.end(), dxB.begin(), dxB.end());
    //dx.assign(dxTemp.begin(), dxTemp.end());
}
//=========================================================================

// IFN response
double calcIFN(VEC& p, double Ma, double IL12L, double IFN, double T1, double Bt) {
    double sg  = p[20];
    double c10 = p[21];
    double s4  = p[22];
    double a5  = p[23];
    double c5  = p[24];
    double mu_IFN = p[25];

    return sg * Bt / (Bt + c10) * IL12L / (IL12L + s4) + a5 * T1 * Ma / (Ma + c5) - mu_IFN * IFN;
}
// IL12 response in Lung tissue
double calcIL12L(VEC& p, double Ma, double Mr, double IL12L) {
    double a8  = p[17];
    double a23 = p[18];
    double mu_IL12L = p[19];

    return a8 * Ma + a23 * Mr - mu_IL12L * IL12L;
}
//IL10 response
double calcIL10(VEC& p, double Ma, double Mi, double IL10,
                double IFN, double T1, double T2, double Tp) {
    double a14 = p[26];
    double s6  = p[27];
    double f6  = p[28];
    double a16 = p[29];
    double a17 = p[30];
    double a18 = p[31];
    double d7  = p[32];
    double mu_IL10 = p[33];

    return a14 * Ma * s6 / (IL10 + f6 * IFN + s6) + a16 * T1 + a17 * T2 + a18 * Tp + d7 * Mi - mu_IL10 * IL10;
}
// IL4 response
double calcIL4(VEC& p, double Tp, double T2, double IL4) {
    double a11 = p[34];
    double a12 = p[35];
    double mu_IL4 = p[36];

    return a11 * Tp + a12 * T2 - mu_IL4 * IL4;
}
// Tp response in Lung tissue
double calcTp(VEC& p, double Ma, double IL10, double IL12L, double IL4,
              double IFN, double IL12LN, double Tp, double TpLN){
    double theta = p[65];
    double d6  = p[37];
    double k6  = p[41];
    double f1  = p[42];
    double f7  = p[43];
    double s1  = p[44];
    double a2  = p[38];
    double c15 = p[39];
    double k7  = p[45];
    double f2  = p[46];
    double s2  = p[47];
    double mu_Tp = p[40];

    return theta * TpLN * Ma / (Ma + d6) - k6 * IL12L * Tp * IL12LN / (IL12LN + f1 * IL4 + f7 * IL10 + s1)
           + a2 * Tp * Ma / (Ma + c15) - k7 * Tp * IL4 / (IL4 + f2 * IFN + s2) - mu_Tp * Tp;
}
// T1 response
double calcT1(VEC& p, double IL10, double IL12L, double IL4, double T1, double IL12LN, double Tp){
    double k6 = p[41];
    double f1 = p[42];
    double f7 = p[43];
    double s1 = p[44];
    double mu_T1 = p[48];

    return k6 * IL12L * Tp * IL12LN / (IL12LN + f1 * IL4 + f7 * IL10 + s1) - mu_T1 * T1;
}
// T2 response
double calcT2(VEC& p, double IL4, double IFN, double T2, double Tp){
    double k7 = p[45];
    double f2 = p[46];
    double s2 = p[47];
    double mu_T2 = p[49];

    return k7 * Tp * IL4 / (IL4 + f2 * IFN + s2) - mu_T2 * T2;
}
// activated macrophages in Lung tissue
double calcMa(VEC& p, double Ma, double Mr, double IL10, double IL4, double IFN, double Bt){
    double k4 = p[3];
    double s8 = p[4];
    double k3 = p[7];
    double f3 = p[8];
    double s3 = p[9];
    double c8 = p[10];
    double mu_a = p[12];

    return (- k4 * Ma * IL10 / (IL10 + s8) + k3 * Mr * IFN / (IFN + f3 * IL4 + s3) * Bt / (Bt + c8) - mu_a * Ma);
}

// infected macrophages in Lung tissue
double calcMi(VEC& p, double Mr, double Mi, double T1, double Be_all, double Bi_all){
    double k17 = p[13];
    double k2  = p[5];
    double c9  = p[6];
    double k14 = p[14];
    double c4  = p[15];
    double mu_i = p[16];
    double N   = p[54];
    double NMi = N * Mi + 1e-20; // to avoid div by zero if Mi and Bi_all = 0
    double T1divMi = T1 / (Mi + 1e-20); // to avoid div by zero if Mi = 0
    double Bi_all2 = Bi_all * Bi_all;

    return (- k17 * Mi * Bi_all2 / (Bi_all2 + NMi*NMi) +
            k2 * Mr * Be_all / (Be_all + c9) - k14 * Mi * T1divMi / (T1divMi + c4) - mu_i * Mi);
}
// Mr response in Lung
double calcMr(VEC& p, double Ma, double Mr, double Mi, double IL10,
              double IFN, double IL4, double Be_all, double Bi_all){
    double Bt = Be_all + Bi_all;

    double sM = p[0];
    double a4 = p[1];
    double w  = p[2];
    double k2 = p[5];
    double c9 = p[6];
    double k4 = p[3];
    double s8 = p[4];
    double k3 = p[7];
    double f3 = p[8];
    double s3 = p[9];
    double c8 = p[10];
    double mu_r = p[11];

    return sM + a4 * (Ma + w * Mi) - k2 * Mr * Be_all / (Be_all + c9) +
           k4 * Ma * IL10 / (IL10 + s8) - k3 * Mr * IFN / (IFN + f3 * IL4 + s3) * Bt / (Bt + c8) - mu_r * Mr;
}
// IL12 in Lymph tissue
double calcIL12LN(VEC& p, double IL12LN, double MDC){
    double d1 = p[56];
    double mu_IL12LN = p[57];

    return d1 * MDC - mu_IL12LN * IL12LN;
}
// TLN response
double calcTLN(VEC& p, double TLN, double MDC){
    double sT = p[58];
    double d2 = p[59];
    double lambda1 = p[60];
    double d4 = p[62];
    double mu_TLN = p[61];

    return sT + d2 * MDC - lambda1 * TLN - d4 * TLN * MDC - mu_TLN * TLN;
}
// TpLN response in Lymph tissue
double calcTpLN(VEC& p, double TLN, double MDC, double TpLN){
    double d4  = p[62];
    double d5  = p[63];
    double rho = p[64];
    double theta = p[65];

    return d4 * TLN * MDC + d5 * TpLN * (1.0 - TpLN / rho) - theta * TpLN;
}
// MDC response
double calcMDC(VEC& p, double MDC, double IDC, double Be_all){
    double scale = p[66];
    double d10 = p[72];
    double d11 = p[73];
    double mu_MDC = p[67];

    return scale * d10 * IDC * Be_all / (Be_all + d11) - mu_MDC * MDC;
}
// IDC response
double calcIDC(VEC& p, double IDC, double Be_all){
    double sIDC = p[69];
    double d8  = p[70];
    double d9  = p[71];
    double d10 = p[72];
    double d11 = p[73];
    double mu_IDC = p[74];

    return sIDC + d8 * IDC * Be_all / (Be_all + d9) - d10 * IDC * Be_all / (Be_all + d11) - mu_IDC * IDC;
}
// growth of intracellular bacteria without impact of drugs or resistance
double calcBaseBiGrowth(VEC& p, double Mi, double Bi_all){
    double a19 = p[53];
    double N = p[54];
    double Bi_all2 = Bi_all * Bi_all + 1e-20; // to avoid div by zero

    return a19 * (1.0 - Bi_all2 / (Bi_all2 + N * N * Mi * Mi));
}
// growth of extracellular bacteria without impact of drugs or resistance
double calcBaseBeGrowth(VEC& p, double Be_all){
    double a20 = p[50];
    double Bemax = p[75];

    return a20 * (1.0 - Be_all / Bemax);
}
//
double calcMacro(VEC& p, double Mi, double T1 ){
    double k14 = p[14];
    double c4  = p[15];
    double Ni  = p[55];
    double T1divMi = T1 / (Mi + 1e-20); // to avoid div by zero if Mi = 0

    return k14 * Ni * Mi * T1divMi / (T1divMi + c4);
}
//
double calcBurst(VEC& p, double Mi, double Bi_tot ){
    double k17 = p[13];
    double N = p[54];
    double Bi_all2 = Bi_tot * Bi_tot;
    double NMi = N * Mi + 1e-20; // to avoid div by zero if Mi=0

    return k17 * NMi * Bi_all2 / (Bi_all2 + NMi * NMi);
}
//
double calcInfec(VEC& p, double Mr, double Be_tot ){
    double N  = p[54];
    double k2 = p[5];
    double c9 = p[6];

    return N * 0.5 * k2 * Mr * Be_tot / (Be_tot + c9);
}
//
double calcBeKill(VEC& p, double Ma, double Mr, double IDC ){
    double k15 = p[51];
    double d12 = p[68];
    double k18 = p[52];

    return -k18 * Mr - k15 * Ma - d12 * IDC;
}
// get macrophage values for use in local variables
void getMacrophageData(VEC& x, double& Ma_12, double& Mr_12, double& Mi_12,
                       double& Ma_34, double& Mr_34, double& Mi_34) {
    Ma_12 = x[0];    // compartments I and II (extra granuloma)
    Mr_12 = x[1];
    Mi_12 = x[2];

    Ma_34 = x[3];    // compartments II and IV (intra granuloma)
    Mr_34 = x[4];
    Mi_34 = x[5];
}
// get immune system data for use in local variables
void getImmuneData(VEC& x, double& IL10, double& IL12L, double& IL4, double& IFN,
                   double& Tp, double& T1, double& T2, double& IL12LN, double& TLN,
                   double& MDC, double& IDC, double& TpLN){
    IL10   = x[6];   // across all compartments
    IL12L  = x[7];
    IL4    = x[8];
    IFN    = x[9];
    Tp     = x[10];
    T1     = x[11];
    T2     = x[12];
    IL12LN = x[13];
    TLN    = x[14];
    MDC    = x[15];
    IDC    = x[16];
    TpLN   = x[17];
}


