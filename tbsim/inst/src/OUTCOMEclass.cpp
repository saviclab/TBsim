#include <vector>

#include "OUTCOMEclass.h"

using namespace std;

void OUTCOMEclass::initialize(int nT, int nO)
{
    nTime = nT;
    nOutcome = nO; // number of outcome states
                  // 0=NoTB, 1=AcuteTB, 2=LatentTB, 3=ClearedTB

    VEC temp(nTime, 0.0);
    outcome.assign(nOutcome, temp);

    temp.clear();
}

void OUTCOMEclass::setOutcome(int isGranuloma, double freeBactLevel, double latentBactLevel, VEC3& B)
{
    for (int iT=0; iT<nTime; iT++) {
        double B_12 = B[1][0][iT] + B[1][1][iT];
        if (isGranuloma==0){
            // patientStatus = 0 for Non-infected patients
            if (B_12==0.0) {
                outcome[0][iT]++;         // No TB
            }
            // over free limit outside
            else if (B_12>freeBactLevel){
                outcome[1][iT]++;      // Acute TB
            }
            // under free limit outside
            else {
                outcome[3][iT]++;    // Cleared TB
            }
        }
        else {
            double B_34 = B[1][2][iT] + B[1][3][iT];
            double Btot = B_12 + B_34;
            // patientStatus = 0 for Non-infected patients
            if (Btot==0.0) {
                outcome[0][iT]++;         // No TB
            }
            // over free limit outside
            else if (B_12>freeBactLevel){
                outcome[1][iT]++;      // Acute TB
            }
            // under free limit outside AND under free limit inside
            else if (B_34<freeBactLevel) {
                outcome[3][iT]++;    // Cleared TB
            }
            // under free limit outside AND under latent limit inside AND over free limit inside
            else if (B_34<latentBactLevel) {
                outcome[2][iT]++;     // Latent TB
            }
            // under free limit outside AND over latent limit inside granuloma
            else {
                outcome[1][iT]++;      // Acute TB
            }
        }
    }
}




