#===========================================================================
# plotGranuloma.R
# Granuloma formation and breakup factors
#
# John Fors, UCSF
# Oct 6, 2014
# updates Ron Keizer, 2015
#===========================================================================
#' @export
tb_plot_granuloma <- function(info, granuloma) {

	timePeriods <- 1:info$nTime
	with(granuloma, {

		# build dataframe
		df1 <- data.frame(times, iterations, formation)
		colnames(df1) <- c("Day", "Iteration", "Formation")
		df1m <- melt(df1, id=c("Day", "Iteration"), na.rm=TRUE)

		# calculate statistics
		df1c <- cast(df1m, Day ~ variable, function(x) quantile(x, c(0.05, 0.5, 0.95)))
		colnames(df1c) <- c("Day", "Formation_05","Formation_m", "Formation_95")

		df2 <- data.frame(times, iterations, breakup)
		colnames(df2) <- c("Day", "Iteration", "Breakup")
		df2m <- melt(df2, id=c("Day", "Iteration"), na.rm=TRUE)

		# calculate statistics
		df2c <- cast(df2m, Day ~ variable, function(x) quantile(x, c(0.05, 0.5, 0.95)))
		colnames(df2c) <- c("Day", "Breakup_05","Breakup_m", "Breakup_95")

		# Prepare data
		yset <- data.frame(timePeriods, df1c$Formation_m, df1c$Formation_05, df1c$Formation_95,
										df2c$Breakup_m,   df2c$Breakup_05,   df2c$Breakup_95)
		colnames(yset)	<- c("time", "Formation_m", "Formation_05", "Formation_95",
									 "Breakup_m",   "Breakup_05", "Breakup_95")
		dfm <- yset

		xlabel <- "Time after infection start (Days)"
		ylabel <- "Factor"
		mainTitle <- "Granuloma Formation & Breakup [0..1]"

		labx	<- c(seq(0, nTime, by = 30))
		namesx	<- labx
		laby	<- c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
		namesy	<- laby

		# Generate plot
		pl <- ggplot(data = dfm, aes(x = time)) +
				geom_ribbon(aes(ymin=Formation_05, ymax=Formation_95), alpha=0.2) +
				geom_line(aes(y=Formation_m, colour="darkgreen"), size=1) +

				geom_ribbon(aes(ymin=Breakup_05, ymax=Breakup_95), alpha=0.2) +
				geom_line(aes(y=Breakup_m, colour="red"), size=1) +

				scale_x_continuous(breaks = labx, labels = namesx) +
				xlab(xlabel) +
				ylab(ylabel) +

				scale_colour_manual(name = 'Factor',
	                                values = c( 'darkgreen'='darkgreen', 'red'='red'),
								    labels = c('Formation','Break up')) +

				theme(legend.justification=c(0,1), legend.position=c(0,1), legend.title=element_blank(),
					  legend.background = element_rect(fill=alpha('white', 1.0)),
					  legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
				expand_limits(y=0) +
				theme(plot.title = element_text(size=12, vjust=2)) +
			    ggtitle(mainTitle)
		return(pl)
	})

}
