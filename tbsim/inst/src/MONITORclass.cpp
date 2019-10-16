#include <vector>
#include <algorithm>

#include "MONITORclass.h"
#include "statFunctions.h"

void MONITORclass::initialize(int nD, int nT, int nS, int nC)
{
    nTime = nT;
    nSteps = nS;
    nComp = nC;
    activeDrugs = nD;

    VEC tempS(nSteps, 0.0);
    VEC tempT(nTime, 0.0);
    VEC2 tempCS (nComp, tempS);
    VEC2 tempCT (nComp, tempT);

    monitor.assign(activeDrugs+2, tempCS);
    monitorDaily.assign(activeDrugs+2, tempCT);

    tempS.clear();  tempT.clear();
    tempCS.clear(); tempCT.clear();
}

void MONITORclass::setMonitor(int iD, int iC, int iS, double x)
{
    monitor[iD][iC][iS] = x;
}

void MONITORclass::update(int iC, int iIndex, VEC& k, double w, VEC& Br)
{
    double temp;
    for (int iD=0; iD<activeDrugs; iD++){
        temp = w;
        for (int jD=0; jD<activeDrugs; jD++){
            if (iD!=jD){
                temp += Br[jD];
            }
        }
        temp *= k[iD];
        monitor[iD][iC][iIndex] = temp;
    }
}

// aggregate data from hourly to weekly
void MONITORclass::aggregate(int iC, double gran)
{
    // adjust for granuloma effect - only applied to drug entries
    // done at this summary level rather than at each iteration to save cycles
    for (int iD=0; iD<activeDrugs; iD++){
        for (int iN=0; iN<nSteps; iN++){
            monitor[iD][iC][iN] = gran * monitor[iD][iC][iN];
        }
    }
    // aggregate from hours to daily totals
    // note: index goes to +1 to cover also immune-related
    for (int iD=0; iD<activeDrugs+1; iD++){
        for (int iT=0; iT<nTime; iT++){
            int istart = iT * 24;
            int istop  = istart + 24 - 1;
            monitorDaily[iD][iC][iT] = sumVec(monitor[iD][iC], istart, istop);
        }
    }

    // make share metric for each drug and for immune system
    double temp(0.0);
    const double lambda(1e-20); // to avoid div by zero
    for (int iT=0; iT<nTime; iT++){
        temp = 0.0;
        // calculate totals for each time point
        // iterate all drugs + immune system
        for (int iD=0; iD<activeDrugs+1; iD++){
                temp += monitorDaily[iD][iC][iT];
            }
        // save totals
        monitorDaily[activeDrugs+1][iC][iT] = temp;

        // check if below threshold
        if (temp<lambda) {
            // set to zero
            for (int iD=0; iD<activeDrugs+1; iD++){
                monitorDaily[iD][iC][iT] = 0.0;
            }
        }
        else {
            // calculate ratios
            double divTemp = 1.0 / temp;
            for (int iD=0; iD<activeDrugs+1; iD++){
                monitorDaily[iD][iC][iT] = monitorDaily[iD][iC][iT] * divTemp;
            }
        }
    }
}

void MONITORclass::finalize(double granulomaKill, VEC3& B)
{
    aggregate(0, 1.0);
    aggregate(1, 1.0);
    aggregate(2, granulomaKill);
    aggregate(3, granulomaKill);

    // differential per day for total bacterial growth & killing, per compartment I to IV
    // filter away growth to show ONLY decline in bacterial population
    int iM = activeDrugs+1;    // index for 'total effect' data
    int iB = 1;                // index for total bacteria value
    for (int iC=0; iC<nComp; iC++){
        for (int iT=0;iT<nTime-1; iT++){
            monitorDaily[iM][iC][iT] = -std::min(0.0, B[iB][iC][iT+1] - B[iB][iC][iT]);
        }
    }
}
