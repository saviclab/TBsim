setwd("~/git/TBsim")

## Compilation
## On Mac, make sure not to use the Clang compiler but the GNU g++ compiler
tb_compile(cpp = "/opt/local/bin/g++")

## simulate
sim <- tb_sim ("TBinit")
