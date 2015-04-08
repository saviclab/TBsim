########################################################
# General purpose plot function for Tb data
# Dec 23, 2012 by John Fors
########################################################

singlePlot <- function(yin, names, logG, timePeriods, titleText, ytext )
{
	yint <- t(yin)
	yset <- yint[timePeriods,]
	colnames(yset) <- names

	# Generate plot
	dev.new()
	if(logG==1) {
		ts.plot(yset, gpars=list(log = "y", xlab="Time (Days from Initial Infection)", 
			ylab = ytext, 
			ylim=range(c(1e-2,1e9)),  
			yaxt="n", 
			col = c('blue', 'red', 'darkgreen', 'grey'), 
			type = 'l', 
			lwd=2, 
			lty=1))
		axis(2, at=10^c(-2,-1,0,1,2,3,4,5,6,7,8,9), 
			labels=expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9), 
			las=1)
 	}
	if (logG==0) {
		ts.plot(yset, gpars=list(xlab="Time (Days from Initial Infection)", 
			ylab = ytext, 
			yaxt="n",
			col = c('blue', 'red', 'darkgreen', 'grey'), 
			type = 'l', 
			lwd=2, 
			lty=1))
		axis(2, las=1)
	}
	grid()
	title(titleText, line=2)

	# Add line for drug start
	abline(v=180, col = "darkgreen", lty=3)
	points(180, 0.01, col = "darkgreen", pch=16)
	text(180, 0.01, "drug start", cex=0.8, pos=2)
	
	op <- par(bg="white")
	legend('topleft', names,
		lty=c(1,1,1,1), lwd=c(2,2,2,2), col=c('blue', 'red', 'darkgreen', "grey"), inset = 0.01, cex=0.8)
 	par(op)
}
