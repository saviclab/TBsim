# setwd("~/git/TBsim")

## Compilation
## On Mac, make sure not to use the Clang compiler but the GNU g++ compiler
tb_compile(cpp = "/usr/local/bin/g++")

## read in templates and define some constants
therapy       <- tb_read_init("standardTB4.txt")
adherence     <- tb_read_init("adh2.txt")
drugs <- list(
  EMB = tb_read_init("EMB.txt"),
  RIF = tb_read_init("RIF.txt"),
  INH = tb_read_init("INH.txt"),
  PZA = tb_read_init("PZA.txt")
)

## create a new simulation definition, and make a few changes
sim1 <- tb_new_sim(therapy = therapy,
                   adherence = adherence,
                   drug = drugs,
                   nPatients = 300,
                   therapyStart = 180,
                   isSaveBactRes = 1,
                   isSaveBact = 1)

## Start the simulation based on the given definitions
tb_run_sim (sim1)

## Read in the output data
info <- tb_read_headerfile("~/tb_run")

## Plot outcome data
outc <- tb_read_outcome("~/tb_run/output", "outcome.txt")
tb_plot_outcome(info, outc)

## Plot bacterial data
bact <- tb_read_bact_totals("~/tb_run/output")
tb_plot_bact_totals(info, bact, type="wild")
tb_plot_bact_totals(info, bact, type="total")


## Make some plots

