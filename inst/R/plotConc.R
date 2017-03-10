#===========================================================================
# plotConc.R
# PK concentration profiles
#
# John Fors, UCSF
# Oct 6, 2014
#===========================================================================
plotConc <- function(){

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

	# read concentration data file
	output <- readFile(folder, "calcConc.txt", "calcConc")
	times <- output[[1]]
	drugs <- output[[2]]
	compartments <- output[[3]]
	concs <- output[[4]]

	# build data frame
	df <- data.frame(times, drugs, compartments, concs)
	df <- na.omit(df)
	colnames(df) <- c("Hour", "Drug", "Compartment", "Concentration")

	# apply actual drug codes
	df$Drug <- drug[df$Drug]

	# apply compartment labels
	compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
	df$Compartment <- compNames[df$Compartment]
	df$Compartment <- factor(df$Compartment,
         levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))

	# generate plot
	dev.new()
	bp <- ggplot(data=df, aes(x=Hour, y=Concentration)) +
	      geom_line(size=0.5, colour="red") +
		  ggtitle("PK Concentration Profile per Drug") +
		  theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
 		  scale_color_brewer(palette="Dark2") +
		  theme(legend.title=element_blank()) +
		  ylab("Concentration [mg/L]") +
   		  xlab("Time after first drug start [Hours]") +
	      facet_grid(Drug ~ Compartment, scales="free_y")
	print(bp)
}
