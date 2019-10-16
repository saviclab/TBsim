## Base packages:
install.packages(c("devtools", "Rcpp", "stringr", "lubridate"))## Shiny extensions
install.packages(c("shinythemes", "shinydashboard",
                   "shinyjs", "shinyBS",
                   "rhandsontable", "googleAuthR"))
install.packages(c("anytime","DT","loggit"))
install.packages("remotes")
library(remotes)
install_version("loggit")
## non-CRAN libraries
library(devtools)
install_github("MarkEdmondson1234/googleID")
install_github("ronkeizer/Rge")
install_git("https://github.com/trestletech/shinyTable")

## TBsim libraries
install_bitbucket("ucsf_ip/TBsim",auth_user="WillFox")
install_github("InsightRX/TBsimApp")


## Need to check if really necessary:
install_github("InsightRX/PKPDsim")
install_github("ronkeizer/PKPDplot")
install_github("ronkeizer/vpc")

package_list<-c("devtools","Rcpp", "stringr", "lubridate")
m<-lapply(package_list,library,character.only=TRUE)


package_list<-c("shinythemes", "shinydashboard",
                "shinyjs", "shinyTable", "shinyBS",
                "rhandsontable", "googleAuthR")
m<-lapply(package_list,library,character.only=TRUE)


package_list<-c("googleID", "Rge",
                "TBsim", "TBsimApp"
                #"PKPDplot","PKPDplot",
                #"vpc"
                )
m<-lapply(package_list,library,character.only=TRUE)

#PORT=8000 LOCAL=1 HOST_IP="10.60.107.63" Rscript run.R
#PORT=1410 LOCAL=1 Rscript run.R


#libcairo2-dev
#libxml2-dev
#libcurl4-openssl-dev
#libssl-dev
#r-base-dev
#sudo apt install gridengine-exec
#sudo apt install gridengine-master
