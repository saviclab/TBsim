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
# Date: Dec 14, 2013
# 
# Directory used for data files:
folder <- "C:/WorkFiles/UCSF_BTS/TB_11302013/DataFiles/"
#===================================================================
# Run settings
isPK		<- 0	# PK profiles - outside granuloma
isPK2		<- 0	# PK profiles - inside granuloma
isGran		<- 0	# Granuloma formation status
isB_I		<- 1	# Total bacteria in compartment I
isB_II		<- 1	# Total bacteria in compartment II
isB_III		<- 1	# Total bacteria in compartment III
isB_IV		<- 1	# Total bacteria in compartment IV
isBer		<- 0	# Resistant extracellular bacteria
isBir		<- 0	# Resistant intracellular bacteria
isM_12		<- 1	# Macrophages in compartment I and II
isM_34		<- 1	# Macrophages in compartment III and IV
isIL_Lung	<- 0	# IL4, IL10, IL12, IFN
isIL12LN	<- 0	# IL12LN
isIDCMDC	<- 0	# IDC and MDC
isT1T2		<- 0	# T1, T2
isTpTpLN	<- 0	# Tp, TpLN
isTLN		<- 0	# TLN (naive T- cell)
isOutcome   <- 1	# Create Outcome chart
isPtStatus  <- 1    # pt infection status
#====================================================================
# Read header file information
y <- read.table(paste(folder, "Header.txt", sep=""), header=FALSE,sep="\t")
y <- t(y)
timeStamp <- as.numeric(y[1])
nTime <- as.numeric(y[2])
nSteps <- as.numeric(y[3])
nPatients <- as.numeric(y[4])

isResistance <- as.numeric(y[5])
isImmuneKill <- as.numeric(y[6])
isGranuloma <- as.numeric(y[7])
diseaseText <- y[8]
nDrugs <- as.numeric(y[9])
doseText <- y[10]

isOutcome <- as.numeric(y[11])
outcomeIter <- as.numeric(y[12])
outcomeLimit <- as.numeric(y[13])

drug <- vector()
for (i in 1:nDrugs) {
	drug[i]<- y[13+i]
}

rText <- "Resist. OFF"
if (isResistance>0) {
rText <-"Resist. ON"}

iText <- "Immune OFF"
if (isImmuneKill>0) {
iText <- "Immune ON"}

gText <- "Gran. OFF"
if (isGranuloma>0) {
	gText <- "Gran. ON"}
	
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
			ylim=range(c(1,1e9)),  yaxt="n", 
			col = 'blue', type = 'l', lty=c(1:3)))
	axis(2, at=10^c(0,1,2,3,4,5,6,7,8,9), 
		 labels=expression(10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9), las=1) 
	grid()
	title(titleText, line=2)
	title(paste(nPatients, " patients; ",
		        doseText,  "; ",
 				rText,     "; ",
				gText,     "; ",
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
			ylim=range(c(1e-2,1e9)),  yaxt="n", 
			col = c('blue', 'red', 'darkgreen', 'grey'), type = 'l', lwd=2, lty=1))
		axis(2, at=10^c(-2,-1,0,1,2,3,4,5,6,7,8,9), 
			labels=expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9), las=1)
 	}
	if (logG==0) {
		ts.plot(yset, gpars=list(xlab="Time (Days from Initial Infection)", 
			ylab = "Count (Cells/ml)", yaxt="n",
			col = c('blue', 'red', 'darkgreen', 'grey'), type = 'l', lwd=2, lty=1))
		axis(2, las=1)
	}
	grid()
	title(titleText, line=2)
	title(paste(nPatients, " patients; ",
		        doseText,  "; ",
 				rText,     "; ",
				gText,     "; ",
				iText,     "]",
				sep=""), line=1, cex.main = 0.8, font.main=1)

	# Add line for drug start
	abline(v=180, col = "darkgreen", lty=3)
	points(180, 0.01, col = "darkgreen", pch=16)
	text(180, 0.01, "drug start", cex=0.8, pos=2)
	
	op <- par(bg="white")
	legend('topright', names,
		lty=c(1,1,1,1), lwd=c(2,2,2,2), col=c('blue', 'red', 'darkgreen', "grey"), inset = 0.01, cex=0.8)
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

# Granuloma formation status
if (isGran==1) {
	y1 <- read.table(paste(folder, "granuloma_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Granuloma formation status [0..1]"
	singlePlot(rbind(y1,y1), c("Granuloma","a"), 0, timePeriods, titleText)
}

# Compartment I
if (isB_I==1){
	y  <- read.table(paste(folder, "Bt_I_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yh <- read.table(paste(folder, "Bt_I_q3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yl <- read.table(paste(folder, "Bt_I_q1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Total Mtb Bacteria: Non-Granuloma | Outside Macrophage"
	rangePlot(y, yh, yl, timePeriods, titleText)
}

# Compartment II
if (isB_II==1) {
	y  <- read.table(paste(folder, "Bt_II_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yh <- read.table(paste(folder, "Bt_II_q3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yl <- read.table(paste(folder, "Bt_II_q1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Total Mtb Bacteria: Non-Granuloma | Inside Macrophage"
	rangePlot(y, yh, yl, timePeriods, titleText)
}

# Compartment III
if (isB_III==1){
	y  <- read.table(paste(folder, "Bt_III_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yh <- read.table(paste(folder, "Bt_III_q3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yl <- read.table(paste(folder, "Bt_III_q1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Total Mtb Bacteria: Granuloma | Outside Macrophage"
	rangePlot(y, yh, yl, timePeriods, titleText)
}

# Compartment IV
if (isB_IV==1) {
	y  <- read.table(paste(folder, "Bt_IV_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yh <- read.table(paste(folder, "Bt_IV_q3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	yl <- read.table(paste(folder, "Bt_IV_q1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Total Mtb Bacteria: Granuloma | Inside Macrophage"
	rangePlot(y, yh, yl, timePeriods, titleText)
}
# Extracellular resistant bacteria
if (isBer==1) {
	y1 <- read.table(paste(folder, "Be_1m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Be_2m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "Be_3m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Total Extracellular Resistant Mtb Bacteria in Lung"
	singlePlot(rbind(y1, y2, y3), drug, 1, timePeriods, titleText)
}

# Intracellular resistant bacteria
if (isBir==1) {
	y1 <- read.table(paste(folder, "Bi_1m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Bi_2m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "Bi_3m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Total Intracellular Resistant Mtb Bacteria in Lung"
	singlePlot(rbind(y1, y2, y3), drug, 1, timePeriods, titleText)
}

# Macrophages - compartment I & II
if (isM_12==1) {
	y1 <- read.table(paste(folder, "Ma_12_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Mi_12_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "Mr_12_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Macrophage Dynamics - compartment I & II"
	singlePlot(rbind(y1, y2, y3), c("Ma", "Mi", "Mr"), 1, timePeriods, titleText)
}

# Macrophages - compartment III & IV
if (isM_34==1) {
	y1 <- read.table(paste(folder, "Ma_34_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Mi_34_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "Mr_34_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Macrophage Dynamics - compartment III & IV"
	singlePlot(rbind(y1, y2, y3), c("Ma", "Mi", "Mr"), 1, timePeriods, titleText)
}

# Pt infection status (no TB, Acute TB, Latent TB, Cleared TB)	
if (isPtStatus==1) {
	y1 <- read.table(paste(folder, "countNoTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "countAcuteTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "countLatentTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y4 <- read.table(paste(folder, "countClearedTB.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Patient Infection Status"
	
	yint <- t(rbind(y1/nPatients, y2/nPatients, y3/nPatients, y4/nPatients))
	yset <- yint[timePeriods,]
	colnames(yset) <- c("No TB","Acute TB", "Latent TB", "Cleared TB")

	# Generate plot
	dev.new()
	ts.plot(yset, gpars=list(xlab="Time (Days from Initial Infection)", 
			ylab = "Share of patient population (%)", yaxt="n",
			col = c('blue', 'red', 'darkgreen', 'grey'), type = 'l', lwd=2, lty=1)) 
		    axis(2, las=1)
	grid()
	title(titleText, line=2)
	title(paste(nPatients, " patients; ",
		        doseText,  "; ",
 				rText,     "; ",
				gText,     "; ",
				iText,     "]",
				sep=""), line=1, cex.main = 0.8, font.main=1)

	# Add line for drug start
	abline(v=180, col = "darkgreen", lty=3)
	points(180, 0.01, col = "darkgreen", pch=16)
	text(180, 0.01, "drug start", cex=0.8, pos=2)
	
	op <- par(bg="white")
	legend('topright', c("No TB","Acute TB", "Latent TB", "Cleared TB"),
		lty=c(1,1,1,1), lwd=c(2,2,2,2), col=c('blue', 'red', 'darkgreen', "grey"), inset = 0.01, cex=0.8)
 	par(op)
	
}

# Cytokines in Lung, (IL4, IL10, IL12L, and IFN)	
if (isIL_Lung==1) {
	y1 <- read.table(paste(folder, "IL4_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "IL10_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "IL12L_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y4 <- read.table(paste(folder, "IFN_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Cytokines in Lung"
	singlePlot(rbind(y1, y2, y3, y4), c("IL4","IL10", "IL12L", "IFN"), 0, timePeriods, titleText)
}

# Cytokines and T cells in Lymph Node (IL12LN)
if (isIL12LN==1) {
	y1 <- read.table(paste(folder, "IL12LN_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Cytokines and Immature T cells in Lymph Node"
	singlePlot(rbind(y1,y1), c("IL12LN","a"), 0, timePeriods, titleText)
}

# Dendritic Cells, isDend (IDC and MDC)
if (isIDCMDC==1) {
	y1 <- read.table(paste(folder, "IDC_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "MDC_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Dendritic Cells (IDC and MDC)"
	singlePlot(rbind(y1,y2), c("IDC","MDC"), 0, timePeriods, titleText)
}

# T cells (T1, T2)
if (isT1T2==1) {
	y1 <- read.table(paste(folder, "T1_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "T2_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "T cells in Lung (T1, T2)"
	singlePlot(rbind(y1, y2), c("T1","T2"), 0, timePeriods, titleText)
}

# T helper cells (Tp, TpLN)
if (isTpTpLN==1) {
	y1 <- read.table(paste(folder, "Tp_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "TpLN_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "T cells in Lung (Tp, TpLN)"
	singlePlot(rbind(y1, y2), c("Tp", "TpLN"), 0, timePeriods, titleText)
}

# Naive T cells (TLN)
if (isTLN==1) {
	y1 <- read.table(paste(folder, "TLN_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	timePeriods <- 1:nTime
	titleText   <- "Naive T cells in Lymph (Naive T)"
	singlePlot(rbind(y1, y1), c("Naive T", "a"), 0, timePeriods, titleText)
}

# PK profiles
if (isPK==1){
	if (nDrugs>0){
		p1 <- read.table(paste(folder, "concIDrug0_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
		p4 <- read.table(paste(folder, "concIIDrug0_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
		p2 <- read.table(paste(folder, "concIDrug1_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
		p5 <- read.table(paste(folder, "concIIDrug1_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
		p3 <- read.table(paste(folder, "concIDrug2_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
		p6 <- read.table(paste(folder, "concIIDrug2_m.txt", sep=""), header=FALSE,sep="\t", skip=1)

		fourWeeks <- 720
		nStart <- 1
		nStop  <- fourWeeks

		dev.new()
		old.par <- par(mfrow = c(3, 2),  # 3x2 layout
				oma = c(2, 2, 5, 1), # bottom, left, top, right
				mar = c(2, 2, 0.5, 0.5), # bottom, left, top, right
				mgp = c(2, 1, 0),    # axis label at 2 rows distance, tick labels at 1 row
				xpd = NA)

# plot first row
		yMax = max(max(p1[1:fourWeeks]), max(p4[1:fourWeeks]))
		multiPlot(p1, nStart, nStop, yMax)	
		title(ylab = drug[1], line=2.5, font.lab=2)
		title("Extracellular | Outside Granuloma", line=1, font.main=1)
		axis(2, ylim=range(c(0,yMax)), las=1)
	
		if (nDrugs==1) {
			axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
		}
		multiPlot(p4, nStart, nStop, yMax)
		title("Intracellular | Outside Granuloma", line=1, font.main=1)
	
	if (nDrugs==1) {
		axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
	}
	
# plot second row
	if (nDrugs>1) {
		yMax = max(max(p2[1:fourWeeks]), max(p5[1:fourWeeks]))
		multiPlot(p2, nStart, nStop, yMax)
		title(ylab = drug[2], line=2.5, font.lab=2)
		axis(2, ylim=range(c(0,yMax)), las=1)
		if (nDrugs==2){
			axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
		}
		multiPlot(p5, nStart, nStop, yMax)
		if (nDrugs==2){
			axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
		}
	}
# plot third row
	if (nDrugs==3){
		yMax = max(max(p3[1:fourWeeks]), max(p6[1:fourWeeks]))
		multiPlot(p3, nStart, nStop, yMax)
		title(ylab = drug[3], line =2.5, font.lab=2)
		axis(2, ylim=range(c(0,yMax)), las=1)
		axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
		multiPlot(p6, nStart, nStop, yMax)
		axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
	}

	title("Drug Concentration (mg/mL) for Initial 30 Days after Drug Start", 
		  outer=TRUE, line=3, cex.main=1.5, font.main=2)
	title(paste("[", doseText, "]", sep=""), outer=TRUE, line=2, 
		  cex.main = 1.0, font.main=1)

	par(old.par)
	}
}

# PK profiles - inside granuloma
if (isPK2==1){
	if (nDrugs>0){
		p1 <- read.table(paste(folder, "concIIIDrug0_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
		p4 <- read.table(paste(folder, "concIVDrug0_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
		p2 <- read.table(paste(folder, "concIIIDrug1_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
		p5 <- read.table(paste(folder, "concIVDrug1_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
		p3 <- read.table(paste(folder, "concIIIDrug2_m.txt", sep=""), header=FALSE,sep="\t", skip=1)
		p6 <- read.table(paste(folder, "concIVDrug2_m.txt", sep=""), header=FALSE,sep="\t", skip=1)

		fourWeeks <- 720
		nStart <- 1
		nStop <-  fourWeeks

		dev.new()
		old.par <- par(mfrow = c(3, 2),  # 3x2 layout
				oma = c(2, 2, 5, 1), # bottom, left, top, right
				mar = c(2, 2, 0.5, 0.5), # bottom, left, top, right
				mgp = c(2, 1, 0),    # axis label at 2 rows distance, tick labels at 1 row
				xpd = NA)
		
# plot first row
		yMax = max(max(p1[1:fourWeeks]), max(p4[1:fourWeeks]))
		multiPlot(p1, nStart, nStop, yMax)	
		title(ylab = drug[1], line=2.5, font.lab=2)
		title("Extracellular | Inside Granuloma", line=1, font.main=1)
		axis(2, ylim=range(c(0,yMax)), las=1)
	
	if (nDrugs==1) {
		axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
	}
	multiPlot(p4, nStart, nStop, yMax)
	title("Intracellular | Inside Granuloma", line=1, font.main=1)
	if (nDrugs==1) {
		axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
	}
	
# plot second row
	if (nDrugs>1) {
		yMax = max(max(p2[1:fourWeeks]), max(p5[1:fourWeeks]))
		multiPlot(p2, nStart, nStop, yMax)
		title(ylab = drug[2], line=2.5, font.lab=2)
		axis(2, ylim=range(c(0,yMax)), las=1)
		if (nDrugs==2){
			axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
		}
		multiPlot(p5, nStart, nStop, yMax)
		if (nDrugs==2){
			axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
		}
	}
# plot third row
	if (nDrugs==3){
		yMax = max(max(p3[1:fourWeeks]), max(p6[1:fourWeeks]))
		multiPlot(p3, nStart, nStop, yMax)
		title(ylab = drug[3], line =2.5, font.lab=2)
		axis(2, ylim=range(c(0,yMax)), las=1)
		axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
		multiPlot(p6, nStart, nStop, yMax)
		axis(1, at=c(seq(1, 720-168, 168)), labels=c("Wk1", "Wk2", "Wk3", "Wk4")) 
	}

	title("Drug Concentration (mg/mL) for Initial 30 Days after Drug Start", 
		  outer=TRUE, line=3, cex.main=1.5, font.main=2)
	title(paste("[", doseText, "]", sep=""), outer=TRUE, line=2, 
		  cex.main = 1.0, font.main=1)

	par(old.par)
}
}

# Outcome plot
if (isOutcome==1) {
	y1 <- read.table(paste(folder, "Outcome_12_Bq2.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y2 <- read.table(paste(folder, "Outcome_12_Bq1.txt", sep=""), header=FALSE,sep="\t", skip=1)
	y3 <- read.table(paste(folder, "Outcome_12_Bq3.txt", sep=""), header=FALSE,sep="\t", skip=1)
	
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
	title(paste(nPatients, " patients; ",
		        doseText,  "; ",
 				rText,     "; ",
				gText,     "; ",
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