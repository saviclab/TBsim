## Base packages:
install.packages("devtools", "Rcpp", "stringr", "lubridate")

## Shiny extensions
install.packages(c("shinythemes", "shinydashboard",
                   "shinyjs", "shinyTable", "shinyBS",
                   "rhandsontable", "googleAuthR"))

## non-CRAN libraries
library(devtools)
install_github("MarkEdmondson1234/googleID")
install_github("ronkeizer/Rge")

## TBsim libraries
install_bitbucket("ucsf_ip/TBsim")
install_github("InsightRX/TBsimApp")


## Need to check if really necessary:
install_github("ronkeizer/PKPDplot")
install_github("ronkeizer/vpc")
