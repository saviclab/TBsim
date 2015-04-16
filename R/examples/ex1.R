# setwd("~/git/TBsim")

## Compilation
## On Mac, make sure not to use the Clang compiler but the GNU g++ compiler
tb_compile(cpp = "/opt/local/bin/g++")

## read in templates and define some constants
therapy       <- tb_read_init("standardTB4.txt")
adherence     <- tb_read_init("adh2.txt")
EMB          <- tb_read_init("EMB.txt")
RIF          <- tb_read_init("RIF.txt")
INH          <- tb_read_init("INH.txt")
PZA          <- tb_read_init("PZA.txt")
tb_write_init(obj = therapy, file = "test.txt", folder="~/tb_run")

## create a new simulation definition, and make a few changes
sim1 <- tb_new_sim(therapy = therapy,
                   adherence = adherence,
                   drug = list("EMB" = EMB,
                               "RIF" = RIF,
                               "INH" = INH,
                               "PZA" = PZA),
                   nPatients = 300,
                   therapyStart = 180)

## simulate
sim <- tb_run_sim (sim1)

## Make some plots

