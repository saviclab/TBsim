plotPK <- function(yin, yMax, yLab, xLab, names)
{
	labx   <- c(1, 96, 168, 264, 336)
	
	# Prepare data 
	timeHours <- seq(1,336)
	yint <- yin[1:336]
	yset <- data.frame(timeHours, yint)
	colnames(yset) <- c('time', "DATA")
	
	# Prepare plot
   	plot1 <- ggplot(data = yset, aes(x = time, y = DATA)) +
			     geom_line(size=0.5, colour="black", rm.na=TRUE) +
	  			 scale_x_continuous(breaks = labx, labels = names) +
 				 scale_y_continuous(limits=c(0, yMax)) +
 				 theme(axis.title.y=element_text(angle=0, size=10)) +
				 theme(axis.title.x=element_text(angle=0, size=10)) 
				 #theme(axis.title.x=element_blank()) 

	plot1 <- plot1 + ylab(yLab)
	plot1 <- plot1 + xlab(xLab)
	plot1 <- plot1 + theme(plot.margin = unit(c(0,0.5,0,0.5),"cm"))
	
	return (plot1)
}