setwd("~/git/TBsim")

## Compilation
## On Mac, make sure not to use the Clang compiler but the GNU g++ compiler
tb_compile(cpp = "/opt/local/bin/g++")

## Reading parameter files and making changes
RPT <- tb_read_init("RPT.txt")
RPT$KeMult <- 5
tb_write_init(RPT, file="RPTx.txt")

## create a new simulation definition, and make a few changes
sim1 <- tb_new_sim()
# ,
#                    therapy = ,
#                    adherence = "",
#                    drug = ,
#                    patients = ,
#                    n_days = ,
#                    n_populations = ,
#                    n_iter = )

## simulate
sim <- tb_run_sim (sim1)
