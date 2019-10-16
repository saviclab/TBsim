# library(shiny)
# setwd("~/git/insightrx/ucsf-tbsim-shiny/app")
PORT <- 1410
HOST_IP<-"0.0.0.0"
if(Sys.getenv("PORT") != "") PORT <- as.numeric(as.character(Sys.getenv("PORT")))
if(Sys.getenv("HOST_IP") != "") HOST_IP <- as.numeric(as.character(Sys.getenv("HOST_IP")))
shiny::runApp("./", launch.browser=F, host=HOST_IP,port=PORT)
