#ifndef WRITEFUNCTIONS_H
#define WRITEFUNCTIONS_H

#include <string>
#include <vector>

#include "Global.h"
#include "PARAMclass.h"
#include "CONCclass.h"
#include "ADHclass.h"
#include "SOLUTIONclass.h"

void writeResults(const std::string&, PARAMclass&, VEC4&, VEC4&, VEC4&, VEC4&, VEC4&,
                  VEC4&, VEC4&, VEC4&, VEC4&, VEC4&, VEC4&);

void writeVector(VEC4&, std::string&, std::string&, std::string&,
                 std::vector<std::string>&, std::vector<std::string>&,
                 int, int, int, int, int, int);

void writeFile (const std::string&, VEC&, int, int, unsigned int, const std::string&, const std::string&);

void writeFileInc (int, const std::string&, VEC&, int, int, const std::string&, const std::string&);

void writeFileIncV (int, const std::string&, VEC, int, int, const std::string&, const std::string&);

void writeFileIncData (const std::string&, const std::string&, const std::string&, VEC, int, int);

void writeDataFileHeader(const std::string&, const std::string&, const std::string&);

void writeHeader (const std::string&, const std::string&, PARAMclass&, const std::string&);

void writeDetails(int, PARAMclass&, SOLUTIONclass&, CONCclass&, ADHclass&, const std::string&);

int getConcStart(int, VEC&);

#endif // WRITEFUNCTIONS_H
