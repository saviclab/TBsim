#' Created by John Fors, updates by Ron Keizer
#' @export
tb_read_headerfile <- function(folder = "~/tb_run") {
	y <- read.table(paste0(folder, "/header.txt"), header=FALSE,sep="\t")
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

	output <- list(timeStamp = timeStamp,
	               nTime = nTime,
	               nSteps = nSteps,
	               drugStart = drugStart,
	               nPatients = nPatients,
	               isResistance = isResistance,
  				  	   isImmuneKill = isImmuneKill,
  				  	   isGranuloma = isGranuloma,
  				  	   isPersistance = isPersistance,
  				  	   diseaseText = diseaseText,
  				  	   nDrugs = nDrugs,
	         			 doseText = doseText,
  				  	   outcomeIter = outcomeIter,
  				  	   drug = drug)
	return(output)
}
