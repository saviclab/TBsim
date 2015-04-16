########################################################
# Read header file information
# function used for analysis of TB simulation data
# Dec 23, 2012 by John Fors
########################################################

readHeaderFile <- function(folder = "~/tb_run") {
	y <- read.table(paste(folder, "header.txt", sep=""), header=FALSE,sep="\t")
	y <- t(y)

	timeStamp		<- y[1]
	nTime			<- as.numeric(y[2])
	nSteps			<- as.numeric(y[3])
	drugStart		<- as.numeric(y[4])
	nPatients		<- as.numeric(y[5])

	isResistance	<- as.numeric(y[6])
	isImmuneKill	<- as.numeric(y[7])
	isGranuloma		<- as.numeric(y[8])
	isPersistance   <- as.numeric(y[9])

	diseaseText		<- y[10]
	nDrugs			<- as.numeric(y[11])
	doseText		<- y[12]

	outcomeIter		<- as.numeric(y[13])

	drug <- vector()
	for (i in 1:nDrugs) {
		drug[i]<- y[13+i]
	}

	output <- list(timeStamp, nTime, nSteps, drugStart, nPatients, isResistance,
					isImmuneKill, isGranuloma, isPersistance, diseaseText, nDrugs,
					doseText, outcomeIter, drug)
	return(output)
}
