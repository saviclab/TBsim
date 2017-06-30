########################################################
# Generate graphs of immune cells and cytikines
# Oct 5, 2014 by John Fors
########################################################

plotImmune <- function(yset, names, mainTitle, subTitle, ytext, drugStart)
{
	# Prepare data
	colnames(yset) <- names
	dfm2		<- melt(yset, id="time", na.rm=TRUE)
	plot.main	<- mainTitle
	plot.sub	<- subTitle
	xtext		<- "Time after infection start (Days)"

	# Generate plot
	dev.new()
	pl <- ggplot(data = dfm2, aes(x = time, y = value, color = variable, group=variable)) +
			geom_line(linetype="solid", size=0.5) +
			scale_color_brewer(palette="Set1") +
			theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
				  legend.background = element_rect(fill=alpha('white', 1.0)),
				  legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
			expand_limits(y=0) +
			xlab(xtext) +
			ylab(ytext) +
			theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
			ggtitle(mainTitle)
	print(pl)
}
