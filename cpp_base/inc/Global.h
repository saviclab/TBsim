#ifndef GLOBAL_H
#define GLOBAL_H

#include <string>
#include <vector>

typedef std::vector<double> VEC;
typedef std::vector<VEC> VEC2;
typedef std::vector<VEC2> VEC3;
typedef std::vector<VEC3> VEC4;
typedef std::vector<VEC4> VEC5;
typedef std::vector<unsigned int> VECI;
typedef std::vector<VECI> VEC2I;
typedef std::vector<std::string> VECS;

struct Factors
{
    double dB_I_w_k, dB_II_w_k, dB_III_w_k, dB_IV_w_k;
    VEC    dB_I_r_k, dB_II_r_k, dB_III_r_k, dB_IV_r_k;

    double dB_I_w_g, dB_II_w_g, dB_III_w_g, dB_IV_w_g;
    VEC    dB_I_r_g, dB_II_r_g, dB_III_r_g, dB_IV_r_g;

    double dB_I_w_m, dB_II_w_m, dB_III_w_m, dB_IV_w_m;
    VEC    dB_I_r_m, dB_II_r_m, dB_III_r_m, dB_IV_r_m;

    double B_I_tot, B_II_tot, B_III_tot, B_IV_tot;
    double B_12_tot, B_34_tot, B_tot;
    double BIw, BIIw, BIIIw, BIVw;
    VEC    BIr, BIIr, BIIIr, BIVr;
    double dMa_gran, dMr_gran, dMi_gran;

    double dB_31_w_gran, dB_42_w_gran;
    VEC    dB_31_r_gran, dB_42_r_gran;

    double dB_I_BaseGrowth, dB_II_BaseGrowth, dB_III_BaseGrowth, dB_IV_BaseGrowth;
    double dBeKill12, dBeKill34;

    Factors (int nDrugs):
        dB_I_w_k(0.0),  dB_II_w_k(0.0), dB_III_w_k(0.0), dB_IV_w_k(0.0),
        dB_I_r_k(nDrugs, 0.0), dB_II_r_k(nDrugs, 0.0), dB_III_r_k(nDrugs, 0.0), dB_IV_r_k(nDrugs, 0.0),

        dB_I_w_g(0.0),   dB_II_w_g(0.0),   dB_III_w_g(0.0),   dB_IV_w_g(0.0),
        dB_I_r_g(nDrugs, 0.0), dB_II_r_g(nDrugs, 0.0), dB_III_r_g(nDrugs, 0.0), dB_IV_r_g(nDrugs, 0.0),

        dB_I_w_m(0.0),   dB_II_w_m(0.0),   dB_III_w_m(0.0),  dB_IV_w_m(0.0),
        dB_I_r_m(nDrugs, 0.0), dB_II_r_m(nDrugs, 0.0), dB_III_r_m(nDrugs, 0.0), dB_IV_r_m(nDrugs, 0.0),

        B_I_tot(0.0),  B_II_tot(0.0), B_III_tot(0.0), B_IV_tot(0.0),
        B_12_tot(0.0), B_34_tot(0.0), B_tot(0.0),

        BIw(0.0), BIIw(0.0), BIIIw(0.0), BIVw(0.0),
        BIr(nDrugs, 0.0), BIIr(nDrugs, 0.0), BIIIr(nDrugs, 0.0), BIVr(nDrugs, 0.0),

        dMa_gran(0.0), dMr_gran(0.0), dMi_gran(0.0),

        dB_31_w_gran(0.0), dB_42_w_gran(0.0),
        dB_31_r_gran(nDrugs, 0.0), dB_42_r_gran(nDrugs, 0.0),

        dB_I_BaseGrowth(0.0), dB_II_BaseGrowth(0.0), dB_III_BaseGrowth(0.0), dB_IV_BaseGrowth(0.0),
        dBeKill12(0.0), dBeKill34(0.0)
    {}
};

#endif // GLOBAL_H
