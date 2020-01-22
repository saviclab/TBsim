#include <iostream>
#include <algorithm>
//#include <windows.h>

#include "printFunctions.h"


//=================================================================
// Top-level prompt & input at run time
//=================================================================
int getUserInput(std::list<int>& validInputs)
{
    int inputValue(0);

    std::cout << "0. Run,   1. Simulation, 2. Adherence, 3. Infection, 4. Immune," << std::endl;
    std::cout << "5. Drugs, 6. Granuloma,  7. Model,     8. Save data, 9. Exit"    << std::endl;
    std::cout << ": ";
    do {
        std::cin >> inputValue;
    } while (std::count (validInputs.begin(), validInputs.end(), inputValue) < 1);
    return inputValue;
}
//=================================================================
// Print program start up greeting
//=================================================================
void printGreeting(const std::string& version){
    printLine();
    std::cout << "Tuberculosis Simulation " << std::endl;
    std::cout << "UCSF" << std::endl;
    std::cout << "Version "<<version<< std::endl;
}

std::string printModel(int disease)
{
    if (disease == 1)
        return "Acute TB (K)"; // Kirschner
    else if (disease == 2)
        return "Latent TB (K)"; // Kirschner
    else if (disease == 3)
        return "PPP+ clearance (K)"; // Kirschner
    else if (disease == 4)
        return "Reactivation (K)"; // Kirschner
    else if (disease == 5)
        return "Acute TB (G)"; // Goutelle
    else if (disease == 6)
        return "Latent TB (G)"; // Goutelle
    else
        return "Error";
}

std::string printYesNo(int x)
{
    std::string c;
    if (x==1)
        c = "Yes";
    else
        c = "No";
    return c;
}

void printLine()
{
    std::cout << "==============================================================="<< std::endl;
}

//void setWindow()
//{
//    SetConsoleTitle("TB Simulation - UCSF");
//    HWND consoleWindow = GetConsoleWindow();
//    SetWindowPos(consoleWindow, 0, 10, 10, 0, 500, SWP_NOSIZE | SWP_NOZORDER );
//}



