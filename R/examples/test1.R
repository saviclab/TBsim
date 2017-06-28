library(TBsim)
library(ggplot2)
library(Rge)

## On Mac, make sure not to use the Clang compiler but the GNU g++ compiler
# tb_compile(cpp = "/usr/bin/g++")

## read in templates and define some constants
therapy       <- tb_read_init("6EHRZ.txt")
adherence     <- tb_read_init("adh2.txt")
drugs <- list(
  EMB = tb_read_init("EMB.txt"),
  RIF = tb_read_init("RIF.txt"),
  INH = tb_read_init("INH.txt"),
  PZA = tb_read_init("PZA.txt")
)

## create a new simulation definition
folder <- new_tempdir()
# tb_write_init(therapy, "therapy.txt", folder = folder)
# tb_write_init(therapy, "adherence.txt", folder = folder)
sim1 <- tb_new_sim(folder = folder,
                   therapy = therapy,
                   adherence = adherence,
                   drugs = drugs,
                   nPatients = 100,
                   therapyStart = 90,
                   nTime = 180,
                   isDrugEffect = 1,
                   isSaveBactRes = 1,
                   isSaveImmune = 1,
                   isSaveBact = 1,
                   isSaveEffect = 1,
                   isSaveConc = 0,
                   isSaveConcKill = 0,
                   isSaveAdhDose = 0,
                   isSavePopulationResults = 1,
                   isSavePatientResults = 0,
                   isSaveMacro = 0,
                   isGranImmuneKill = 1,
                   isClearResist = 1,
                   isPersistance = 1)

## Start the simulation based on the given definitions
run <- tb_run_sim (sim1)

## First, read in all information available
info  <- tb_read_output(folder, "header")
outc  <- tb_read_output(folder, "outcome")
bact  <- tb_read_output(folder, "bact")
conc  <- tb_read_output(folder, "conc")
dose  <- tb_read_output(folder, "dose")
eff   <- tb_read_output(folder, "effect")
kill  <- tb_read_output(folder, "kill")
imm   <- tb_read_output(folder, "immune")
macro <- tb_read_output(folder, "macro")

tb_plot (info, res$outc)
