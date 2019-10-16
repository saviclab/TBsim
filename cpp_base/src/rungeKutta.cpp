#include "rungeKutta.h"
#include "dxTB.h"

//=================================================================
// FUNCTION: calcTB
// Runge-Kutta approximation for ODE functions in time point t
//=================================================================

void calcTB(double ti, double tf, VEC& xi, VEC& xf, int nODEtot,
            VEC& p, double immuneStatus, PARAMclass& PARA, Factors& f)
{
    double h(tf-ti);
    double t(ti);
    VEC x(nODEtot,  0.0);
    VEC dx(nODEtot, 0.0);
    VEC k1(nODEtot, 0.0);
    VEC k2(nODEtot, 0.0);
    VEC k3(nODEtot, 0.0);
    VEC k4(nODEtot, 0.0);

    int j;
    const double third(1.0/3.0), sixth (1.0/6.0), half (1.0/2.0);

    dxTB(t, xi, dx, p, immuneStatus, PARA, f);          //k1
    for (j=0; j<nODEtot; j++) {
        k1[j] = h*dx[j];
        x[j]  = xi[j] + half * k1[j];
    }

    dxTB(t+half*h, x, dx, p, immuneStatus, PARA, f);     //k2
    for (j=0; j<nODEtot; j++) {
        k2[j] = h*dx[j];
        x[j]  = xi[j] + half * k2[j];
    }

    dxTB(t+half*h, x, dx, p, immuneStatus, PARA, f);     //k3
    for (j=0; j<nODEtot; j++) {
        k3[j] = h*dx[j];
        x[j]  = xi[j] + k3[j];
    }

    dxTB(t+h, x, dx, p, immuneStatus, PARA, f);         //k4 and result
    for (j=0; j<nODEtot; j++) {
        k4[j] = h*dx[j];
        xf[j] = xi[j] + sixth * k1[j] + third * k2[j] + third * k3[j] + sixth * k4[j];
    }
}
