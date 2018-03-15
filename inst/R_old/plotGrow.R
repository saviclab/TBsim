#===========================================================================
# plotGrow.R
# EC50 growth factors
#
# John Fors, UCSF
# Oct 6, 2014
#===========================================================================
plotGrow <- function(){

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
	output <- readFile(folder, "calcGrow.txt", "calcGrow")
	times <- output[[1]]
	drugs <- output[[2]]
	compartments <- output[[3]]
	grows <- output[[4]]

	# build data frame
	df <- data.frame(times, drugs, compartments, grows)
	df <- na.omit(df)
	colnames(df) <- c("Hour", "Drug", "Compartment", "Growth")
	
	# apply actual drug codes
	df$Drug <- drug[df$Drug]
	
	# apply compartment labels
	compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
	df$Compartment <- compNames[df$Compartment] 
	df$Compartment <- factor(df$Compartment,
         levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))
	
	# display growth factor as 1-x (to make easier to understand effect)
	df$Growth <- -df$Growth + 1	
	
	# generate plot
	dev.new()
	bp <- ggplot(data=df, aes(x=Hour, y=Growth)) + 
	      geom_line(size=0.5, colour="red") + 
		  ggtitle("EC50 Growth Factor per Drug (Average) [0 = no effect]") + 
		  theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
 		  scale_color_brewer(palette="Set1") +
		  theme(legend.title=element_blank()) +
		  ylab("Growth factor [0..1]") +
   		  xlab("Time after drug treatment start [Hours]") +
	      facet_grid(Drug ~ Compartment, scales="free_y")
	print(bp)
}