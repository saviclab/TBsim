# Clear all
library(zoo)
rm(list=ls())
graphics.off()
#===================================================================
# Simulation of TB infection and treatment dynamics 
# 
# Program used to visualize calc output from C++ simulation
#
# Author: John Fors
# Date: Oct 7, 2013
# 
# Directory used for data files:
folder <- "C:/WorkFiles/UCSF_BTS/TB_06162013/DataFiles/"
#===================================================================
# Run settings
isPK		<- 0	# PK profiles
isBi		<- 0	# Total intracellular bacteria
isBe		<- 0	# Total extracellular bacteria
isBer		<- 0	# Resistant extracellular bacteria
isBir		<- 0	# Resistant intracellular bacteria
isM			<- 0	# Macrophages (Ma, Mr, and Mi)
isIL_Lung	<- 0	# IL4, IL10, IL12L, and IFN
isLN		<- 0	# IL12LN and T in LN
isDend		<- 0	# IDC and MDC
isT1T2		<- 0	# T1, T2
#isTpLTpLN	<- 1	# TpL and TpLN
isOutcome   <- 1	# create Outcome chart
#====================================================================
# Read header file information
y <- read.table(paste(folder, "Header.txt", sep=""), header=FALSE,sep="\t")
y <- t(y)
nTime <- as.numeric(y[1])
nSteps <- as.numeric(y[2])
nPatients <- as.numeric(y[3])

isResistance <- as.numeric(y[4])
isImmuneKill <- as.numeric(y[5])
diseaseText <- y[6]
nDrugs <- as.numeric(y[7])
doseText <- y[8]

isOutcome <- as.numeric(y[9])
outcomeIter <- as.numeric(y[10])
outcomeLimit <- as.numeric(y[11])

drug <- vector()
for (i in 1:nDrugs) {
	drug[i]<- y[11+i]
}

rText <- "Resist. OFF"
if (isResistance>0) {
rText <-"Resist. ON"}

iText <- "Immune OFF"
if (isImmuneKill>0) {
	iText <- "Immune ON"}
	
# Plot function for medium and quartiles
rangePlot <- function(y, yh, yl, timePeriods, titleText ){
	ymed <- t(y)
	ymed <- ymed[1:nTime,1]
	ylow <- t(yl)
	ylow <- ylow[1:nTime,1]
	yhigh <- t(yh)
	yhigh <- yhigh[1:nTime,1]

	yset <- cbind(ymed, yhigh, ylow)
	colnames(yset) <- c("Median", "3rd quartile", "1st quartile")

	# Generate plot
	dev.new()
	ts.plot(yset, gpars=list(log = "y", xlab="Time (Days from Initial Infection)", 
			ylab = "Bacterial load (CFU/ml)", 
			ylim=range(c(1,1e8)),  yaxt="n", 
			col = 'blue', type = 'l', lty=c(1:3)))
	axis(2, at=10^c(0,1,2,3,4,5,6,7,8), 
		 labels=expression(10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8), las=1) 
	grid()
	title(titleText, line=2)
	title(paste("[", diseaseText,"; ", 
				nPatients, " patients; ",
		        doseText,  "; ",
 				rText,     "; ",
				iText,     "]",
				sep=""), line=1, cex.main = 0.8, font.main=1)
		
	ylowlim <- rep(0.5, nTime)
	ylowm   <-pmax(ylow,  ylowlim)
	yhighm  <-pmax(yhigh, ylowlim)
	ymedm   <-pmax(ymed,  ylowlim)

	# Add shading
	polygon(c(timePeriods,rev(timePeriods)),c(ymedm,rev(ylowm)), col="lightgrey", border=NA)
	polygon(c(timePeriods,rev(timePeriods)),c(ymedm,rev(yhighm)),col="lightgrey", border=NA)
	points(x=timePeriods, y=ymed,  col='red',  type='l', lwd=2, lty=1)
	points(x=timePeriods, y=ylow,  col='blue', type='l', lwd=1, lty=2)
	points(x=timePeriods, y=yhigh, col='blue', type='l', lwd=1, lty=2)
	
	abline(v=180, col = "darkgreen", lty=3)
	points(180, 1, col = "darkgreen", pch=16)
	text(180, 1, "drug start", cex=0.8, pos=2)
	
	op <- par(bg="white")
	legend('topright', c("Median","1st/3rd Quartiles"),
		lty=c(1,2), lwd=c(2,1), col=c('red', 'blue'), inset = 0.01, cex=0.8)
 	par(op)
}

# Plot function for single line plot for resistant bacteria
singlePlot <- function(yin, names, logG, timePeriods, titleText ){
	yint <- t(yin)
	yset <- yint[timePeriods,]
	colnames(yset) <- names

	# Generate plot
	dev.new()
	if(logG==1) {
		ts.plot(yset, gpars=list(log = "y", xlab="Time (Days from Initial Infection)", 
			ylab = "Bacterial load (CFU/ml)", 
			ylim=range(c(1e-2,1e8)),  yaxt="n", 
			col = c('blue', 'red', 'darkgreen', 'grey'), type = 'l', lwd=2, lty=1))
		axis(2, at=10^c(-2,-1,0,1,2,3,4,5,6,7,8), 
			labels=expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8), las=1)
 	}
	if (logG==0) {
		ts.plot(yset, gpars=list(xlab="Time (Days from Initial Infection)", 
			ylab = "Count (Cells/ml)", yaxt="n",
			col = c('blue', 'red', 'darkgreen', 'grey'), type = 'l', lwd=2, lty=1))
		axis(2, las=1)
	}
	grid()
	title(titleText, line=2)
	title(paste("[", diseaseText,"; ", 
				nPatients, " patients; ",
		        doseText,  "; ",
 				rText,     "; ",
				iText,     "]",
				sep=""), line=1, cex.main = 0.8, font.main=1)

	# Add line for drug start
	abline(v=180, col = "darkgreen", lty=3)
	points(180, 0.01, col = "darkgreen", pch=16)
	text(180, 0.01, "drug start", cex=0.8, pos=2)
	
	op <- par(bg="white")
	legend('topright', names,
		lty=c(1,1,1,1), lwd=c(2,2,2,2), col=c('red', 'blue', 'darkgreen', "grey"), inset = 0.01, cex=0.8)
 	par(op)
}

# Plot function for concentration intra- and extracellular
multiPlot <- function(y1, nStart, nStop, yMax){
	y1t <- t(y1)
	y1ts <- cbind(y1t[nStart:nStop,1])
	colnames(y1ts) <- c("DATA")

	# Generate plot
	ts.plot(y1ts, gpars=list(ylim=range(c(0,round(yMax)+1)), 
		xlab="", ylab="", yaxt="n", xaxt="n"), col="black", lwd=1.5)
	grid()
	
	par(new=T)
	day<-23 # 24 hours, need odd value
	ts.plot(rollmean(y1ts, day), gpars=list(ylim=range(c(0,round(yMax)+1)), 
		xlab="", ylab="", yaxt="n", xaxt="n"), col="darkgreen", lty=2)
	par(new=F)
	
	par(new=T)
	week<-167 # 24 hours * 7 days - 1, need odd value
	ts.plot(rollmean(y1ts, week), gpars=list(ylim=range(c(0,round(yMax)+1)), 
		xlab="", ylab="", yaxt="n", xaxt="n"), col="blue", lty=2)
	par(new=F)
	
	op <- par(bg="white")
	legend('topright',c("Hourly Value","Daily Avg", "Weekly Avg"),
		   lty=c(1,2,2), lwd=c(1,1,1), col=c('black','darkgreen','blue'),
		   inset = 0.01, cex=0.8)
 	par(op)
}

# Start of each specific plot definition
# Intracellular bacteria
if (isBi==1){
	y  <- read.table(paste(folder, "Bi_tm.txt", sep=""), header=FALSE,sep="\t")
	yh <- read.table(paste(folder, "Bi_t3.txt", sep=""), header=FALSE,sep="\t")
	yl <- read.table(paste(folder, "Bi_t1.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Total Intracellular Mtb Bacteria in Lung"
	rangePlot(y, yh, yl, timePeriods, titleText)
}
# Extracellular bacteria
if (isBe==1) {
	y  <- read.table(paste(folder, "Be_tm.txt", sep=""), header=FALSE,sep="\t")
	yh <- read.table(paste(folder, "Be_t3.txt", sep=""), header=FALSE,sep="\t")
	yl <- read.table(paste(folder, "Be_t1.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Total Extracellular Mtb Bacteria in Lung"
	rangePlot(y, yh, yl, timePeriods, titleText)
}
# Extracellular resistant bacteria
if (isBer==1) {
	y1 <- read.table(paste(folder, "Be_rm.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "Be_im.txt", sep=""), header=FALSE,sep="\t")
	y3 <- read.table(paste(folder, "Be_pm.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Total Extracellular Resistant Mtb Bacteria in Lung"
	singlePlot(rbind(y1, y2, y3), drug, 1, timePeriods, titleText)
}
# Intracellular resistant bacteria
if (isBir==1) {
	y1 <- read.table(paste(folder, "Bi_rm.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "Bi_im.txt", sep=""), header=FALSE,sep="\t")
	y3 <- read.table(paste(folder, "Bi_pm.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Total Intracellular Resistant Mtb Bacteria in Lung"
	singlePlot(rbind(y1, y2, y3), drug, 1, timePeriods, titleText)
}
# Macrophages
if (isM==1) {
	y1 <- read.table(paste(folder, "Ma_m.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "Mi_m.txt", sep=""), header=FALSE,sep="\t")
	y3 <- read.table(paste(folder, "Mr_m.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Macrophage Dynamics"
	singlePlot(rbind(y1, y2, y3), c("Ma", "Mi", "Mr"), 1, timePeriods, titleText)
}
# Cytokines in Lung, (IL4, IL10, IL12L, and IFN)	
if (isIL_Lung==1) {
	y1 <- read.table(paste(folder, "IL4_m.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "IL10_m.txt", sep=""), header=FALSE,sep="\t")
	y3 <- read.table(paste(folder, "IL12L_m.txt", sep=""), header=FALSE,sep="\t")
	y4 <- read.table(paste(folder, "IFN_m.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Cytokines in Lung"
	singlePlot(rbind(y1, y2, y3, y4), c("IL4","IL10", "IL12L", "IFN"), 0, timePeriods, titleText)
}
# Cytokines and T cells in Lymph Node (IL12LN & T)
if (isLN==1) {
	y1 <- read.table(paste(folder, "IL12LN_m.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "T_m.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Cytokines and Immature T cells in Lymph Node"
	singlePlot(rbind(rbind(y1, y2)), c("IL12LN", "naive T"), 0, timePeriods, titleText)
}
# Dendritic Cells, isDend (IDC and MDC)
if (isDend==1) {
	y1 <- read.table(paste(folder, "IDC_m.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "MDC_m.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "Dendritic Cells (IDC and MDC)"
	singlePlot(rbind(y1, y2), c("IDC", "MDC"), 0, timePeriods, titleText)
}
# T cells (T1, T2)
if (isT1T2==1) {
	y1 <- read.table(paste(folder, "T1_m.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "T2_m.txt", sep=""), header=FALSE,sep="\t")
	timePeriods <- 1:nTime
	titleText   <- "T cells in Lung (T1, T2)"
	singlePlot(rbind(y1, y2), c("T1","T2"), 0, timePeriods, titleText)
}
# PK profiles
if (isPK==1){
	p1 <- read.table(paste(folder, "concINHe_m.txt", sep=""), header=FALSE,sep="\t")
	p2 <- read.table(paste(folder, "concRMPe_m.txt", sep=""), header=FALSE,sep="\t")
	p3 <- read.table(paste(folder, "concPZAe_m.txt", sep=""), header=FALSE,sep="\t")
	p4 <- read.table(paste(folder, "concINHi_m.txt", sep=""), header=FALSE,sep="\t")
	p5 <- read.table(paste(folder, "concRMPi_m.txt", sep=""), header=FALSE,sep="\t")
	p6 <- read.table(paste(folder, "concPZAi_m.txt", sep=""), header=FALSE,sep="\t")

	fourWeeks <- 720
	nStart <- (180*24)##0
	nStop <-  (nStart + fourWeeks)## 600*24

	dev.new()
	old.par <- par(mfrow = c(3, 2),  # 3x2 layout
				oma = c(2, 2, 5, 1), # bottom, left, top, right
				mar = c(2, 2, 0.5, 0.5), # bottom, left, top, right
				mgp = c(2, 1, 0),    # axis label at 2 rows distance, tick labels at 1 row
				xpd = NA)

# plot first row
	yMax = max(max(p1[1:nSteps]), max(p4[1:nSteps]))
	multiPlot(p1, nStart, nStop, yMax)	
	title(ylab = "INH", line=2.5, font.lab=2)
	title("Extracellular", line=1, font.main=1)
	axis(2, ylim=range(c(0,yMax)), las=1)
	multiPlot(p4, nStart, nStop, yMax)
	title("Intracellular", line=1, font.main=1)
	
# plot second row
	yMax = max(max(p2[1:nSteps]), max(p5[1:nSteps]))
	multiPlot(p2, nStart, nStop, yMax)
	title(ylab = "RIF", line=2.5, font.lab=2)
	axis(2, ylim=range(c(0,yMax)), las=1)
	multiPlot(p5, nStart, nStop, yMax)

# plot third row
	yMax = max(max(p3[1:nSteps]), max(p6[1:nSteps]))
	multiPlot(p3, nStart, nStop, yMax)
	title(ylab = "PZA", line =2.5, font.lab=2)
	axis(2, ylim=range(c(0,yMax)), las=1)
	axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
	multiPlot(p6, nStart, nStop, yMax)
	axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 

	title("Drug Concentration (mg/mL) for Initial 30 Days after Drug Start", 
		  outer=TRUE, line=3, cex.main=1.5, font.main=2)
	title(paste("[", doseText, "]", sep=""), outer=TRUE, line=2, 
		  cex.main = 1.0, font.main=1)

	par(old.par)
}
# Outcome plot
if (isOutcome==1) {
	y1 <- read.table(paste(folder, "Outcome_Bq2.txt", sep=""), header=FALSE,sep="\t")
	y2 <- read.table(paste(folder, "Outcome_Bq1.txt", sep=""), header=FALSE,sep="\t")
	y3 <- read.table(paste(folder, "Outcome_Bq3.txt", sep=""), header=FALSE,sep="\t")
	
	ymed <- t(y1)
	ymed <- ymed[1:nTime,1]
	ylow <- t(y2)
	ylow <- ylow[1:nTime,1]
	yhigh <- t(y3)
	yhigh <- yhigh[1:nTime,1]
	
	timePeriods <- 1:nTime
	yset <- cbind(ymed, ylow, yhigh)
	colnames(yset) <- c("Median", "1st quartile", "3rd quartile")
	
	dev.new()
	day <- 7 # 3 days (note: need odd value)
	ts.plot(rollmean(yset, day), gpars=list(xlab="Time (Days from Initial Infection)", 
			ylab = "Share of patients resolved",  yaxt="n", ylim=range(c(0,1)),
			col = c('red', 'blue', 'blue'), type = 'l', lwd=c(2,1,1), lty=c(1,2,2)))
	axis(2, las=1)
	titleText   <- "Summary of Therapy Outcome"
	grid()

	ylowlim <- rep(0.0, nTime)
	ymedm   <-pmax(y1[1:nTime,1], ylowlim)
	ylowm   <-pmax(y2[1:nTime,1], ylowlim)
	yhighm  <-pmax(y3[1:nTime,1], ylowlim)
	
	grid()
	title(titleText, line=2)
	title(paste("[", diseaseText,"; ", 
				nPatients, " patients; ",
		        doseText,  "; ",
 				rText,     "; ",
				iText,     "]",
				sep=""), line=1, cex.main = 0.8, font.main=1)
			
	# Add line for drug start
	abline(v=180, col = "darkgreen", lty=3)
	points(180, 0.05, col = "darkgreen", pch=16)
	text(180, 0.05, "drug start", cex=0.8, pos=2)
	
	text(-20,0.89, paste("Threshold: ",outcomeLimit, sep=""), cex=0.8, pos=4)
	text(-20,0.85, paste("Iterations: ",outcomeIter, sep=""), cex=0.8, pos=4)
			
	op <- par(bg="white")
	legend('topleft', c("Median","1st/3rd Quartiles"),
		lty=c(1,2), lwd=c(2,1), col=c('red', 'blue'), inset = 0.01, cex=0.8)
 	par(op)
}