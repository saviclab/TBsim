basePlot <- function(yin, mainTitle, yMax, yLab, names)
{
	labx   <- c(1, 96, 168, 264, 336)
	xLab = "Time"
	if (names[1]=="") {xLab = ""}
	# Prepare data 
	timeHours <- seq(1,336)
	#yint <- t(yin[1:336])
	yint <- yin[1:336]
	yset <- data.frame(timeHours, yint)
	colnames(yset) <- c('time', "DATA")
	
	# rolling average
	temp.zoo<- zoo(yset$DATA,yset$time)

	#Calculate moving average with window 3 and make first and last value as NA (to ensure identical length of vectors)
	m.av<-rollmean(temp.zoo, 23, fill = list(NA, NULL, NA))
	yset$DATA.av=coredata(m.av)
	
	# Prepare plot
   	plot1 <- ggplot(data = yset, aes(x = time, y = DATA)) +
			     geom_line(size=0.5, colour="black", rm.na=TRUE) +
				 geom_line(aes(time,DATA.av), size=0.5, colour="blue", rm.na=TRUE) +
	  			 scale_x_continuous(breaks = labx, labels = names) +
 				 scale_y_continuous(limits=c(0, yMax)) +
 				 theme(axis.title.y=element_text(angle=0, size=10)) +
				 theme(axis.title.x=element_blank()) 

	plot1 <- plot1 + ylab(yLab)
	if (names[1]=="") {plot1<- plot1 + labs(x=NULL)}
	if (yLab=="") {plot1<- plot1 + labs(y=NULL)}

	plot1 <- plot1 + theme(plot.margin = unit(c(0,0.5,0,0.5),"cm"))
	
	return (plot1)
}