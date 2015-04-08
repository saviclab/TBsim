#include <vector>

#include "ODEclass.h"

//=================================================================
// FUNCTION: setInitialValues
// set ODE variable input values
// first set default values
// note that bacterial start values set in "createInfection.cpp"
//=================================================================
void ODEclass::setInitialValues(){
    nODE = 22;
    xi.assign(nODE, 0.0);

    xi[0]  = 0.0;            // Ma12
    xi[1]  = 5e5;            // Mr12
    xi[2]  = 0.0;            // Mi12
    xi[3]  = 0.0;            // Ma34
    xi[4]  = 0.0;            // Mr34
    xi[5]  = 0.0;            // Mi34

    xi[6] = 0.0;            // IL10
    xi[7] = 0.0;            // IL12L
    xi[8] = 0.0;            // IL4
    xi[9] = 0.0;            // IFN
    xi[10] = 0.0 ;           // Tp
    xi[11] = 0.0;            // T1
    xi[12] = 0.0;            // T2
    xi[13] = 0.0;            // IL12LN
    xi[14] = 4e3;            // TLN
    xi[15] = 0.0;            // MDC
    xi[16] = 5e4;            // IDC
    xi[17] = 0.0;            // TpLN
}

//=================================================================
// Name   : createInfection
// Purpose: set starting population of bacteria per compartment,
//          defined as colony forming units per mL
// Methods: amount of resistant bacteria set as fixed proportion
//          of wild type based on factor PARA.resistanceRatio
//=================================================================
void ODEclass::createInfection(double infI, double infII, double infIII, double infIV)
{
    // set wild-type bacteria starting population
    //compartment I
    xi[18]  = infI;
    //compartment II
    xi[19]  = infII;
    //compartment III
    xi[20]  = infIII;
    //compartment IV
    xi[21]  = infIV;
}

void ODEclass::createResistanceStart(int activeDrugs, double resistanceRatio)
{
    xBi.assign(activeDrugs*4, 0.0);
    for (int i=0; i<activeDrugs; i++){
        xBi[i]               = xi[18] * resistanceRatio;
        xBi[i+activeDrugs]   = xi[19] * resistanceRatio;
        xBi[i+activeDrugs*2] = xi[20] * resistanceRatio;
        xBi[i+activeDrugs*3] = xi[21] * resistanceRatio;
    }
}

VEC ODEclass::getxi(){
    return xi;
}

VEC ODEclass::getxBi(){
    return xBi;
}
int ODEclass::getnODE(){
    return nODE;
}
