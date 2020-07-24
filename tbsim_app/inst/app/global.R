## TBsim libraries
library(TBsimApp)       ## Helper functions for the TBsim Shiny app
library(TBsim)          ## Main simulation module

## Custom libraries
library(PKPDsim)        ## Simulation
library(PKPDplot)       ## Plotting
library(vpc)            ## For some plotting functions
#library(insightrxmisc)  ## Miscellaneous routines, will be split off later
library(Rge)            ## Grid engine

## tidyverse and related
library(stringr)        ## String manipulation
library(lubridate)      ## For handling date/times
library(anytime)        ## parse dates and times
library(ggplot2)

# library(sys)            ## run internal system commands

################################################################
## Google authentication
################################################################
library(googleAuthR)
library(googleID)
library(shiny)
library(shinyjs)
library(rhandsontable)
library(jsonlite)

# library(shinyjs)
options(googleAuthR.scopes.selected = c("https://www.googleapis.com/auth/userinfo.email", "https://www.googleapis.com/auth/userinfo.profile"))
options(googleAnalyticsR.webapp.client_id = "*u8e2.apps.googleusercontent.com")
options(googleAnalyticsR.webapp.client_secret = "*F")
options(googleAuthR.client_id ="2.apps.googleusercontent.com")
options(googleAuthR.client_secret = "*F")
options(googleAuthR.webapp.client_id = "*2.apps.googleusercontent.com")
options(googleAuthR.webapp.client_secret = "*F")

## Global variables and definitions
base_dir <- getwd()
regimenList <- list(
 "HRZE daily 8 wks, HR daily 18 wks" = tb_read_init("standard_HRZE8_7wkl_HR18_7wkl.txt"),
 "HRZE daily 8 wks, HR 3x/week 18 wks" = tb_read_init("standard_HRZE8_7wkl_HR18_3wkl.txt"),
 "HRZE 3x/week 8 wks, HR 3x/week 18 wks" = tb_read_init("standard_HRZE8_3wkl_HR18_3wkl.txt"),
 "HRZE daily 2 wks, HRZE 2x/wk 6 wks, HR 2x/week 18 wks" = tb_read_init("standard_HRZE2_7wkl_HRZE6_2wkl_HR18_2wkl.txt")
)
defaultRegimen <- names(regimenList)[1]
drugDefinitions <- list(
  RIF = tb_read_init("RIF.txt"),
  INH = tb_read_init("INH.txt"),
  PZA = tb_read_init("PZA.txt"),
  RPT = tb_read_init("RPT.txt"),
  MOX = tb_read_init("MOX.txt"),
  EMB = tb_read_init("EMB.txt")
)
drugNames <- list(
  RIF = "rifampicin",
  INH = "isoniazid",
  PZA = "pyrazinamide",
  RPT = "rifapentin",
  MOX = "moxifloxacin",
  EMB = "ethambutol"
)
adherenceOptions <- c("100%", "MEMS", "Markov")

## Colors
allDrugs <- drugDefinitions
regimenColors <- get_standard_colors(names(allDrugs))

cache <<- list(
  resetRegimen = FALSE,
  regimenList = regimenList,
  defaultRegimen = defaultRegimen,
  combinedDrugList = names(allDrugs)
)

# Override shiny button, should be <button>, not <a>
downloadButtonPDF <- function(outputId,
                           label="Download",
                           class=NULL, ...) {
  aTag <- tags$a(id=outputId,
                 class=paste('btn btn-default shiny-download-link', class),
                 href='',
                 target='_blank',
                 download=NA,
                 icon("file-pdf-o"),
                 "", ...)
}
downloadButtonData <- function(outputId,
                           label="Download",
                           class=NULL, ...) {
  aTag <- tags$a(id=outputId,
                 class=paste('btn btn-default shiny-download-link', class),
                 href='',
                 target='_blank',
                 download=NA,
                 icon("download"),
                 "", ...)
}
