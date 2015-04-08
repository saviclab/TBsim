########################################################
# Read granuloma formation and break up data
# function used for analysis of TB simulation data
# June 1, 2014 by John Fors
########################################################

readGranuloma <- function(folder, fileName, fileType)
{
	# read the immune data file
	inputFile <- paste(folder, fileName, sep="")
	con  <- file(inputFile, open = "r")
	
	#counters
	countIterations <- 0
	
	#output variables
	times <- c()
	iterations <- c()
	formation <- c()
	breakup <- c()

	# first check for correct type of data file
	firstLine <- readLines(con, n = 1, warn = FALSE)
	if (str_detect(firstLine, fileType)){
		# then step through each row and parse data
		while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
			if (str_detect(oneLine, "<type>")){
				type <- word(oneLine, 2, sep = '>')		# get granuloma type
			}
			if (str_detect(oneLine, "<startTime>")){
				startTime <- as.numeric(word(oneLine, 2, sep = '>'))
			}
			if (str_detect(oneLine, "<iteration>")){
				iteration <- as.numeric(word(oneLine, 2, sep = '>')) + 1	# adjust index values
				countIterations <- max(countIterations, iteration)
			}
			if (str_detect(oneLine, "<data>")){
				numberString	<- word(oneLine, 2, sep = '>')
				numberVector	<- as.numeric(unlist(str_split(numberString, '\t')))
				if (type=="formation"){
					times			<- c(times, 1:length(numberVector))
					iterations		<- c(iterations, rep(iteration, length(numberVector)))
				}
				if (type=="formation") { formation <- c(formation, numberVector)}
				if (type=="breakup")   { breakup   <- c(breakup, numberVector)}
			}
		}
	} 
	close(con)
	output <- list(times, iterations, formation, breakup)
}