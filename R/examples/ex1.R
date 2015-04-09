setwd("~/git/TBsim")

# compile
tb_compile(cpp = "/usr/local/bin/g++")

# simulate
sim <- tb_sim ("RPT")
