#ifndef PRINTFUNCTIONS_H
#define PRINTFUNCTIONS_H

#include <string>
#include <list>

void setWindow();

std::string printModel(int);

std::string printYesNo(int);

void printGreeting(const std::string&);

void printLine();

int getUserInput(std::list<int>&);

#endif // PRINTFUNCTIONS_H
