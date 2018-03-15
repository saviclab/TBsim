# Clear all
rm(list=ls())
graphics.off()

library(ggplot2)
library(reshape2)
library(scales) 
library(grid)
library(gridExtra)
library(stringr)
library(RColorBrewer)

#=======================================================================================
# Simulation of TB infection and treatment dynamics 
# 
# Program used to visualize calc output from C++ simulation
#
# Author: John Fors
# Date: July 2, 2014
# 
# Directory used for data files:
folder <- "/Users/johnfors/Desktop/TBsimulation/dataFiles/"
#=======================================================================================
# load external functions used
setwd('~/Desktop/TBsimulation/rFiles/')
source("readHeaderFile.R")

source("readGranuloma.R")
source("plotGranuloma.R")

source("readBactTotals.R")
source("plotBactTotals.R")	

source("makeDF.R")
source("makeDFQ.R")
source("plotBact.R")
source("plotMacro.R")
source("plotBactRes.R")
source("plotMultiBactRes.R")
source("plotMultiBact.R")
source("plotMultiMacro.R")

source("readMacro.R")
source("plotMacro.R")

source("readFile.R")
source("plotAdherence.R")
source("plotAdherenceBasic.R")

source("plotDose.R")
source("plotConc.R")
source("plotKill.R")
source("plotGrow.R")

source("readOutcome.R")
source("plotOutcome.R")

source("readBactRes.R")
source("plotBactRes.R")

source("readImmune.R")
source("plotImmune.R")
source("plotImmuneAll.R")

source("readEffect.R")
source("plotEffect.R")

#=======================================================================================
# Run settings
isFromDrugStart <- 1 # Start plots from time of drug start
isSummary		<- 0 # Summary across all compartments
isCombineLatClr <- 0 # Combine Latent and Cleared in outcome plot

isOutcome   <- 1	# Population infection status 
isCFUtot	<- 0	# plot total bacteria population, after start of therapy

isAdherence <- 0	# Basic adherence plot
isDose		<- 0    # Dose profiles
isConc		<- 0	# PK concentration profiles
isKill		<- 0	# EC50 Kill factors
isGrow		<- 0	# EC50 Growth factors

isEffect	<- 1	# Bactericidal contribution per drug and immune
isGran		<- 0	# Granuloma formation & break-up

isBactWild	<- 0	# Total wild-type bacteria per compartment
isBactTotal	<- 0	# Total bacteria per compartment
isBactRes	<- 0	# Resistant bacteria per compartment 
isMacro		<- 0	# Macrophages
isImmune	<- 0	# Immune system variables, except macrophages

isAdhDetails <- 0	# Adherence details
isTrials     <- 0	# summary of TB clinical trials

#=======================================================================================
# Read header file information
list <- readHeaderFile(folder)
timeStamp		<- list[[1]] 
nTime			<- list[[2]]
nSteps			<- list[[3]]
drugStart		<- list[[4]]
nPatients		<- list[[5]]
isResistance	<- list[[6]]
isImmuneKill	<- list[[7]]
isGranuloma		<- list[[8]]
isPersistance   <- list[[9]]
diseaseText		<- list[[10]]
nDrugs			<- list[[11]]
doseText		<- list[[12]]
outcomeIter		<- list[[13]]
drugNames		<- list[[14]]

rText <- "Resist. OFF"
if (isResistance>0) { rText <-"Resist. ON"}

iText <- "Immune OFF"
if (isImmuneKill>0) { iText <- "Immune ON"}

gText <- "Gran. OFF"
if (isGranuloma>0) { gText <- "Gran. ON"}

timePeriods <- 1:nTime
subTitle <- paste(nPatients, " pts; ",doseText, "; ", rText, "; ", gText, "; ", iText, sep="")

#=======================================================================================
# report figures
isFig2		<- 0	# Overview of bacterial growth without drug therapy
isFig3		<- 0	# Example PK profiles for 9 patients
isFig4		<- 0	# Overview of PK profiles with standard drug therapy
isFig5		<- 0	# Overview of bacterial growth with standard drug therapy
isFig6		<- 0	# Patient population therapy outcomes with standard drug therapy
isFig7		<- 0	# Compare outcome for standard Tx vs. not include INH 
isFig8		<- 0	# Increased growth in RMP-resistant bacterial strains 
isFig9		<- 0	# Compare outcome for different drug therapy scenarios
isFig10		<- 0	# Compare outcome for different patient scenarios

isFig11		<- 0	# Compare total bacterial load REMOX
isFig12		<- 0	# Compare total bacterial load RIFAQUIN
isFig13		<- 0	# Compare patient outcome REMOX
isFig14		<- 0	# Compare patient outcome RIFAQUIN

#=======================================================================================
# Wild-type bacteria
if (isBactWild==1){
	plotBactTotals("wild", isSummary, isFromDrugStart)
}
#=====================================================================================	
# Total bacteria 
if (isBactTotal==1){
	plotBactTotals("total", isSummary, isFromDrugStart)
}
#=====================================================================================	
# Total bacteria across all compartments
if (isCFUtot==1){
	isSum <- 1
	plotBactTotals("total", isSum, isFromDrugStart)
}
#=====================================================================================
# Resistant bacteria 
if (isBactRes==1){
	plotBactRes(isSummary, isFromDrugStart)
}
#=======================================================================================
# Macrophages
if (isMacro==1){
	plotMacro()
}
#=====================================================================================
# Immune system variables	
if (isImmune==1) {
	plotImmuneAll()
}
#=======================================================================================
# Granuloma formation status
if (isGran==1) {
	plotGranuloma()
}
#=======================================================================================
# Basicadherence
if (isAdherence==1) {
	plotAdherenceBasic()
}
#=======================================================================================
# Detailed adherence view
#if (isAdhDetails==1) {
#	plotAdherence()
#}
#=======================================================================================
# Effective drug dose
if (isDose==1){	
	plotDose()
}
#=======================================================================================
# PK concentration profiles
if (isConc==1){	
	plotConc()
}
#=======================================================================================
# EC50 kill factors
if (isKill==1){	
	plotKill()
}
#=======================================================================================
# EC50 growth factors
if (isGrow==1){	
	plotGrow()
}
#=======================================================================================
# Therapy outcome for population
if (isOutcome==1) {
	plotOutcome(isFromDrugStart, isCombineLatClr)
}		
#=======================================================================================
# Bactericidal contribution per drug per compartment per time
if (isEffect==1){	
	plotEffect()
}
#===========================================================================
if (isTrials==1){
	plotTrials()
}
#===========================================================================
# figure 2
# Drug: no drug
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean:1
# immune level: 1
# persisting: 0
# patients: 5000, time: 600, start: 180
if (isFig2==1){
	# Load data
	y1 <- read.table(paste(folder, "Bt_I_q3N.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Bt_I_mN.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "Bt_I_q1N.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y4 <- read.table(paste(folder, "Bt_II_q3N.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y5 <- read.table(paste(folder, "Bt_II_mN.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	y6 <- read.table(paste(folder, "Bt_II_q1N.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare data
	timePeriods <- 1:nTime
	drugStart <- 180
	yin   <- rbind(y1, y2, y3, y4, y5, y6)
	yint  <- t(yin[1:(length(yin)-1)])
	yset  <- data.frame(timePeriods, yint)
	names <- c("time", "Quartile_3", "Median", "Quartile_1", "Quartile_32", "Median2", "Quartile_12")
	colnames(yset) <- names
	yset <- yset[seq(1, nrow(yset), 10), ]
	
	plot.main <- "Total Tuberculosis Bacteria Growth Without Drug Therapy"
	plot.sub  <- "[Median and quartiles for population of 5000 patients]"
	ytext	  <- "Bacterial Load (CFU/mL)"
	xtext	  <- "Time (days since drug start)"
	
	yset$Median		<-	log(yset$Median)
	yset$Quartile_1 <-	log(yset$Quartile_1)
	yset$Quartile_3 <-	log(yset$Quartile_3)
	yset$Median2	<-	log(yset$Median2)
	yset$Quartile_12 <-	log(yset$Quartile_12)
	yset$Quartile_32 <-	log(yset$Quartile_32)
	laby   <- log(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000)) 
	namesy <- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9)
	labx   <- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +
          geom_ribbon(aes(ymin=Quartile_1, ymax=Quartile_3), alpha=0.2) +
    	  geom_line(aes(y=Median), colour="blue", size=1) +
		  geom_ribbon(aes(ymin=Quartile_12, ymax=Quartile_32), alpha=0.2) +
    	  geom_line(aes(y=Median2), colour="red", size=1) +
		  scale_y_continuous(breaks = laby, labels = namesy) +
		  scale_x_continuous(breaks = labx, labels = namesx) 
	pl +  xlab(xtext) + 
		  ylab(ytext) +
		  geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
		  annotate("text", x = 50, y = 10, label = "Intracellular", size=4) +
		  annotate("text", x = 150, y = 2, label = "Extracellular", size=4) +
		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}
#===========================================================================
# figure 3
# Drug: standard drug therapy
# filter 0, 0; threshold 1, 20
# resistance: on, 
# save individual patient data: on
# adherencetype: 0, mean:1
# immune level: 1
# persisting: 0
# patients: 10, time: 600, start: 180	
if (isFig3==1) {
	# Load data
	p1 <- read.table(paste(folder, "calcCII2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	r1 <- p1[1,]
	r2 <- p1[2,]
	r3 <- p1[3,]
	r4 <- p1[4,]
	r5 <- p1[5,]
	r6 <- p1[6,]
	r7 <- p1[7,]
	r8 <- p1[8,]
	r9 <- p1[9,]
	yin <- rbind(r1, r2, r3, r4, r5, r6, r7, r8, r9)
	
	# Prepare data 
	timeHours <- seq(1,144)
	yint <- t(yin[1:144])
	yset <- data.frame(timeHours, yint)
	labx	<- c(1, 24, 48, 72, 96, 120, 144)
	mainTitle <- "Rifampin Concentration Profiles for 9 Patients"
	subTitle  <- "[Standard drug therapy, initial 1 wk, intracellular]"
	namesx <- c("D1", "D2", "D3", "D4", "D5", "D6", "D7")
	xLab	<- "Time (days since drug start)"
	yLab	<- "Drug concentration (mg/L)"
	colnames(yset) <- c("time", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9")
	dfm <- melt(yset, id="time")
	
	# Prepare plot
   	dev.new()
	pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable, group=variable)) +
		  geom_line(size=1.0, rm.na=TRUE) +
		  scale_colour_brewer(palette="Set1") +
		  scale_x_continuous(breaks = labx, labels = namesx) +
 		  theme(axis.title.y=element_text(angle=90, size=10)) +
  		  theme(axis.title.x=element_text(angle=0, size=10)) 
 
	pl + xlab(xLab) +
	     ylab(yLab) +
 		 expand_limits(y=0) + 
		 labs(color = "Patient") +
		 ggtitle(bquote(atop(.(mainTitle), atop(italic(.(subTitle)), "")))) 
}	
#===========================================================================
# figure 4
# Drug: standard drug therapy
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean:1
# immune level: 1
# persisting: 0
# patients: 5000, time: 600, start: 180	
if (isFig4==1) {	
	# set default
	if (drug[3]=="RIF") {drug[3] <- "RMP"} # use standard naming
	
	dev.new()
	mainTitle	<- "Drug PK Concentration Profiles per Drug"
	subTitle	<- "[Hourly and daily averages (mg/L) first 2 wks, 5000 patients]"
	namesx		<- c("D1", "D4", "D8", "D11", "D15")
	namesBlank	<- c("", "", "", "", "")
	
	p1 <- read.table(paste(folder, "concIDrug0_m.txt",   sep=""), header=FALSE,sep="\t", skip=1)
	p2 <- read.table(paste(folder, "concIIDrug0_m.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	yMax = 1.2*max(max(p1, na.rm=TRUE), max(p2, na.rm=TRUE))
	plot1 <- basePlot(rbind(p1), "Extracellular \n Outside Granuloma", yMax, drug[1], namesBlank)
	plot2 <- basePlot(rbind(p2), "Intracellular \n Outside Granuloma", yMax, "", namesBlank)
	
	#isTitle <- 0
	p5 <- read.table(paste(folder, "concIDrug1_m.txt",   sep=""), header=FALSE,sep="\t", skip=1)
	p6 <- read.table(paste(folder, "concIIDrug1_m.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	yMax = 1.2*max(max(p5, na.rm=TRUE), max(p6, na.rm=TRUE))
   	plot5 <- basePlot(rbind(p5), "", yMax, drug[2], namesBlank)
	plot6 <- basePlot(rbind(p6), "", yMax, "", namesBlank)

	p9 <- read.table(paste(folder, "concIDrug2_m.txt",    sep=""), header=FALSE,sep="\t", skip=1)
	p10 <- read.table(paste(folder, "concIIDrug2_m.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	yMax = 1.2*max(max(p9, na.rm=TRUE), max(p10, na.rm=TRUE))
	plot9 <- basePlot(rbind(p9), "", yMax, drug[3], namesBlank)
	plot10 <- basePlot(rbind(p10), "", yMax, "", namesBlank)

	p13 <- read.table(paste(folder, "concIDrug3_m.txt",   sep=""), header=FALSE,sep="\t", skip=1)
	p14 <- read.table(paste(folder, "concIIDrug3_m.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	yMax = 1.2*max(max(p13, na.rm=TRUE), max(p14, na.rm=TRUE))
	plot13 <- basePlot(rbind(p13), "", yMax, drug[4], namesx)
	plot14 <- basePlot(rbind(p14), "", yMax, "", namesx)

	multiPlot4(plot1, plot5, plot9, plot13, plot2, plot6, plot10, plot14, cols=2, label1 = mainTitle, label2=subTitle)
}
#===========================================================================
# figure 5
# Drug: standard drug therapy
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean:1
# immune level: 1
# persisting: 0
# patients: 5000, time: 600, start: 180
if (isFig5==1){
	# Load data
	y1 <- read.table(paste(folder, "Bt_I_q3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Bt_I_m.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "Bt_I_q1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y4 <- read.table(paste(folder, "Bt_II_q3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y5 <- read.table(paste(folder, "Bt_II_m.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	y6 <- read.table(paste(folder, "Bt_II_q1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare data
	timePeriods <- 1:nTime
	drugStart <- 180
	yin   <- rbind(y1, y2, y3, y4, y5, y6)
	yint  <- t(yin[1:(length(yin)-1)])
	yset  <- data.frame(timePeriods, yint)
	names <- c("time", "Quartile_3", "Median", "Quartile_1", "Quartile_32", "Median2", "Quartile_12")
	colnames(yset) <- names
	yset <- yset[seq(1, nrow(yset), 10), ]
	
	plot.main <- "Total Tuberculosis Bacteria With Standard Drug Therapy"
	plot.sub <- "[Median and quartiles for population of 5000 patients]"
	ytext <- "Bacterial Load (CFU/mL)"
	xtext <- "Time (days since drug start)"
	
	yset$Median		<-	log(yset$Median)
	yset$Quartile_1 <-	log(yset$Quartile_1)
	yset$Quartile_3 <-	log(yset$Quartile_3)
	yset$Median2	<-	log(yset$Median2)
	yset$Quartile_12 <-	log(yset$Quartile_12)
	yset$Quartile_32 <-	log(yset$Quartile_32)
	laby <- log(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000)) 
	namesy <- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9)
	labx <-   c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +
          geom_ribbon(aes(ymin=Quartile_1, ymax=Quartile_3), alpha=0.2) +
    	  geom_line(aes(y=Median), colour="blue", size=1) +
		  geom_ribbon(aes(ymin=Quartile_12, ymax=Quartile_32), alpha=0.2) +
    	  geom_line(aes(y=Median2), colour="red", size=1) +
		  scale_y_continuous(breaks = laby, labels = namesy) +
		  scale_x_continuous(breaks = labx, labels = namesx) 
	pl +  xlab(xtext) + 
		  ylab(ytext) +
		  geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
		  annotate("text", x = 50, y = 10, label = "Intracellular", size=4) +
		  annotate("text", x = 120, y = 1, label = "Extracellular", size=4) +
		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
	
	#ggsave(pl, file="ratings.png", scale=1)
	#dev.off()
}
#===========================================================================
# figure 6
# Drug: standard drug therapy
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean:1
# immune level: 1
# persisting: 0
# patients: 5000, time: 600, start: 180	

if (isFig6==1) {
	# Load data
	y1 <- read.table(paste(folder, "countAcuteTB.txt",   sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "countClearedTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare data 
	timePeriods <- 1:nTime
	drugStart   <- 180
	yin   <- rbind(y1*100, y3*100)
	yint  <- t(yin[1:(length(yin)-1)])
	yset  <- data.frame(timePeriods, yint)
	names <- c("time", "Acute TB", "Cleared TB")
	colnames(yset) <- names
	dfm <- melt(yset, id="time")
	
	plot.main <- "Treatment Outcome With Standard Drug Therapy"
	plot.sub  <- "[Population of 5000 patients]"
	xtext	  <- "Time (days since drug start)"
	ytext     <- "Share of patient population (%)"
	
	labx   <- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby   <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable)) +
		  scale_fill_brewer(palette="Set1") +
		  geom_line(size=1.0) +
		  scale_x_continuous(breaks = labx, labels = namesx) +
		  scale_y_continuous(breaks = laby, labels = namesy) 
		
	pl +  xlab(xtext) + 
		  ylab(ytext) +
		  theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
			    legend.background = element_rect(fill=alpha('white', 1.0)),
			    legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
		  geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
		  expand_limits(y=0) + 
		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}
#===========================================================================
# figure 7
# Drug: run 1 for standard drug therapy, run 2 for partial drug therapy (selection = 1)
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean: 1
# immune level: 1
# persisting: 0
# patients: 5000, time: 600, start: 180	
if (isFig7==1) {
	# Load data
	## standard therapy file
	y1 <- read.table(paste(folder, "countClearedTB1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	## partial therapy file
	y3 <- read.table(paste(folder, "countClearedTB2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare data 
	timePeriods <- 1:nTime
	drugStart   <- 180
	yin   <- rbind(y1*100, y3*100)
	yint  <- t(yin[1:(length(yin)-1)])
	yset  <- data.frame(timePeriods, yint)
	names <- c("time", "Standard Therapy", "Partial Therapy")
	colnames(yset) <- names
	dfm <- melt(yset, id="time")
	
	plot.main <- "Treatment Outcome with Standard vs. Partial Drug Therapy"
	plot.sub  <- "[Population of 5000 patients]"
	xtext	  <- "Time (days since drug start)"
	ytext     <- "Share of patient population (%)"
	
	labx   <- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby   <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable)) +
		  scale_fill_brewer(palette="Set1") +
		  geom_line(size=1.0) +
		  scale_x_continuous(breaks = labx, labels = namesx) +
		  scale_y_continuous(breaks = laby, labels = namesy) 
		
	pl +  xlab(xtext) + 
		  ylab(ytext) +
		  theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
			    legend.background = element_rect(fill=alpha('white', 1.0)),
			    legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
		  geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
		  expand_limits(y=0) + 
		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}
#===========================================================================
# figure 8
# Drug: run 1 for standard drug therapy, run 2 for partial drug therapy (selection = 1)
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean:1
# immune level: 1
# persisting: 0
# patients: 5000, time: 600, start: 180
if (isFig8==1){
	# Load data
	# standard therapy
	y1 <- read.table(paste(folder, "Br1_I_m1.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Br1_II_m1.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	# partial drug therapy
	y3 <- read.table(paste(folder, "Br1_I_m2.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	y4 <- read.table(paste(folder, "Br1_II_m2.txt",  sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare data
	timePeriods <- 1:nTime
	drugStart <- 180
	yin   <- rbind(y1+y2, y3+y4)
	yint  <- t(yin[1:(length(yin)-1)])
	yset  <- data.frame(timePeriods, yint)
	names <- c("time", "Standard Therapy", "Partial Therapy")
	colnames(yset) <- names
	dfm <- melt(yset, id="time")
	
	plot.main <- "Rifampin Resistant Bacteria with Standard vs. Partial Drug Therapy"
	plot.sub  <- "[Median value for population of 5000 patients]"
	ytext	  <- "Bacterial load (CFU/mL)"
	xtext	  <- "Time (days since drug start)"
	
	labx	  <- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx    <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = dfm, aes(x = time, y=value, colour=variable)) +
    	  geom_line(size=1) +
		  scale_fill_brewer(palette="Set1") +
		  scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                        labels = trans_format("log10", math_format(10^.x)),
		   				limits = c(1e-8,1e3)) +
		  scale_x_continuous(breaks = labx, labels = namesx) 
	pl +  xlab(xtext) + 
		  ylab(ytext) +
		  theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
		        legend.background = element_rect(fill=alpha('white', 1.0)),
		        legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
		  geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}
#===========================================================================
# figure 9
# Drug: run 1 for standard drug therapy, run 2 for increased drug dose (selection = 7)
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean: 1
# immune level: 1
# persisting: 0
# patients: 5000, time: 600, start: 180	
if (isFig9==1) {
	# Load data
	## standard therapy file
	y1 <- read.table(paste(folder, "countClearedTB1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	## increased RMP dose
	y3 <- read.table(paste(folder, "countClearedTB3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	## earlier therapy start date
	y4 <- read.table(paste(folder, "countClearedTB4.txt", sep=""), header=FALSE,sep="\t", skip=1)
	# adjust for different time reference point, and add 90 days of null before start
	y4t <- y4
	for (i in 90:(600-90))  { y4t[i+90] <- y4[i] }
	for (i in 1:90)			{ y4t[i+90] <- y4[i] }

	## reduced drug frequency
	y5 <- read.table(paste(folder, "countClearedTB5.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
	# shorter therapy (2 + 2 months)
	y8 <- read.table(paste(folder, "countClearedTB8.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare data 
	timePeriods <- 1:nTime
	drugStart   <- 180
	yin   <- rbind(y1*100, y3*100, y4t*100, y5*100, y8*100)
	yint  <- t(yin[1:(length(yin)-1)])
	yset  <- data.frame(timePeriods, yint)
	names <- c("time", "Standard therapy", "Increased RMP dose", "Earlier Tx start", "Reduced Tx frequency", "Shorter Tx")
	colnames(yset) <- names
	dfm <- melt(yset, id="time")
	
	plot.main <- "Treatment Outcome with Standard vs. Other Therapy Scenarios"
	plot.sub  <- "[Population of 5000 patients]"
	xtext	  <- "Time (days since drug start)"
	ytext     <- "Share of patient population (%)"
	
	labx   <- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby   <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable)) +
		  scale_fill_brewer(palette="Set1") +
		  geom_line(size=1.0) +
		  scale_x_continuous(breaks = labx, labels = namesx) +
		  scale_y_continuous(breaks = laby, labels = namesy) 
		
	pl + xlab(xtext) + 
		 ylab(ytext) +
		 theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
			   legend.background = element_rect(fill=alpha('white', 1.0)),
			   legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
		 geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
		 expand_limits(y=0) + 
		 ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}
#===========================================================================
# figure 10
# Drug: run 1 for standard drug therapy
# run 2 for reduced pt adherence (0.8), and run 3 for lower immune system (0.5)
# filter 0, 0; threshold 1, 20
# resistance: on, 
# adherencetype: 0, mean: 0.8
# immune level: 0.5
# persisting: 0
# patients: 5000, time: 600, start: 180	
if (isFig10==1) {
	# Load data
	## standard therapy file
	y1 <- read.table(paste(folder, "countClearedTB1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	## reduced pt adherence level 
	y6 <- read.table(paste(folder, "countClearedTB6.txt", sep=""), header=FALSE,sep="\t", skip=1)
	## reduced immune system function
	y7 <- read.table(paste(folder, "countClearedTB7.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare data 
	timePeriods <- 1:nTime
	drugStart   <- 180
	yin   <- rbind(y1*100, y6*100, y7*100)
	yint  <- t(yin[1:(length(yin)-1)])
	yset  <- data.frame(timePeriods, yint)
	names <- c("time", "Standard therapy", "Lower adherence", "Lower immune system")
	colnames(yset) <- names
	dfm <- melt(yset, id="time")
	
	plot.main <- "Treatment Outcome with Standard vs. Different Patient Scenarios"
	plot.sub  <- "[Population of 5000 patients]"
	xtext	  <- "Time (days since drug start)"
	ytext     <- "Share of patient population (%)"
	
	labx   <- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby   <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable)) +
		scale_fill_brewer(palette="Set1") +
		geom_line(size=1.0) +
		scale_x_continuous(breaks = labx, labels = namesx) +
		scale_y_continuous(breaks = laby, labels = namesy) 
		
	pl + xlab(xtext) + 
		 ylab(ytext) +
		 theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
			   legend.background = element_rect(fill=alpha('white', 1.0)),
			   legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
		 geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
		 expand_limits(y=0) + 
		 ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}
#=============================================
if (isFig11==1){
	subTitle <- ""
	mainTitle <- "Total Mtb Bacteria (all compartments)"
	nTime <- 360
	timePeriods <- 1:nTime
	
	folder2 <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/StandardOfCare/"
	
	y1 <- read.table(paste(folder2, "Bt_I2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y1  <- makeDF(y1, "y1m")
	y2 <- read.table(paste(folder2, "Bt_I1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2  <- makeDF(y2, "y2m")
	y3 <- read.table(paste(folder2, "Bt_I0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3  <- makeDF(y3, "y3m")

	y4 <- read.table(paste(folder2, "Bt_II2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y4  <- makeDF(y4, "y1m")
	y5 <- read.table(paste(folder2, "Bt_II1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y5  <- makeDF(y5, "y2m")
	y6 <- read.table(paste(folder2, "Bt_II0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y6  <- makeDF(y6, "y3m")
	
	y1$y1m <- y1$y1m + y4$y1m
	y2$y2m <- y2$y2m + y5$y2m
	y3$y3m <- y3$y3m + y6$y3m
	
	y7 <- read.table(paste(folder2, "Bt_III2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y7  <- makeDF(y7, "y1m")
	y8 <- read.table(paste(folder2, "Bt_III1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y8  <- makeDF(y8, "y2m")
	y9 <- read.table(paste(folder2, "Bt_III0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y9  <- makeDF(y9, "y3m")
	
	y1$y1m <- y1$y1m + y7$y1m
	y2$y2m <- y2$y2m + y8$y2m
	y3$y3m <- y3$y3m + y9$y3m	
	
	y10 <- read.table(paste(folder2, "Bt_IV2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y10  <- makeDF(y10, "y1m")
	y11 <- read.table(paste(folder2, "Bt_IV1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y11 <- makeDF(y11, "y2m")
	y12 <- read.table(paste(folder2, "Bt_IV0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y12  <- makeDF(y12, "y3m")
	
	y1$y1m <- y1$y1m + y10$y1m
	y2$y2m <- y2$y2m + y11$y2m
	y3$y3m <- y3$y3m + y12$y3m
	
	yset <- data.frame(timePeriods, y1$y1m, y2$y2m, y3$y3m)
	
	folder2 <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/REMoxEMB/"
	
	y11 <- read.table(paste(folder2, "Bt_I2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y11  <- makeDF(y11, "y1m")
	y12 <- read.table(paste(folder2, "Bt_I1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y12  <- makeDF(y12, "y2m")
	y13 <- read.table(paste(folder2, "Bt_I0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y13  <- makeDF(y13, "y3m")

	y14 <- read.table(paste(folder2, "Bt_II2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y14  <- makeDF(y14, "y1m")
	y15 <- read.table(paste(folder2, "Bt_II1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y15  <- makeDF(y15, "y2m")
	y16 <- read.table(paste(folder2, "Bt_II0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y16  <- makeDF(y16, "y3m")
	
	y11$y1m <- y11$y1m + y14$y1m
	y12$y2m <- y12$y2m + y15$y2m
	y13$y3m <- y13$y3m + y16$y3m
	
	y17 <- read.table(paste(folder2, "Bt_III2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y17  <- makeDF(y17, "y1m")
	y18 <- read.table(paste(folder2, "Bt_III1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y18  <- makeDF(y18, "y2m")
	y19 <- read.table(paste(folder2, "Bt_III0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y19  <- makeDF(y19, "y3m")
	
	y11$y1m <- y11$y1m + y17$y1m
	y12$y2m <- y12$y2m + y18$y2m
	y13$y3m <- y13$y3m + y19$y3m	
	
	y110 <- read.table(paste(folder2, "Bt_IV2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y110  <- makeDF(y110, "y1m")
	y111 <- read.table(paste(folder2, "Bt_IV1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y111 <- makeDF(y111, "y2m")
	y112 <- read.table(paste(folder2, "Bt_IV0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y112  <- makeDF(y112, "y3m")
	
	y11$y1m <- y11$y1m + y110$y1m
	y12$y2m <- y12$y2m + y111$y2m
	y13$y3m <- y13$y3m + y112$y3m
	
	yset <- data.frame(yset, y11$y1m, y12$y2m, y13$y3m)		# append more data
	
	folder2 <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/REMoxINH/"
		
	y21 <- read.table(paste(folder2, "Bt_I2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y21  <- makeDF(y21, "y1m")
	y22 <- read.table(paste(folder2, "Bt_I1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y22  <- makeDF(y22, "y2m")
	y23 <- read.table(paste(folder2, "Bt_I0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y23  <- makeDF(y23, "y3m")

	y24 <- read.table(paste(folder2, "Bt_II2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y24  <- makeDF(y24, "y1m")
	y25 <- read.table(paste(folder2, "Bt_II1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y25  <- makeDF(y25, "y2m")
	y26 <- read.table(paste(folder2, "Bt_II0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y26  <- makeDF(y26, "y3m")
	
	y21$y1m <- y21$y1m + y24$y1m
	y22$y2m <- y22$y2m + y25$y2m
	y23$y3m <- y23$y3m + y26$y3m
	
	y27 <- read.table(paste(folder2, "Bt_III2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y27  <- makeDF(y27, "y1m")
	y28 <- read.table(paste(folder2, "Bt_III1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y28  <- makeDF(y28, "y2m")
	y29 <- read.table(paste(folder2, "Bt_III0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y29  <- makeDF(y29, "y3m")
	
	y21$y1m <- y21$y1m + y27$y1m
	y22$y2m <- y22$y2m + y28$y2m
	y23$y3m <- y23$y3m + y29$y3m	
	
	y210 <- read.table(paste(folder2, "Bt_IV2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y210  <- makeDF(y210, "y1m")
	y211 <- read.table(paste(folder2, "Bt_IV1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y211 <- makeDF(y211, "y2m")
	y212 <- read.table(paste(folder2, "Bt_IV0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y212  <- makeDF(y212, "y3m")
	
	y21$y1m <- y21$y1m + y210$y1m
	y22$y2m <- y22$y2m + y211$y2m
	y23$y3m <- y23$y3m + y212$y3m
	
	yset <- data.frame(yset, y21$y1m, y22$y2m, y23$y3m)		# append more data
	
	names <- c("time", "SoCQ1", "SOC", "SoCQ3", "EQ3", "EMB", "EQ1", "IQ3", "INH", "IQ1")
	colnames(yset) <- names
	yset$INH[300:360] <- NA
	yset$IQ1[300:360] <- NA
	yset$IQ3[300:360] <- NA
	yset$EMB[300:360] <- NA
	yset$EQ1[300:360] <- NA
	yset$EQ3[300:360] <- NA
	
	yset <- subset(yset, time>180)

	# Prepare data for subset
	#yset <- yset[seq(1, nrow(yset), 10), ]	# sample every 10th point to plot
	
	# transform to log
	yset$SOC	<- log(yset$SOC)
	yset$SoCQ1	<- log(yset$SoCQ1)
	yset$SoCQ3	<- log(yset$SoCQ3)
	
	yset$INH	<- log(yset$INH)
	yset$IQ1	<- log(yset$IQ1)
	yset$IQ3	<- log(yset$IQ3)

	yset$EMB	<- log(yset$EMB)
	yset$EQ1	<- log(yset$EQ1)
	yset$EQ3	<- log(yset$EQ3)
	
	# set axis text and labels
	plot.main	<- mainTitle
	plot.sub	<- subTitle
	ytext <- "Cells/mL"
	laby	<- log(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000)) 
	namesy	<- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6)
	labx	<- c(180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx	<- c(0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +			
		  geom_ribbon(aes(ymin=SoCQ1, ymax=SoCQ3), alpha=0.2) +
    	  geom_line(aes(y=SOC, colour="SOC"), size=1) +
          geom_ribbon(aes(ymin=EQ1, ymax=EQ3), alpha=0.2) +
    	  geom_line(aes(y=EMB, colour="EMB"), size=1) +
		  geom_ribbon(aes(ymin=IQ1, ymax=IQ3), alpha=0.2) +
    	  geom_line(aes(y=INH, colour="INH"), size=1) +
		  scale_y_continuous(breaks = laby, labels = namesy) +
		  scale_x_continuous(breaks = labx, labels = namesx) 

	pl +  xlab("Time (Days after therapy start)") + 
		  ylab(ytext) +
 		  scale_colour_manual(name = 'Simulations', 
                              values = c('SOC'='darkgreen','EMB'='blue', 'INH'='red'),
							  breaks = c("SOC", "EMB", "INH"),
							  labels = c('SoC','REMox EMB', 'REMox INH')) +		
		  theme(legend.justification=c(1,1), legend.position=c(1,1),
		        legend.background = element_rect(fill=alpha('white', 1.0)),
		        legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 	
}
#=============================================
if (isFig12==1){
	subTitle <- ""
	mainTitle <- "Total Mtb Bacteria (all compartments)"
	nTime <- 360
	timePeriods <- 1:nTime

	folder2 <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/StandardOfCare/"
	
	y1 <- read.table(paste(folder2, "Bt_I2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y1  <- makeDF(y1, "y1m")
	y2 <- read.table(paste(folder2, "Bt_I1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2  <- makeDF(y2, "y2m")
	y3 <- read.table(paste(folder2, "Bt_I0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3  <- makeDF(y3, "y3m")

	y4 <- read.table(paste(folder2, "Bt_II2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y4  <- makeDF(y4, "y1m")
	y5 <- read.table(paste(folder2, "Bt_II1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y5  <- makeDF(y5, "y2m")
	y6 <- read.table(paste(folder2, "Bt_II0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y6  <- makeDF(y6, "y3m")
	
	y1$y1m <- y1$y1m + y4$y1m
	y2$y2m <- y2$y2m + y5$y2m
	y3$y3m <- y3$y3m + y6$y3m
	if (1>0) {
	y7 <- read.table(paste(folder2, "Bt_III2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y7  <- makeDF(y7, "y1m")
	y8 <- read.table(paste(folder2, "Bt_III1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y8  <- makeDF(y8, "y2m")
	y9 <- read.table(paste(folder2, "Bt_III0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y9  <- makeDF(y9, "y3m")
	
	y1$y1m <- y1$y1m + y7$y1m
	y2$y2m <- y2$y2m + y8$y2m
	y3$y3m <- y3$y3m + y9$y3m	
	
	y10 <- read.table(paste(folder2, "Bt_IV2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y10  <- makeDF(y10, "y1m")
	y11 <- read.table(paste(folder2, "Bt_IV1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y11 <- makeDF(y11, "y2m")
	y12 <- read.table(paste(folder2, "Bt_IV0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y12  <- makeDF(y12, "y3m")
	
	y1$y1m <- y1$y1m + y10$y1m
	y2$y2m <- y2$y2m + y11$y2m
	y3$y3m <- y3$y3m + y12$y3m
	}
	yset <- data.frame(timePeriods, y1$y1m, y2$y2m, y3$y3m)
	
	folder2 <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/Rifaquin4mo/"
	
	y11 <- read.table(paste(folder2, "Bt_I2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y11  <- makeDF(y11, "y1m")
	y12 <- read.table(paste(folder2, "Bt_I1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y12  <- makeDF(y12, "y2m")
	y13 <- read.table(paste(folder2, "Bt_I0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y13  <- makeDF(y13, "y3m")

	y14 <- read.table(paste(folder2, "Bt_II2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y14  <- makeDF(y14, "y1m")
	y15 <- read.table(paste(folder2, "Bt_II1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y15  <- makeDF(y15, "y2m")
	y16 <- read.table(paste(folder2, "Bt_II0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y16  <- makeDF(y16, "y3m")
	
	y11$y1m <- y11$y1m + y14$y1m
	y12$y2m <- y12$y2m + y15$y2m
	y13$y3m <- y13$y3m + y16$y3m
	
	y17 <- read.table(paste(folder2, "Bt_III2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y17  <- makeDF(y17, "y1m")
	y18 <- read.table(paste(folder2, "Bt_III1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y18  <- makeDF(y18, "y2m")
	y19 <- read.table(paste(folder2, "Bt_III0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y19  <- makeDF(y19, "y3m")
	
	y11$y1m <- y11$y1m + y17$y1m
	y12$y2m <- y12$y2m + y18$y2m
	y13$y3m <- y13$y3m + y19$y3m	
	
	y110 <- read.table(paste(folder2, "Bt_IV2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y110  <- makeDF(y110, "y1m")
	y111 <- read.table(paste(folder2, "Bt_IV1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y111 <- makeDF(y111, "y2m")
	y112 <- read.table(paste(folder2, "Bt_IV0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y112  <- makeDF(y112, "y3m")
	
	y11$y1m <- y11$y1m + y110$y1m
	y12$y2m <- y12$y2m + y111$y2m
	y13$y3m <- y13$y3m + y112$y3m
	
	yset <- data.frame(yset, y11$y1m, y12$y2m, y13$y3m)		# append more data
	
	folder2 <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/Rifaquin6mo/"
		
	y21 <- read.table(paste(folder2, "Bt_I2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y21  <- makeDF(y21, "y1m")
	y22 <- read.table(paste(folder2, "Bt_I1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y22  <- makeDF(y22, "y2m")
	y23 <- read.table(paste(folder2, "Bt_I0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y23  <- makeDF(y23, "y3m")

	y24 <- read.table(paste(folder2, "Bt_II2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y24  <- makeDF(y24, "y1m")
	y25 <- read.table(paste(folder2, "Bt_II1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y25  <- makeDF(y25, "y2m")
	y26 <- read.table(paste(folder2, "Bt_II0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y26  <- makeDF(y26, "y3m")
	
	y21$y1m <- y21$y1m + y24$y1m
	y22$y2m <- y22$y2m + y25$y2m
	y23$y3m <- y23$y3m + y26$y3m
	
	y27 <- read.table(paste(folder2, "Bt_III2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y27  <- makeDF(y27, "y1m")
	y28 <- read.table(paste(folder2, "Bt_III1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y28  <- makeDF(y28, "y2m")
	y29 <- read.table(paste(folder2, "Bt_III0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y29  <- makeDF(y29, "y3m")
	
	y21$y1m <- y21$y1m + y27$y1m
	y22$y2m <- y22$y2m + y28$y2m
	y23$y3m <- y23$y3m + y29$y3m	
	
	y210 <- read.table(paste(folder2, "Bt_IV2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y210  <- makeDF(y210, "y1m")
	y211 <- read.table(paste(folder2, "Bt_IV1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y211 <- makeDF(y211, "y2m")
	y212 <- read.table(paste(folder2, "Bt_IV0.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y212  <- makeDF(y212, "y3m")
	
	y21$y1m <- y21$y1m + y210$y1m
	y22$y2m <- y22$y2m + y211$y2m
	y23$y3m <- y23$y3m + y212$y3m
	
	yset <- data.frame(yset, y21$y1m, y22$y2m, y23$y3m)		# append more data
	
	names <- c("time", "SoCQ1", "SOC", "SoCQ3", "M4Q3", "M4M", "M4Q1", "M6Q3", "M6M", "M6Q1")
	colnames(yset) <- names
	yset$M4M[300:360] <- NA
	yset$M4Q1[300:360] <- NA
	yset$M4Q3[300:360] <- NA
	
	yset <- subset(yset, time>180)
	
	# Prepare data for subset
	#yset <- yset[seq(1, nrow(yset), 10), ]	# sample every 10th point to plot
	
	yset$SOC	<- log(yset$SOC)
	yset$SoCQ1	<- log(yset$SoCQ1)
	yset$SoCQ3	<- log(yset$SoCQ3)
	
	yset$M4M	<- log(yset$M4M)
	yset$M4Q1	<- log(yset$M4Q1)
	yset$M4Q3	<- log(yset$M4Q3)

	yset$M6M	<- log(yset$M6M)
	yset$M6Q1	<- log(yset$M6Q1)
	yset$M6Q3	<- log(yset$M6Q3)
	
	# set axis text and labels
	plot.main	<- mainTitle
	plot.sub	<- subTitle
	ytext <- "Cells/mL"
	laby	<- log(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000)) 
	namesy	<- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6)
	labx	<- c(180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx	<- c(0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	
	# Generate plot
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +
		  geom_ribbon(aes(ymin=SoCQ1, ymax=SoCQ3), alpha=0.2) +
    	  geom_line(aes(y=SOC, colour="SOC"), size=1) +
          geom_ribbon(aes(ymin=M4Q1, ymax=M4Q3), alpha=0.2) +
    	  geom_line(aes(y=M4M, colour="M4M"), size=1) +
		  geom_ribbon(aes(ymin=M6Q1, ymax=M6Q3), alpha=0.2) +
    	  geom_line(aes(y=M6M, colour="M6M"), size=1) +
		  scale_y_continuous(breaks = laby, labels = namesy) +
		  scale_x_continuous(breaks = labx, labels = namesx) 

	pl + 	xlab("Time (Days after therapy start)") + 
			ylab(ytext) +
  		    scale_colour_manual(name = 'Simulations', 
                              values = c('SOC'='darkgreen','M4M'='blue', 'M6M'='red'),
							  breaks = c("SOC", "M4M", "M6M"),
							  labels = c('SoC','RIFQ 4mo', 'RIFQ 6mo')) +		
		    theme(legend.justification=c(1,1), legend.position=c(1,1),
		        legend.background = element_rect(fill=alpha('white', 1.0)),
		        legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
			ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 	
}
#=================================
# Pt infection outcome - multiple simulation iterations
if (isFig13==1) {
	subTitle <- "Share of population without Acute TB"
	nTime <- 360
	timePeriods <- 1:nTime
	
	folder <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/REMoxEMB/"
	
	y1	<- read.table(paste(folder, "countAcuteTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y1	<- 1 - y1
	
	y1  <- makeDFQ(y1, "y1m", "y1q1", "y1q3")
	c1	<- c("EMB", "EMBq1", "EMBq3")
	
	folder <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/REMoxINH/"
	
	y2	<- read.table(paste(folder, "countAcuteTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2	<- 1 - y2
	y2  <- makeDFQ(y2, "y2m", "y2q1", "y2q3")
	c2	<- c("INH", "INHq1", "INHq3")
	
	folder <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/StandardOfCare/"
	
	y3	<- read.table(paste(folder, "countAcuteTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3	<- 1 - y3
	
	y3  <- makeDFQ(y3, "y3m", "y3q1", "y3q3")
	c3	<- c("SOC", "SOCq1", "SOCq3")
		
	yset <- data.frame(timePeriods, y1$y1m, y1$y1q1, y1$y1q3, y2$y2m, y2$y2q1, y2$y2q3, 
		                            y3$y3m, y3$y3q1, y3$y3q3)
	yset$y1.y1m[300:360]  <- NA
	yset$y1.y1q1[300:360] <- NA
	yset$y1.y1q3[300:360] <- NA
	yset$y2.y2m[300:360]  <- NA
	yset$y2.y2q1[300:360] <- NA
	yset$y2.y2q3[300:360] <- NA
	
	mainTitle   <- "Patient Population Treatment Outcome"
	c5 <- c("time",c1, c2, c3)
	colnames(yset) <- c5
	yset <- subset(yset, time>180)

	# combine the different data sets into single data table
	colnames(yset) <- c5
	dfm <- melt(yset, id='time')
	dfm <- dfm[seq(1, nrow(dfm), 10), ]
	
	plot.main	<- mainTitle
	plot.sub	<- subTitle
	
	labx	<- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx	<- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby	<- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy	<- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)

	# Generate plot
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +          
		  geom_ribbon(aes(ymin=INHq1, ymax=INHq3), alpha=0.2) +
		  geom_line(aes(y=INH, colour="INH"), size=1) +
		
		  geom_ribbon(aes(ymin=SOCq1, ymax=SOCq3), alpha=0.2) +
		  geom_line(aes(y=SOC, colour="SOC"), size=1) +
		
		  geom_ribbon(aes(ymin=EMBq1, ymax=EMBq3), alpha=0.2) +
		  geom_line(aes(y=EMB, colour="EMB"), size=1)
		

	pl +  xlab("Time (Days since first drug start)") + 
		  ylab("Share of patient population (%)") +
		  scale_x_continuous(breaks = labx, labels = namesx) +
	      scale_y_continuous(breaks = laby , labels = namesy, limits = c(0,100)) +
		  scale_colour_manual(name = 'Simulations', 
                              values = c('SOC'='darkgreen','EMB'='blue', 'INH'='red'),
							  breaks = c("SOC", "EMB", "INH"),
							  labels = c('SoC','REMox EMB', 'REMox INH')) +		
		  theme(legend.justification=c(0,1), legend.position=c(0,1),
		        legend.background = element_rect(fill=alpha('white', 1.0)),
		        legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +

		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 	
}
#=================================
# Pt infection outcome - multiple simulation iterations
if (isFig14==1) {
	subTitle <- "Share of population without Acute TB"
	nTime <- 360
	timePeriods <- 1:nTime
	
	folder <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/Rifaquin4mo/"
	
	y1	<- read.table(paste(folder, "countAcuteTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y1	<- 1 - y1
	y1  <- makeDFQ(y1, "y1m", "y1q1", "y1q3")
	c1	<- c("R4M", "R4Mq1", "R4Mq3")
	
	folder <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/Rifaquin6mo/"
	
	y2	<- read.table(paste(folder, "countAcuteTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2	<- 1 - y2
	y2  <- makeDFQ(y2, "y2m", "y2q1", "y2q3")
	c2	<- c("R6M", "R6Mq1", "R6Mq3")
	
	folder <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/Saved/StandardOfCare/"
	
	y3	<- read.table(paste(folder, "countAcuteTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3	<- 1 - y3
	y3  <- makeDFQ(y3, "y3m", "y3q1", "y3q3")
	c3	<- c("SOC", "SOCq1", "SOCq3")
		
	yset <- data.frame(timePeriods, y1$y1m, y1$y1q1, y1$y1q3, y2$y2m, y2$y2q1, y2$y2q3, 
		                            y3$y3m, y3$y3q1, y3$y3q3)
	yset$y1.y1m[300:360]  <- NA
	yset$y1.y1q1[300:360] <- NA
	yset$y1.y1q3[300:360] <- NA
	#yset$y2.y2m[300:360]  <- NA
	#yset$y2.y2q1[300:360] <- NA
	#yset$y2.y2q3[300:360] <- NA
	
	mainTitle   <- "Patient Population Treatment Outcome"
	c5 <- c("time",c1, c2, c3)
	colnames(yset) <- c5
	
	yset <- subset(yset, time>180)

	# combine the different data sets into single data table
	colnames(yset) <- c5
	dfm <- melt(yset, id='time')
	dfm <- dfm[seq(1, nrow(dfm), 10), ]
	
	plot.main	<- mainTitle
	plot.sub	<- subTitle
	
	labx	<- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx	<- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby	<- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy	<- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100)

	# Generate plot
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +
		  
		  geom_ribbon(aes(ymin=SOCq1, ymax=SOCq3), alpha=0.2) +
		  geom_line(aes(y=SOC, colour="SOC"), size=1) +
          
		  geom_ribbon(aes(ymin=R4Mq1, ymax=R4Mq3), alpha=0.2) +
		  geom_line(aes(y=R4M, colour="R4M"), size=1) +
          
		  geom_ribbon(aes(ymin=R6Mq1, ymax=R6Mq3), alpha=0.2) +
		  geom_line(aes(y=R6M, colour="R6M"), size=1) 
		

	pl +  xlab("Time (Days since first drug start)") + 
		  ylab("Share of patient population (%)") +
		  scale_x_continuous(breaks = labx, labels = namesx) +
	      scale_y_continuous(breaks = laby , labels = namesy, limits=c(0,100)) +
		  scale_colour_manual(name = 'Simulations', 
                              values = c('SOC'='darkgreen', 'R4M'='blue', 'R6M'='red'), 
 							  breaks = c("SOC", "R4M", "R6M"),
							  labels = c('SoC','RIFQ 4mo', 'RIFQ 6mo')) +
		  theme(legend.justification=c(0,1), legend.position=c(0,1),
		        legend.background = element_rect(fill=alpha('white', 1.0)),
		        legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +

		  ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 	
}