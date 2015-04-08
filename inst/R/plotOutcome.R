#===========================================================================
# plotOutcome.R
# Therapy outcome statistics for population
#
# John Fors, UCSF
# Oct 6, 2014
#===========================================================================
plotOutcome <- function(isFromDrugStart, isCombineLatClr){

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
	
	output <- readOutcome(folder, "outcome.txt", "outcome")
	times <- output[[1]]
	NoTB       <- output[[2]]*100
	AcuteTB    <- output[[3]]*100
	LatentTB   <- output[[4]]*100
	ClearedTB  <- output[[5]]*100
	NoTBp05       <- output[[6]]*100
	AcuteTBp05    <- output[[7]]*100
	LatentTBp05   <- output[[8]]*100
	ClearedTBp05  <- output[[9]]*100
	NoTBp95       <- output[[10]]*100
	AcuteTBp95    <- output[[11]]*100
	LatentTBp95   <- output[[12]]*100
	ClearedTBp95  <- output[[13]]*100
	
	# build dataframe
	df1c <- data.frame(times, NoTB, NoTBp05, NoTBp95)
	colnames(df1c) <- c("Day", "NoTBAvg", "NoTBp05", "NoTBp95")
	df1c <- df1c[1:nTime,]
	
	df2c <- data.frame(times, AcuteTB, AcuteTBp05, AcuteTBp95)
	colnames(df2c) <- c("Day", "AcuteTBAvg", "AcuteTBp05", "AcuteTBp95")
	df2c <- df2c[1:nTime,]

	df3c <- data.frame(times, ClearedTB, ClearedTBp05, ClearedTBp95)
	colnames(df3c) <- c("Day", "ClearedTBAvg", "ClearedTBp05", "ClearedTBp95")
	df3c <- df3c[1:nTime,]
	
	df4c <- data.frame(times, LatentTB, LatentTBp05, LatentTBp95)
	colnames(df4c) <- c("Day", "LatentTBAvg", "LatentTBp05", "LatentTBp95")
	df4c <- df4c[1:nTime,]

	# estimate the 5/95 percentiles by estimating composite variance of latent and cleared
	LatentDiff95	<- (LatentTBp95 - LatentTB) * 0.5
	LatentDiff05	<- (LatentTB - LatentTBp05) * 0.5
	ClearedDiff95	<- (ClearedTBp95 - ClearedTB) * 0.5
	ClearedDiff05	<- (ClearedTB - ClearedTBp05) * 0.5
	cDiff95 <- sqrt(LatentDiff95 * LatentDiff95 + ClearedDiff95 * ClearedDiff95) * 2.0 
	cDiff05 <- sqrt(LatentDiff05 * LatentDiff05 + ClearedDiff05 * ClearedDiff05) * 2.0 
	
	# combined metric: cleared + latent TB
	df5c <- data.frame(times, LatentTB+ClearedTB, LatentTB+ClearedTB - cDiff95, LatentTB+ClearedTB + cDiff95)
	colnames(df5c) <- c("Day", "cTBAvg", "cTBp05", "cTBp95")
	df5c <- df5c[1:nTime,]
	
	# combine all pieces into a single data frame	
	yset <- data.frame(timePeriods, df1c$NoTBAvg,      df1c$NoTBp05,		df1c$NoTBp95,
									df2c$AcuteTBAvg,   df2c$AcuteTBp05,		df2c$AcuteTBp95,  
		                            df3c$ClearedTBAvg, df3c$ClearedTBp05,	df3c$ClearedTBp95, 
									df4c$LatentTBAvg,  df4c$LatentTBp05,	df4c$LatentTBp95, 
									df5c$cTBAvg,       df5c$cTBp05,			df5c$cTBp95)
	
	c5 <- c("time", "NTB50", "NTBp05", "NTBp95",
					"ATB50", "ATBp05", "ATBp95", 
		            "CTB50", "CTBp05", "CTBp95",
					"LTB50", "LTBp05", "LTBp95",
					"cTB50", "cTBp05", "cTBp95")
	colnames(yset) <- c5
	
	# filter out data before drugStart
	if (isFromDrugStart==1){
		yset <- yset[yset$time>drugStart,]
    }

	# trim to only include every 5th data point
	yset <- yset[seq(1, nrow(yset), 5), ]
	
	dfm <- yset
	
	mainTitle   <- "Patient Population Treatment Outcome"
	labx	<- c(seq(0, nTime, by = 30))
	namesx	<- labx
	laby	<- c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100) 
	namesy	<- laby

	# Generate plot
	dev.new()
	pl <- ggplot(data = dfm, aes(x = time))
			if (isCombineLatClr==0){
			   pl <- pl +	
				geom_ribbon(aes(ymin=LTBp05, ymax=LTBp95), alpha=0.2) +
				geom_line(aes(y=LTB50, colour="darkgreen"),size=1) +
          
				geom_ribbon(aes(ymin=CTBp05, ymax=CTBp95), alpha=0.2) +
				geom_line(aes(y=CTB50, colour="blue"),size=1) 
			}
		  if (isCombineLatClr==1){
			pl <- pl +
				geom_ribbon(aes(ymin=cTBp05, ymax=cTBp95), alpha=0.2) +
				geom_line(aes(y=cTB50, colour="blue"),size=1) 
			}
		pl <- pl +	
			geom_ribbon(aes(ymin=NTBp05, ymax=NTBp95), alpha=0.2) +
			geom_line(aes(y=NTB50, colour="black"),size=1) +
		
			geom_ribbon(aes(ymin=ATBp05, ymax=ATBp95), alpha=0.2) +
			geom_line(aes(y=ATB50, colour="red"), size=1) +

		xlab("Time after infection start [Days]") + 
		ylab("Share of patient population [%]") +
		scale_x_continuous(breaks = labx, labels = namesx) +
	    scale_y_continuous(breaks = laby , labels = namesy) 
		if (isCombineLatClr==0){		
			pl <- pl + scale_colour_manual(name = 'Outcome', 
					values = c('darkgreen'='darkgreen', 'blue'='blue', 'black'='black', 'red'='red'), 
					labels = c('No TB', 'Cleared', 'Latent','Acute')) 
		}
		if (isCombineLatClr==1){
			 pl <- pl + scale_colour_manual(name = 'Outcome', 
					values = c('black'='black', 'blue'='blue', 'red'='red'), 
					labels = c('No TB', 'Cleared/Latent', 'Acute')) 
		}
		pl <- pl + 	theme(legend.justification=c(0,1), legend.position=c(0,1),
					legend.background = element_rect(fill=alpha('white', 1.0)),
					legend.direction="vertical", legend.box="horizontal", legend.box.just = c("top")) +
				expand_limits(y=0) +
  				theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
				ggtitle(mainTitle) 
	print(pl)	
}	