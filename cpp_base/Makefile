# make file for TB simulation program
# primarily created for QS3 deployment
# update the parameters to fit specific compute platform used
#
# $(CXX) compiler
# John Fors, UCSF
# December 9, 2014
# scl enable devtoolset-2 bash
CXX ?= g++
CXXFLAGS = -fexceptions -O3 -std=c++11 -I./inc -m64 -mmmx -msse -msse2
# on Mac, "-fopenmp" not available in Clang compiler, but available on Linux:
ifeq ($(UNAME), Linux)
  CXXFLAGS = -fexceptions -O3 -std=c++11 -fopenmp -I./inc -m64 -mmmx -msse -msse2
endif

ODIR = ./obj
SDIR = ./src
IDIR = ./inc

TBsim : $(ODIR)/main.o \
        $(ODIR)/ADHclass.o \
        $(ODIR)/CONCclass.o \
        $(ODIR)/DOSEclass.o \
        $(ODIR)/DRUGclass.o \
        $(ODIR)/DRUGLISTclass.o \
        $(ODIR)/dxTB.o \
        $(ODIR)/GRANclass.o \
        $(ODIR)/IMMUNEclass.o \
        $(ODIR)/MONITORclass.o \
        $(ODIR)/ODEclass.o \
        $(ODIR)/OUTCOMEclass.o \
        $(ODIR)/PARAMclass.o \
        $(ODIR)/POPULATIONclass.o \
        $(ODIR)/printFunctions.o \
        $(ODIR)/rungeKutta.o \
        $(ODIR)/SOLUTIONclass.o \
        $(ODIR)/statFunctions.o \
        $(ODIR)/TIMERclass.o \
        $(ODIR)/writeFunctions.o
	echo Linking TBsim
	$(CXX) -o TBsim $(CXXFLAGS) \
                 $(ODIR)/main.o \
                 $(ODIR)/ADHclass.o \
                 $(ODIR)/CONCclass.o \
                 $(ODIR)/DOSEclass.o \
                 $(ODIR)/DRUGclass.o \
                 $(ODIR)/DRUGLISTclass.o \
                 $(ODIR)/dxTB.o \
                 $(ODIR)/GRANclass.o \
                 $(ODIR)/IMMUNEclass.o \
                 $(ODIR)/MONITORclass.o \
                 $(ODIR)/ODEclass.o \
                 $(ODIR)/OUTCOMEclass.o \
                 $(ODIR)/PARAMclass.o \
                 $(ODIR)/POPULATIONclass.o \
                 $(ODIR)/printFunctions.o \
                 $(ODIR)/rungeKutta.o \
                 $(ODIR)/SOLUTIONclass.o \
                 $(ODIR)/statFunctions.o \
                 $(ODIR)/TIMERclass.o \
                 $(ODIR)/writeFunctions.o
Debug: TBsim

$(ODIR)/main.o : $(SDIR)/main.cpp \
                 $(IDIR)/ADHclass.h \
                 $(IDIR)/CONCclass.h \
                 $(IDIR)/DOSEclass.h \
                 $(IDIR)/DRUGclass.h \
                 $(IDIR)/DRUGLISTclass.h \
                 $(IDIR)/Global.h \
                 $(IDIR)/GRANclass.h \
                 $(IDIR)/IMMUNEclass.h \
                 $(IDIR)/MONITORclass.h \
                 $(IDIR)/ODEclass.h \
                 $(IDIR)/OUTCOMEclass.h \
                 $(IDIR)/PARAMclass.h \
                 $(IDIR)/POPULATIONclass.h \
                 $(IDIR)/printFunctions.h \
                 $(IDIR)/SOLUTIONclass.h \
                 $(IDIR)/TIMERclass.h \
                 $(IDIR)/writeFunctions.h
	echo Compiling main.cpp
	$(CXX) -o $(ODIR)/main.o -c $(SDIR)/main.cpp $(CXXFLAGS)

$(ODIR)/ADHclass.o : $(SDIR)/ADHclass.cpp \
                     $(IDIR)/ADHclass.h \
                     $(IDIR)/statFunctions.h
	echo Compiling ADHclass.cpp
	$(CXX) -o $(ODIR)/ADHclass.o -c $(SDIR)/ADHclass.cpp $(CXXFLAGS)

$(ODIR)/CONCclass.o : $(SDIR)/CONCclass.cpp \
                      $(IDIR)/CONCclass.h \
                      $(IDIR)/statFunctions.h
	echo Compiling CONCclass.cpp
	$(CXX) -o $(ODIR)/CONCclass.o -c $(SDIR)/CONCclass.cpp $(CXXFLAGS)

$(ODIR)/DOSEclass.o : $(SDIR)/DOSEclass.cpp \
                      $(IDIR)/DOSEclass.h \
                      $(IDIR)/Global.h \
                      $(IDIR)/statFunctions.h
	echo Compiling DOSEclass.cpp
	$(CXX) -o $(ODIR)/DOSEclass.o -c $(SDIR)/DOSEclass.cpp $(CXXFLAGS)

$(ODIR)/DRUGclass.o : $(SDIR)/DRUGclass.cpp $(IDIR)/DRUGclass.h
	echo Compiling DRUGclass.cpp
	$(CXX) -o $(ODIR)/DRUGclass.o -c $(SDIR)/DRUGclass.cpp $(CXXFLAGS)

$(ODIR)/DRUGLISTclass.o : $(SDIR)/DRUGLISTclass.cpp \
                          $(IDIR)/DRUGLISTclass.h \
                          $(IDIR)/printFunctions.h
	echo Compiling DRUGLISTclass.cpp
	$(CXX) -o $(ODIR)/DRUGLISTclass.o -c $(SDIR)/DRUGLISTclass.cpp $(CXXFLAGS)

$(ODIR)/dxTB.o : $(SDIR)/dxTB.cpp $(IDIR)/dxTB.h
	echo Compiling dxTB.cpp
	$(CXX) -o $(ODIR)/dxTB.o -c $(SDIR)/dxTB.cpp $(CXXFLAGS)

$(ODIR)/GRANclass.o : $(SDIR)/GRANclass.cpp $(IDIR)/GRANclass.h
	echo Compiling GRANclass.cpp
	$(CXX) -o $(ODIR)/GRANclass.o -c $(SDIR)/GRANclass.cpp $(CXXFLAGS)

$(ODIR)/IMMUNEclass.o : $(SDIR)/IMMUNEclass.cpp \
                        $(IDIR)/IMMUNEclass.h \
                        $(IDIR)/statFunctions.h
	echo Compiling IMMUNEclass.cpp
	$(CXX) -o $(ODIR)/IMMUNEclass.o -c $(SDIR)/IMMUNEclass.cpp $(CXXFLAGS)

$(ODIR)/MONITORclass.o : $(SDIR)/MONITORclass.cpp \
                         $(IDIR)/MONITORclass.h \
                         $(IDIR)/statFunctions.h
	echo Compiling MONITORclass.cpp
	$(CXX) -o $(ODIR)/MONITORclass.o -c $(SDIR)/MONITORclass.cpp $(CXXFLAGS)

$(ODIR)/ODEclass.o : $(SDIR)/ODEclass.cpp $(IDIR)/ODEclass.h
	echo Compiling ODEclass.cpp
	$(CXX) -o $(ODIR)/ODEclass.o -c $(SDIR)/ODEclass.cpp $(CXXFLAGS)

$(ODIR)/OUTCOMEclass.o : $(SDIR)/OUTCOMEclass.cpp $(IDIR)/OUTCOMEclass.h
	echo Compiling OUTCOMEclass.cpp
	$(CXX) -o $(ODIR)/OUTCOMEclass.o -c $(SDIR)/OUTCOMEclass.cpp $(CXXFLAGS)

$(ODIR)/PARAMclass.o : $(SDIR)/PARAMclass.cpp $(IDIR)/printFunctions.h
	echo Compiling PARAMclass.cpp
	$(CXX) -o $(ODIR)/PARAMclass.o -c $(SDIR)/PARAMclass.cpp $(CXXFLAGS)

$(ODIR)/SOLUTIONclass.o : $(SDIR)/SOLUTIONclass.cpp \
                          $(IDIR)/SOLUTIONclass.h \
                          $(IDIR)/statFunctions.h \
                          $(IDIR)/rungeKutta.h
	echo Compiling SOLUTIONclass.cpp
	$(CXX) -o $(ODIR)/SOLUTIONclass.o -c $(SDIR)/SOLUTIONclass.cpp $(CXXFLAGS)

$(ODIR)/POPULATIONclass.o : $(SDIR)/POPULATIONclass.cpp \
                            $(IDIR)/POPULATIONclass.h \
                            $(IDIR)/statFunctions.h
	echo Compiling POPULATIONclass.cpp
	$(CXX) -o $(ODIR)/POPULATIONclass.o -c $(SDIR)/POPULATIONclass.cpp $(CXXFLAGS)

$(ODIR)/printFunctions.o : $(SDIR)/printFunctions.cpp $(IDIR)/printFunctions.h
	echo Compiling printFunctions.cpp
	$(CXX) -o $(ODIR)/printFunctions.o -c $(SDIR)/printFunctions.cpp $(CXXFLAGS)

$(ODIR)/rungeKutta.o : $(SDIR)/rungeKutta.cpp $(IDIR)/rungeKutta.h $(IDIR)/dxTB.h
	echo Compiling rungeKutta.cpp
	$(CXX) -o $(ODIR)/rungeKutta.o -c $(SDIR)/rungeKutta.cpp $(CXXFLAGS)

$(ODIR)/statFunctions.o : $(SDIR)/statFunctions.cpp $(IDIR)/statFunctions.h
	echo Compiling statFunctions.cpp
	$(CXX) -o $(ODIR)/statFunctions.o -c $(SDIR)/statFunctions.cpp $(CXXFLAGS)

$(ODIR)/TIMERclass.o : $(SDIR)/TIMERclass.cpp $(IDIR)/TIMERclass.h
	echo Compiling TIMERclass.cpp
	$(CXX) -o $(ODIR)/TIMERclass.o -c $(SDIR)/TIMERclass.cpp $(CXXFLAGS)

$(ODIR)/writeFunctions.o : $(SDIR)/writeFunctions.cpp $(IDIR)/writeFunctions.h $(IDIR)/printFunctions.h
	echo Compiling writeFunctions.cpp
	$(CXX) -o $(ODIR)/writeFunctions.o -c $(SDIR)/writeFunctions.cpp $(CXXFLAGS)

clean:
	$(RM) TBsim ; $(RM) obj/*.o

