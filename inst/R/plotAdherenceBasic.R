#===========================================================================
# plotAdherenceBasic.R
# Basic adherence profiles
#
# John Fors, UCSF
# Nov 4, 2014
#===========================================================================
plotAdherenceBasic <- function(){

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
		
	# read dose data file
	output <- readFile(folder, "adherence.txt", "adherence")
	times <- output[[1]]
	adh   <- output[[2]]
	
	# build data frame
	df <- data.frame(times, adh)
	df <- na.omit(df)
	colnames(df) <- c("Day", "Adh")
	
	# generate plot
	dev.new()
	bp <- ggplot(data=df, aes(x=Day, y=Adh)) + 
	      #geom_line(linetype="dashed", size=0.5, colour="grey") + 
		  geom_point(colour="red", size = 1) +
		  ggtitle("Patient Drug Adherence (Median)") + 
		  theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
 		  scale_color_brewer(palette="Set1") +
		  theme(legend.title=element_blank()) +
		  ylab("Adherence [%]") +
   		  xlab("Time after infection start (Days)") 
	print(bp)
}