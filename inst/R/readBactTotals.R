readBactTotals <- function(folder, fileName, fileType)
{
	# read the immune data file
	inputFile <- paste(folder, fileName, sep="")
	con  <- file(inputFile, open = "r")
	
	#counters
	countCompartments <- 0
	
	#output variables
	times <- c()
	compartments <- c()
	wilds05 <- c()
	wilds50 <- c()
	wilds95 <- c()
	totals05 <- c()
	totals50 <- c()
	totals95 <- c()

	# first check for correct type of data file
	firstLine <- readLines(con, n = 1, warn = FALSE)
	if (str_detect(firstLine, fileType)){
		# then step through each row and parse data
		while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
			if (str_detect(oneLine, "<type>")){
				type <- word(oneLine, 2, sep = '>')		# get bacterial data type
			}
			if (str_detect(oneLine, "<stat>")){
				stat <- word(oneLine, 2, sep = '>')		# get statistic type (m, q1, q3)
			}
			if (str_detect(oneLine, "<startTime>")){
				startTime <- as.numeric(word(oneLine, 2, sep = '>'))
			}
			if (str_detect(oneLine, "<compartment>")){
				compartment <- as.numeric(word(oneLine, 2, sep = '>')) + 1
				countCompartments <- max(countCompartments, compartment)
			}
			if (str_detect(oneLine, "<data>")){
				numberString	<- word(oneLine, 2, sep = '>')
				numberVector	<- as.numeric(unlist(str_split(numberString, '\t')))
				if ((type=="wild")&&(stat=="median")){
					times			<- c(times, 1:length(numberVector))
					compartments	<- c(compartments, rep(compartment, length(numberVector)))
				}
				if (type=="wild") {
					if (stat=="median")	{ wilds50  <- c(wilds50, numberVector)}
					if (stat=="p05")	{ wilds05  <- c(wilds05, numberVector)}
					if (stat=="p95")	{ wilds95  <- c(wilds95, numberVector)}
				}
				if (type=="total") {
					if (stat=="median") { totals50 <- c(totals50, numberVector)}
					if (stat=="p05")	{ totals05 <- c(totals05, numberVector)}
					if (stat=="p95")	{ totals95 <- c(totals95, numberVector)}
				}
			}
		}
	} 
	close(con)
	output <- list(times, compartments, wilds05, wilds50, wilds95, totals05, totals50, totals95)												
}