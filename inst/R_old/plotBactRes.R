#===========================================================================
# plotBactRes.R
# Plot resistant bacteria - as totals or per compartment
#
# John Fors, UCSF
# Oct 10, 2014
#===========================================================================
plotBactRes <- function(isSummary, isFromDrugStart){

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
	drugNames		<- list[[14]]
	
	timePeriods <- 1:nTime
	
	output <- readBactRes(folder, "bactRes.txt", "bactRes")
	times <- output[[1]]
	drugs <- output[[2]]
	compartments  <- output[[3]]
	values	<- output[[4]]

	# build dataframe 1
	df1 <- data.frame(times, drugs, compartments, values)
	colnames(df1) <- c("Day", "Drug", "Compartment", "Median")
	
	# Combine data into single data frame 
	# apply log transform
	if (isSummary==0){
		yset <- data.frame(df1$Day, df1$Drug, df1$Compartment, log10(df1$Median), rm.na=TRUE)
		colnames(yset)	<- c("time", "Drug", "Compartment", "Median")
		
		# apply compartment labels
		compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
		yset$Compartment <- compNames[yset$Compartment] 
		yset$Compartment <- factor(yset$Compartment,
			levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))
	}
	
	# if summary across all compartments then create sum
	if (isSummary==1){
		df1Agg <- aggregate(Median ~ Day + Drug, dfc, FUN=sum, na.rm=TRUE)
		yset <- data.frame(df1Agg$Day, df1Agg$Drug, log10(df1Agg$Median))
		colnames(yset)	<- c("time", "Drug", "Median")
	}

	# filter out data before drugStart
	if (isFromDrugStart==1){
		yset <- yset[yset$time>drugStart,]
    }
	
	# filter out to have 1/5 of points, for more smooth curve
	#yset <- yset[seq(1, nrow(yset), 5), ]
	
	# apply drug names
	yset$Drug <- drugNames[yset$Drug]
	
	xlabel <- "Time after infection (Days)"
	if (isFromDrugStart==1) {
		xlabel <- "Time after drug start (Days)"
	}
	ylabel <- "Bacterial load [log(CFU/ml)]"
	titleText <- "Total Resistant Bacteria "
	
	#labx	<- c(seq(0, nTime, by = 60))
	#namesx	<- labx
		
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +
			#geom_ribbon(aes(ymin=Q1, ymax=Q3), alpha=0.2) +
   			geom_line(aes(y=Median), colour="blue", size=0.5) +
			theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
			#scale_y_continuous(breaks = laby, labels = namesy) +
			#scale_x_continuous(breaks = labx, labels = namesx) +
			xlab(xlabel) + 
			ylab(ylabel) +
			ggtitle(titleText) 
			if (isSummary==0){
				pl <- pl + facet_grid(Drug ~ Compartment, scales="free_y")
			}
			if (isSummary==1){
				pl <- pl + facet_wrap(~Drug, nrow=1, scales="free_y")
			}
	print(pl)
}