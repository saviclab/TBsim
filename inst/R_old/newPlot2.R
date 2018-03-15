########################################################
# General purpose plot function for TB data
# updated to use ggplot package
# Dec 23, 2012 by John Fors
########################################################

newPlot2 <- function(yin, names, logG, timePeriods, mainTitle, subTitle, ytext)
{
	# Prepare data 
	timeSelect <- drugStart:(drugStart+360)
	yint <- t(yin[drugStart:(drugStart+360)])
	yset <- data.frame(timeSelect, yint)
	colnames(yset) <- names
	dfm <- melt(yset, id='time')
	dfm <- dfm[seq(1, nrow(dfm), 10), ]
	plot.main <- mainTitle
	plot.sub <- subTitle
	labx <-   c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 

	# Generate plot
	#dev.new()
	if(logG==1) {
		pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable, group=variable)) +
	        geom_line(size=1) +
			#stat_smooth(span=0.1, se=FALSE, size=1, method="loess") +
			#scale_y_log10() +
			scale_x_continuous(breaks = labx, labels = namesx)
 	}
	pl + 	xlab("Time (Days since first drug start)") + 
			ylab(ytext) +
			theme(axis.title = element_text(size=10)) +
			theme(legend.position="none") +
			geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
			expand_limits(y=0) 
			#ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}