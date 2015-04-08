readBactRes <- function(folder, fileName, fileType)
{
	# read the res bact data file
	inputFile <- paste(folder, fileName, sep="")
	con  <- file(inputFile, open = "r")
	
	#counters
	countIterations <- 0
	countCompartments <- 0
	countDrugs <- 0
	
	#output variables
	times <- c()
	iterations <- c()
	compartments <- c()
	drugs <- c()
	values <- c()

	# first check for correct type of data file
	firstLine <- readLines(con, n = 1, warn = FALSE)
	if (str_detect(firstLine, fileType)){
		# then step through each row and parse data
		while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
			if (str_detect(oneLine, "<type>")){
				drugid <- as.numeric(word(oneLine, 2, sep = '>')) + 1		# adjust index values
				countDrugs <- max(countDrugs, drugid)
			}
			if (str_detect(oneLine, "<startTime>")){
				startTime <- as.numeric(word(oneLine, 2, sep = '>'))
			}
			if (str_detect(oneLine, "<compartment>")){
				compartment <- as.numeric(word(oneLine, 2, sep = '>')) + 1	# adjust index values
				countCompartments <- max(countCompartments, compartment)
			}
			if (str_detect(oneLine, "<data>")){
				numberString	<- word(oneLine, 2, sep = '>')
				numberVector	<- as.numeric(unlist(str_split(numberString, '\t')))
				drugs			<- c(drugs,		   rep(drugid, length(numberVector)))
				times			<- c(times,        1:length(numberVector))
				compartments	<- c(compartments, rep(compartment, length(numberVector)))
				values			<- c(values, numberVector)
			}
		}
	} 
	close(con)
	output <- list(times, drugs, compartments, values)
}