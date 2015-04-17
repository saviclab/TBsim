library(TBsim)
library(reshape2)
library(dplyr)
library(stringr)

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

## create a new simulation definition
sim1 <- tb_new_sim(therapy = therapy,
                   adherence = adherence,
                   drug = drugs,
                   nPatients = 100,
                   therapyStart = 90,
                   nTime = 180,
                   isDrugEffect = 1,
                   isSaveBactRes = 1,
                   isSaveImmune = 1,
                   isSaveBact = 1,
                   isSaveEffect = 1,
                   isSaveConc = 1,
                   isSaveConcKill = 1,
                   isSaveAdhDose = 1,
                   isSavePopulationResults = 1,
                   isSavePatientResults = 1,
                   isSaveMacro = 1,
                   isGranImmuneKill = 1,
                   isClearResist = 1,
                   isPersistance = 1)

## Start the simulation based on the given definitions
tb_run_sim (sim1)

## First, read in all information available
folder <- "~/tb_run/output"
info  <- tb_read_output(folder, "header")
outc  <- tb_read_output(folder, "outcome")
bact  <- tb_read_output(folder, "bact")
conc  <- tb_read_output(folder, "conc")
dose  <- tb_read_output(folder, "dose")
eff   <- tb_read_output(folder, "effect")
kill  <- tb_read_output(folder, "kill")
imm   <- tb_read_output(folder, "immune")
macro <- tb_read_output(folder, "macro")

# granuloma <- tb_read_output(folder, "granuloma") # couldn't get this file to be saved by the tool !!!
# adh <- tb_read_output(folder, "adherence") # something's wrong with the output data too

## Plot outcome data
tb_plot (info, outc)

## Plot bacterial data
tb_plot (info, bact, type="wild")
tb_plot (info, bact, type="total")

## Plot concentrations
tb_plot (info, conc)

## Plot doses
tb_plot (info, dose)

## Plot effect
tb_plot_effect (info, eff)

## plot Kill
tb_plot (info, kill)

## Plot immune results
imm_pl <- tb_plot(info, imm)
imm_pl$cytokines_lung
imm_pl$cytokines_lymph
imm_pl$cytokines_dendr
imm_pl$t_cells_lung
imm_pl$t_helper
imm_pl$t_naive

## Plot macrophages
tb_plot(info, macro)

## Plot adherence
tb_plot(info, adh)

## Plot granuloma (no data yet)
# tb_plot(info, granuloma)


