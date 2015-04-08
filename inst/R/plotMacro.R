#===========================================================================
# plotMacro.R
# Total macrophages
#
# John Fors, UCSF
# Oct 14, 2014
#===========================================================================
plotMacro <- function(){

	# read header file
	list <- readHeaderFile(folder)
	timeStamp		<- list[[1]] 
	nTime			<- list[[2]]
	nSteps			<- list[[3]]
	drugStart		<- list[[4]]
	nPatients		<- list[[5]]
	isResistance	<- list[[6]]
	isImmuneKill	<- list[[7]]
	isGranuloma		<- list[[8]]
	isPersistance   <- list[[9]]
	diseaseText		<- list[[10]]
	nDrugs			<- list[[11]]
	doseText		<- list[[12]]
	outcomeIter		<- list[[13]]
	drug			<- list[[14]]
	
	timePeriods <- 1:nTime
	
	output <- readMacro(folder, "macro.txt", "macro")
	times <- output[[1]]
	compartments  <- output[[2]]
	#Ma25 <- output[[3]]
	Ma50 <- output[[3]]
	#Ma75 <- output[[5]]
	#Mr25 <- output[[6]]
	Mr50 <- output[[4]]
	#Mr75 <- output[[8]]
	#Mi25 <- output[[9]]
	Mi50 <- output[[5]]
	#Mi75 <- output[[11]]

	# lower plot limit 
	minValue <- 1e-2
	
	# prepare data for Ma
	# build dataframe 1
	#df1c <- data.frame(times, compartments, Ma25)
	#colnames(df1c) <- c("Day", "Compartment", "Q1")
	#df1c$Q1 <- pmax(df1c$Q1, rep(minValue, length(df1c$Q1)))
	
	# build dataframe 2
	df2c <- data.frame(times, compartments, Ma50)
	colnames(df2c) <- c("Day", "Compartment", "Median")
	df2c$Median <- pmax(df2c$Median, rep(minValue, length(df2c$Median)))
	
	# build dataframe 3
	#df3c <- data.frame(times, compartments, Ma75)
	#colnames(df3c) <- c("Day", "Compartment", "Q3")
	#df3c$Q3 <- pmax(df3c$Q3, rep(minValue, length(df3c$Q3)))
	
	# build dataframe 4
	#df4c <- data.frame(times, compartments, Mr25)
	#colnames(df4c) <- c("Day", "Compartment", "Q1")
	#df4c$Q1 <- pmax(df4c$Q1, rep(minValue, length(df4c$Q1)))
	
	# build dataframe 5
	df5c <- data.frame(times, compartments, Mr50)
	colnames(df5c) <- c("Day", "Compartment", "Median")
	df5c$Median <- pmax(df5c$Median, rep(minValue, length(df5c$Median)))
	
	# build dataframe 6
	#df6c <- data.frame(times, compartments, Mr75)
	#colnames(df6c) <- c("Day", "Compartment", "Q3")
	#df6c$Q3 <- pmax(df6c$Q3, rep(minValue, length(df6c$Q3)))
	
	# build dataframe 7
	#df7c <- data.frame(times, compartments, Mi25)
	#colnames(df7c) <- c("Day", "Compartment", "Q1")
	#df7c$Q1 <- pmax(df7c$Q1, rep(minValue, length(df7c$Q1)))
	
	# build dataframe 8
	df8c <- data.frame(times, compartments, Mi50)
	colnames(df8c) <- c("Day", "Compartment", "Median")
	df8c$Median <- pmax(df8c$Median, rep(minValue, length(df8c$Median)))
	
	# build dataframe 9
	#df9c <- data.frame(times, compartments, Mi75)
	#colnames(df9c) <- c("Day", "Compartment", "Q3")
	#df9c$Q3 <- pmax(df9c$Q3, rep(minValue, length(df9c$Q3)))
	
	# Combine data into single data frame 
	# apply log transform
	yset <- data.frame(df2c$Day, df2c$Compartment, log10(df2c$Median), 
												    log10(df5c$Median), 
												    log10(df8c$Median))
	
	#yset <- data.frame(df1c$Day, df1c$Compartment, log(df2c$Median), log(df1c$Q1), log(df3c$Q3),
	#											   log(df5c$Median), log(df4c$Q1), log(df6c$Q3),
	#											   log(df8c$Median), log(df7c$Q1), log(df9c$Q3))

	colnames(yset)	<- c("time", "Compartment", "MaM", "MrM", "MiM")
	#colnames(yset)	<- c("time", "Compartment", 
	#	                 "MaM", "MaQ1", "MaQ3", "MrM", "MrQ1", "MrQ3", "MiM", "MiQ1", "MiQ3")
						
	# filter out data before drugStart
	if (isFromDrugStart==1){
		yset <- yset[yset$time>drugStart,]
    }
	
	# set compartment labels
	compNames <- c("Non-Granuloma", "Granuloma")
	
	xlabel <- "Time after infection start [Days]"
	if (isFromDrugStart==1) {
		xlabel <- "Time after drug start [Days]"
	}
	ylabel <- "Macrophage count [log(Cells/ml)]"
	
	labx	<- c(seq(0, nTime, by = 30))
	namesx	<- labx
	laby	<- log10(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000)) 
	namesy	<- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9)
	
	titleText <- "Macrophages "
		
	# Generate plot per compartment
	for (i in 1:2){
		yset2 <- yset[yset$Compartment==i,]
		
		dev.new()
		pl <- ggplot(data = yset2, aes(x = time)) +
		  # Ma
		  #geom_ribbon(aes(ymin=MaQ1, ymax=MaQ3), alpha=0.2) +
    	  geom_line(aes(y=MaM), colour="blue", size=0.5) +
		
		  # Mr
		  #geom_ribbon(aes(ymin=MrQ1, ymax=MrQ3), alpha=0.2) +
    	  geom_line(aes(y=MrM), colour="red", size=0.5) +
		
		  # Mi
		  #geom_ribbon(aes(ymin=MiQ1, ymax=MiQ3), alpha=0.2) +
    	  geom_line(aes(y=MiM), colour="darkgreen", size=0.5) +
		
		  theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
		  scale_y_continuous(breaks = laby, labels = namesy) +
		  scale_x_continuous(breaks = labx, labels = namesx) +
		  xlab(xlabel) + 
		  ylab(ylabel) +
		  ggtitle(paste(titleText, compNames[i])) 
		print(pl)
	}
}