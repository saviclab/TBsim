# TB platform

## Background
This library is a wrapper around the TBsim tool developed by John Fors at UCSF. The aim of the library is to provide a scriptable interface to this tool and relieve the user of the need to manually write the configuration files and command line specifications. It also provides R plots to evaluate output and generate tables of results. 

## Installation

The installation assumes the user is working on Mac OS X. For use on Windows, possibly some alterations to the makefile have to be made.

The R libary needs to be installed from BitBucket. First make sure your ssh key is put into the `ucsf_ip` account at BitBucket. Then, in R run:

    install.packages("devtools")
    library(devtools)
    install_bb("ucsf_ip/bb")

The C++ compiler provided with OSX (Clang) is unfortunately not working with the TBsim toolkit, so the GNU C++ compiler needs to be installed.

    brew install gcc

Brew might complain that gcc libraries cannot be linked. If so, run the following:
    
    brew link gcc
   
It will then complain about a particular folder not being accessible. Change the permissions for that folder to e.g. 777:

    chmod 777 /usr/local/bin
    
Then repeat the last two commands until the link succeeds.

Finally, you should be able to run:

    library(TBsim)
    tb_compile()

This compiles the executable for TBsim, which is used subsequently. If you make changes to the C++ sourcecode, you should rerun this command e.g.:

    tb_compile()

This should create the file `TBsim`, which is the main executable. In the R package, a function is included to compile (`compile_tb()`) which does the same. 

## 
