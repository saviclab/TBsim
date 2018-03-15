#===========================================================================
# plotTrials.R
# Compare simulations and clinical trials
#
# John Fors, UCSF
# Nov 7, 2014
#===========================================================================
plotTrials <- function(){
	folder   <- "C:/WorkFiles/UCSF_BTS/TB_10262014/DataFiles/"
	fileName <- "clinicaltrials.txt"
	
	inputFile <- paste(folder, fileName, sep="")
	con		  <- file(inputFile, open = "r")
	
mydata = read.table(fileName, skip=1, sep ="\t")
colnames(mydata) <- c("Study", "Tx", "Patients", "Duration", "Metric", "Outcome", "Simulation_Median", "Simulation_05",
		              "Simulation_95", "Category")

	# Generate plot
	dev.new()
	pl <- ggplot(data = mydata, aes(x=Outcome, y=Simulation_Median, colour=Category)) +
		  geom_point(size=3.0) +
		  geom_errorbar(aes(ymin = Simulation_05,ymax = Simulation_95)) + 
		  geom_smooth(data=subset(mydata, mydata$Category=="A"), method=lm, se=FALSE, size=1.0, type="b") +
		  scale_x_continuous(limits=c(0, 0.35)) +
		  scale_y_continuous(limits=c(0, 0.35)) +
		  #geom_text(aes(label=mydata$Tx), size=3, colour = "black") +
		  labs(title="Comparison of Clinical Trials and Simulations") +
		  xlab("Clinical Trial") + 
		  ylab("Simulation") 
	print(pl)	
}	