tb_read_macro <- function(folder) {
	# read the immune data file
	inputFile <- paste(folder, "/macro.txt", sep="")
	if(!file.exists(inputFile)) {
    warning(paste0("Couldn't find file ", inputFile))
    return(NULL)
  }
	con  <- file(inputFile, open = "r")

	#counters
	countCompartments <- 0

	#output variables
	times <- c()
	compartments <- c()
	#Ma25 <- c()
	Ma50 <- c()
	#Ma75 <- c()
	#Mr25 <- c()
	Mr50 <- c()
	#Mr75 <- c()
	#Mi25 <- c()
	Mi50 <- c()
	#Mi75 <- c()

	# first check for correct type of data file
	firstLine <- readLines(con, n = 1, warn = FALSE)
	if (stringr::str_detect(firstLine, "macro")){
		# then step through each row and parse data
		while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
			if (stringr::str_detect(oneLine, "<type>")){
				type <- stringr::word(oneLine, 2, sep = '>')		# get macro data type
			}
			if (stringr::str_detect(oneLine, "<stat>")){
				stat <- stringr::word(oneLine, 2, sep = '>')		# get statistic type (m, q1, q3)
			}
			if (stringr::str_detect(oneLine, "<startTime>")){
				startTime <- as.numeric(stringr::word(oneLine, 2, sep = '>'))
			}
			if (stringr::str_detect(oneLine, "<compartment>")){
				compartment <- as.numeric(stringr::word(oneLine, 2, sep = '>')) + 1	# adjust index values
				countCompartments <- max(countCompartments, compartment)
			}
			if (stringr::str_detect(oneLine, "<data>")){
				numberString	<- stringr::word(oneLine, 2, sep = '>')
				numberVector	<- as.numeric(unlist(stringr::str_split(numberString, '\t')))
				if ((type=="Ma")&&(stat=="median")){
					times			<- c(times, 1:length(numberVector))
					compartments	<- c(compartments, rep(compartment, length(numberVector)))
				}
				if (type=="Ma") {
					if (stat=="median")	   { Ma50  <- c(Ma50, numberVector)}
					#if (stat=="quartile1") { Ma25  <- c(Ma25, numberVector)}
					#if (stat=="quartile3") { Ma75  <- c(Ma75, numberVector)}
				}
				if (type=="Mr") {
					if (stat=="median")    { Mr50 <- c(Mr50, numberVector)}
					#if (stat=="quartile1") { Mr25 <- c(Mr25, numberVector)}
					#if (stat=="quartile3") { Mr75 <- c(Mr75, numberVector)}
				}
				if (type=="Mi") {
					if (stat=="median")    { Mi50 <- c(Mi50, numberVector)}
					#if (stat=="quartile1") { Mi25 <- c(Mi25, numberVector)}
					#if (stat=="quartile3") { Mi75 <- c(Mi75, numberVector)}
				}
			}
		}
	}
	close(con)
	output <- list(times = times, compartments = compartments, Ma50 = Ma50, Mr50 = Mr50, Mi50 = Mi50)
	return(output)
}
