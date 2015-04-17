#===========================================================================
# plotMacro.R
# Total macrophages
#
# John Fors, UCSF
# Oct 14, 2014
# updates Ron Keizer, 2015
#===========================================================================
#' @export
tb_plot_macro <- function(info, macro, is_from_drug_start = TRUE) {
	
	timePeriods <- 1:info$nTime
	
	with(macro, {
		# lower plot limit 
		minValue <- 1e-2
		
		# prepare data for Ma		
		# build dataframe 2
		df2c <- data.frame(times, compartments, Ma50)
		colnames(df2c) <- c("Day", "Compartment", "Median")
		df2c$Median <- pmax(df2c$Median, rep(minValue, length(df2c$Median)))
		
		# build dataframe 5
		df5c <- data.frame(times, compartments, Mr50)
		colnames(df5c) <- c("Day", "Compartment", "Median")
		df5c$Median <- pmax(df5c$Median, rep(minValue, length(df5c$Median)))
		
		# build dataframe 8
		df8c <- data.frame(times, compartments, Mi50)
		colnames(df8c) <- c("Day", "Compartment", "Median")
		df8c$Median <- pmax(df8c$Median, rep(minValue, length(df8c$Median)))
		
		# Combine data into single data frame 
		# apply log transform
		yset <- data.frame(df2c$Day, df2c$Compartment, log10(df2c$Median), 
													    log10(df5c$Median), 
													    log10(df8c$Median))
		colnames(yset)	<- c("time", "Compartment", "MaM", "MrM", "MiM")
									
		# set compartment labels
		compNames <- c("Non-Granuloma", "Granuloma")		
		xlabel <- "Time after infection start [Days]"
		if (is_from_drug_start) {
			yset <- yset[yset$time > info$drugStart,]
			xlabel <- "Time after drug start [Days]"
		}
		ylabel <- "Macrophage count [log(Cells/ml)]"		
		labx	<- c(seq(0, info$nTime, by = 30))
		namesx	<- labx
		laby	<- log10(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000)) 
		namesy	<- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9)		
		titleText <- "Macrophages "
			
		# Generate plot per compartment
		for (i in 1:2){
			yset2 <- yset[yset$Compartment==i,]			
			pl <- ggplot(data = yset2, aes(x = time)) +
	    	  geom_line(aes(y=MaM), colour="blue", size=0.5) +
	    	  geom_line(aes(y=MrM), colour="red", size=0.5) +
	    	  geom_line(aes(y=MiM), colour="darkgreen", size=0.5) +
			  theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
			  scale_y_continuous(breaks = laby, labels = namesy) +
			  scale_x_continuous(breaks = labx, labels = namesx) +
			  xlab(xlabel) + 
			  ylab(ylabel) +
			  ggtitle(paste(titleText, compNames[i])) 
			return(pl)
		}
	})

}