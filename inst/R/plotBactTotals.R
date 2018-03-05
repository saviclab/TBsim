#===========================================================================
# plotBactTotals.R
# Total wild-type and All-type bacteria
#
# John Fors, UCSF
# Oct 6, 2014
#===========================================================================
plotBactTotals <- function(type, isSummary, isFromDrugStart){

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
	
	output <- readBactTotals(folder, "bactTotals.txt", "bactTotals")
	times <- output[[1]]
	compartments  <- output[[2]]
	wilds05  <- output[[3]]
	wilds50  <- output[[4]]
	wilds95  <- output[[5]]
	totals05 <- output[[6]]
	totals50 <- output[[7]]
	totals95 <- output[[8]]
	
	if (type=="wild") {
		p05		<- wilds05
		median	<- wilds50
		p95		<- wilds95
	}
	if (type=="total") {
		p05		<- totals05
		median	<- totals50
		p95		<- totals95
	}

	# build dataframe 1
	df1 <- data.frame(times, compartments, p05)
	colnames(df1) <- c("Day", "Compartment", "p05")
	
	# build dataframe 2
	df2 <- data.frame(times, compartments, median)
	colnames(df2) <- c("Day", "Compartment", "Median")
	
	# build dataframe 3
	df3 <- data.frame(times, compartments, p95)
	colnames(df3) <- c("Day", "Compartment", "p95")
	
	# if summary across all compartments then create sum
	if (isSummary==1){
		df1 <-aggregate(df1, by=list(df1$Day), FUN=sum, na.rm=TRUE)
		df2 <-aggregate(df2, by=list(df2$Day), FUN=sum, na.rm=TRUE)
		df3 <-aggregate(df3, by=list(df3$Day), FUN=sum, na.rm=TRUE)
		df1$Day <- df1$Group.1
		df2$Day <- df2$Group.1
		df3$Day <- df3$Group.1
	}
	
	# Combine data into single data frame 
	# apply log transform
	yset <- data.frame(df1$Day, df1$Compartment, log10(df2$Median), log10(df1$p05), log10(df3$p95))
	colnames(yset)	<- c("time", "Compartment", "Median", "p05", "p95")
    yset <- yset[yset$time<nTime+1,]
	
	# filter out data before drugStart
	if (isFromDrugStart==1){
		yset <- yset[yset$time>drugStart,]
    }
	
	# filter out to have 1/5 of points, for more smooth curve
	#yset <- yset[seq(1, nrow(yset), 5), ]
	
	# apply compartment labels
	compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
	
	xlabel <- "Time after infection (Days)"
	if (isFromDrugStart==1) {
		xlabel <- "Time after drug start (Days)"
	}
	ylabel <- "Bacterial load [log(CFU/ml)]"
	mainTitle <- "Total Bacteria Population"
	
	labx	<- c(seq(0, nTime, by = 30))
	namesx	<- labx
	laby	<- log10(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000)) 
	namesy	<- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9)
	
	if (type=="wild")  {titleText <- "Wild-type Bacteria - "}
	if (type=="total") {titleText <- "Total Bacteria - "}	
		
	if (isSummary==0){
	# Generate plot per compartment
	for (i in 1:4){
		yset2 <- yset[yset$Compartment==i,]
		
		dev.new()
		pl <- ggplot(data = yset2, aes(x = time)) +
		  geom_ribbon(aes(ymin=p05, ymax=p95), alpha=0.2) +
    	  geom_line(aes(y=Median), colour="blue", size=0.5) +
		  theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
		  scale_y_continuous(breaks = laby, labels = namesy) +
		  scale_x_continuous(breaks = labx, labels = namesx) +
		  xlab(xlabel) + 
		  ylab(ylabel) +
		  #ylim(c(-2, 9)) + 
		  ggtitle(paste(titleText, compNames[i])) 
		print(pl)
	}
	}
	if (isSummary==1){	
	# Generate plot sum across all compartments
	dev.new()
	pl <- ggplot(data = yset, aes(x = time)) +
		theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
		geom_ribbon(aes(ymin=p05, ymax=p95), alpha=0.2) +
		geom_line(aes(y=Median), colour="blue", size=0.5) +
		scale_y_continuous(breaks = laby, labels = namesy) +
		scale_x_continuous(breaks = labx, labels = namesx) +
		xlab(xlabel) + 
		ylab(ylabel) +
		ggtitle(paste(titleText, " All Compartments")) 
	print(pl)	
	}
}