basePlot2 <- function(yin, plotTitle, drug)
{
	xLab <- "Time (Days since first drug start)"
	yLab = "Bactericidal effect"
	laby <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy <- c(10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	labx <-   c(60, 120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx <- c(-120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)

	# Prepare data 
	legendPosition <-"none"
	if (plotTitle == "IntraCellular Granuloma") {legendPosition <- "top"}
	
	timeSelect <- drugStart:(drugStart+360)
	yint <- t(yin[drugStart:(drugStart+360)])
	yset <- data.frame(timeSelect, yint)
	name1 <- paste(drug[1])
	name2 <- paste(drug[2])
	name3 <- paste(drug[3])
	name4 <- paste(drug[4])
	name5 <- "Immune"
	colnames(yset) <- c('time', name1, name2, name3, name4, name5)
	dfm <- melt(yset, id='time')
	#dfm <- dfm[seq(1, nrow(dfm), 10), ]
	
	# Prepare plot
   	plot1 <- ggplot(data = dfm, aes(x = time, y= value, colour=variable, fill=variable)) +
			     #stat_smooth(size=0.5, rm.na=TRUE) +
				 geom_line(size=1, rm.na=TRUE) +
				 #geom_area(rm.na=TRUE) +
  				 #scale_y_log10() +
 				 #scale_y_continuous(breaks = laby , labels = namesy) +
				 scale_x_continuous(breaks = labx, labels = namesx) +
				 scale_y_continuous(limits=c(0, 1)) +
 				 ggtitle(plotTitle) +
				 theme(plot.title = element_text(size=12, face="bold", vjust=0.5)) +
				 theme(legend.position=legendPosition, legend.text =element_text(size=8)) +
				 theme(legend.title=element_blank()) +
				 xlab(xLab) +
 				 theme(axis.title = element_text(size=10)) +
				 ylab(yLab)
				
	return (plot1)
}