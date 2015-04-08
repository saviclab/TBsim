########################################################
# General purpose plot function for TB data
# updated to use ggplot package
# Dec 23, 2012 by John Fors
########################################################

plotBact <- function(yset, names, mainTitle, subTitle, ytext, drugStart)
{
	# Prepare data 
	colnames(yset) <- names
	yset <- yset[seq(1, nrow(yset), 10), ]
	plot.main	<- mainTitle
	plot.sub	<- subTitle
	yset$Median <- log10(yset$Median)
	yset$Quartile_1 <- log10(yset$Quartile_1)
	yset$Quartile_3 <- log10(yset$Quartile_3)
	laby	<- log10(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000)) 
	namesy	<- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9)
	labx	<- c(1,    60,   120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840, 900, 960, 1020)
	namesx	<- c(-180, -120, -60, 0,   60,  120, 180, 240, 300, 360, 420, 480, 540, 600, 660, 720, 780, 840)
	
	# Generate plot
	pl <- ggplot(data = yset, aes(x = time)) +
          geom_ribbon(aes(ymin=Quartile_1, ymax=Quartile_3), alpha=0.2) +
    	  geom_line(aes(y=Median), colour="blue") +
		  scale_y_continuous(breaks = laby, labels = namesy) +
		  scale_x_continuous(breaks = labx, labels = namesx) 

	pl + 	xlab("Time (Days since first drug start)") + 
			ylab(ytext) +
			geom_vline(xintercept = drugStart, colour = "darkgreen", linetype = "dotted") +
			#annotate("text", x = 70, y = 18, label = "Median vs 1st/3rd quartiles", size=3, fontface="italic") +
			ggtitle(bquote(atop(.(plot.main), atop(italic(.(plot.sub)), "")))) 
}