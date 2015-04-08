########################################################
# General purpose plot function for TB data
# updated to use ggplot package
# Dec 23, 2012 by John Fors
########################################################

newPlot <- function(yin, names, logG, timePeriods, mainTitle, subTitle, ytext, drugStart)
{
	# Prepare data 
	yint <- t(yin[1:(length(yin)-1)])
	yset <- data.frame(timePeriods, yint)
	colnames(yset) <- names
	dfm <- melt(yset, id='time')
	#dfm <- dfm[seq(1, nrow(dfm), 10), ]
	plot.main <- mainTitle
	plot.sub <- subTitle
	labx <-   c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	laby <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 

	# Generate plot
	dev.new()
	if(logG==1) {
		pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable, group=variable)) +
	        #geom_line(size=1) +
			stat_smooth(span=0.1, se=FALSE, size=1, method="loess") +
			scale_y_log10(breaks = trans_breaks("log10", function(x) 10^x),
                           labels = trans_format("log10", math_format(10^.x)),
		   				   limits = c(1e-2,1e9)) +
			scale_x_continuous(breaks = labx, labels = namesx)
 	}
	if (logG==0) {
		pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable, group=variable)) +
			#geom_line(size=1) +
			stat_smooth(span=0.1, se=FALSE, size=1, method="loess") +
			scale_x_continuous(breaks = labx, labels = namesx)
	}
	if (logG==2){
		pl <- ggplot(data = dfm, aes(x = time, y = value, color = variable)) +
			scale_fill_brewer(palette="Set1") +
			geom_line(size=1.0) +
#			stat_smooth(span=0.1, se=FALSE, size=1, method="loess") +
			scale_x_continuous(breaks = labx, labels = namesx) +
			scale_y_continuous(breaks = laby , labels = namesy)
	}
	pl + 	xlab("Time (Days since first drug start)") + 
			ylab(ytext) +
			theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
				  legend.background = element_rect(fill=alpha('white', 1.0)),
				  legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
			geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
			expand_limits(y=0) + 
			ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}