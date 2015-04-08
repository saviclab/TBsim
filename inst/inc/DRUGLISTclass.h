#ifndef DRUGLISTCLASS_H
#define DRUGLISTCLASS_H

#include <string>
#include <vector>

#include "Global.h"
#include "PARAMclass.h"
#include "DRUGclass.h"

class DRUGLISTclass {
public:
    bool initialize(int, const std::string&, VECS&);
    void printDrugList(int, VECI&, VECS&);
    void selectActiveDrugs(PARAMclass&);
    VEC2 setDoseFullAdherence(PARAMclass&);
    bool checkDrugStop(PARAMclass&);
    int getDrugStart();
    int getDrugStart(int);
    int getDrugStop();

    DRUGclass get(int);

private:
    int nDrugs;
    int activeDrugs;
    int nTime;

    std::vector<DRUGclass> DRUGLIST;
    VEC2 doseFullAdherence;    // dose independent of adherence
};

#endif // DRUGLISTCLASS_H

