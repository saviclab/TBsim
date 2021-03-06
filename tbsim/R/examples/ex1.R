library(TBsim)
library(ggplot2)
library(Rge)

## On Mac, make sure not to use the Clang compiler but the GNU g++ compiler
# tb_compile(cpp = "/usr/bin/g++")

## read in templates and define some constants
therapy       <- tb_read_init("standardTB4.txt")
adherence     <- tb_read_init("adh2.txt")
drugs <- list(
  EMB = tb_read_init("EMB.txt"),
  RIF = tb_read_init("RIF.txt"),
  INH = tb_read_init("INH.txt"),
  PZA = tb_read_init("PZA.txt")
)

immune <- tb_read_init("Immune.txt")

## create a new simulation definition
folder <- new_tempdir()
sim1 <- tb_new_sim(folder = folder,
                   therapy = therapy,
                   adherence = adherence,
                   immune = immune,
                   drugs = drugs,
                   nPatients = 1,
                   therapyStart = 180,
                   nTime = 180,
                   isDrugEffect = 1,
                   isSaveBactRes = 1,
                   isSaveImmune = 1,
                   isSaveBact = 1,
                   isSaveBactRes = 1,
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
run <- tb_run_sim (sim1)

## First, read in all information available
info  <- tb_read_output(folder, "header")
outc  <- tb_read_output(folder, "outcome")
bact  <- tb_read_output(folder, "bact")
bactRes <- tb_read_output(folder, "bactRes")
conc  <- tb_read_output(folder, "conc")
dose  <- tb_read_output(folder, "dose")
eff   <- tb_read_output(folder, "effect")
kill  <- tb_read_output(folder, "kill")
imm   <- tb_read_output(folder, "immune")
macro <- tb_read_output(folder, "macro")
print("\n\n\n:::")
print(folder)
# granuloma <- tb_read_output(folder, "granuloma") # couldn't get this file to be saved by the tool !!!
# adh <- tb_read_output(folder, "adherence") # something's wrong with the output data too

drugDefinitions <- list(
  RIF = tb_read_init("RIF.txt"),
  INH = tb_read_init("INH.txt"),
  PZA = tb_read_init("PZA.txt"),
  RPT = tb_read_init("RPT.txt"),
  MOX = tb_read_init("MOX.txt"),
  EMB = tb_read_init("EMB.txt")
)
#reg <- load_regimen(folder=paste0(folder, "/output/config"),
#                    drugDefinitions = drugDefinitions)


## Plot outcome data
res <- tb_read_all_output(folder = folder, output_folder = TRUE)
tb_plot (res$info, res$outc, theme=NULL) +
  theme(
    plot.title=element_blank(),
    legend.position = c(.5, .5),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    legend.background = element_blank(),
    panel.background = element_rect(fill="#ffffff"),
    plot.background = element_rect(fill = "#efefef")
  )+ xlab("Days") + ylab("%")
tb_plot (info, outc, theme=NULL)

## Plot bacterial data
tb_plot (info, bact, type="wild", is_summary=FALSE, theme=theme_bw())
tb_plot (info, bact, type="total")
tb_plot (info, bactRes)

## Plot concentrations
tb_plot_conc (info, conc)

## Plot doses
tb_plot_dose (info, dose)

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

