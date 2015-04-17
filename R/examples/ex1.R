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
                   isSaveMacro = 1)

## Start the simulation based on the given definitions
tb_run_sim (sim1)

## Make some plots
## First, read in some general information about the simulation
folder <- "~/tb_run/output"
info <- tb_read_headerfile(folder)

## Plot outcome data
outc <- tb_read_outcome(folder)
tb_plot_outcome(info, outc)

## Plot bacterial data
bact <- tb_read_bact_totals(folder)
tb_plot_bact_totals(info, bact, type="wild")
tb_plot_bact_totals(info, bact, type="total")

## Plot concentrations
conc <- tb_read_conc(folder)
tb_plot_conc (info, conc)

## Plot doses
dose <- tb_read_dose(folder)
tb_plot_dose (info, dose)

## Plot effect
eff <- tb_read_effect(folder)
tb_plot_effect (info, eff)

## plot Kill
kill <- tb_read_kill(folder)
tb_plot_kill (info, kill)

## Plot adherence (doesn't work!)
adh <- tb_read_adherence(folder)
tb_plot_adherence(info, adh)

## Plot immune results
imm <- tb_read_immune(folder)
imm_pl <- tb_plot_immune_all(info, imm)
imm_pl$cytokines_lung
imm_pl$cytokines_lymph
imm_pl$cytokines_dendr
imm_pl$t_cells_lung
imm_pl$t_helper
imm_pl$t_naive

## Plot macro

## Plot population results

## plot Grow

## Plot patient results


