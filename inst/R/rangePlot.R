########################################################
# Plot function for bacterial medium and quartile data
# Dec 23, 2012 by John Fors
########################################################

rangePlot <- function(file_m, file_h, file_l, timePeriods, titleText, nTime)
{
	# Read file data
	y  <- read.table(paste(folder, file_m,  sep=""), header=FALSE,sep="\t", skip=1)
	yh <- read.table(paste(folder, file_h, sep=""), header=FALSE,sep="\t", skip=1)
	yl <- read.table(paste(folder, file_l, sep=""), header=FALSE,sep="\t", skip=1)
	
	# Prepare plot
	ymed <- t(y)
	ymed <- ymed[timePeriods,1]
	ylow <- t(yl)
	ylow <- ylow[timePeriods,1]
	yhigh <- t(yh)
	yhigh <- yhigh[timePeriods,1]

	yset <- cbind(ymed, yhigh, ylow)
	colnames(yset) <- c("Median", "3rd quartile", "1st quartile")

	# Generate plot
	dev.new()
	ts.plot(yset, gpars=list(log = "y", 
		    xlab="Time (Days from Initial Infection)", 
			ylab = "Bacterial load (CFU/ml)", 
			ylim=range(c(1,1e9)),  
			yaxt="n", 
			col = 'blue', 
			type = 'l', 
			lty=c(1:3)))
	axis(2, at=10^c(0,1,2,3,4,5,6,7,8,9), 
		    labels=expression(10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9), 
			las=1) 
	grid()
	title(titleText, line=2)
		
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
	
	# Add marker for drug start
	abline(v=180, col = "darkgreen", lty=3)
	points(180, 1, col = "darkgreen", pch=16)
	text(180, 1, "drug start", cex=0.8, pos=2)
	
	op <- par(bg="white")
	legend('topleft', c("Median","1st/3rd Quartiles"),
		lty=c(1,2), lwd=c(2,1), col=c('red', 'blue'), inset = 0.01, cex=0.8)
 	par(op)
}