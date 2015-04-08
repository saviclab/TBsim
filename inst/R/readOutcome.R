readOutcome <- function(folder, fileName, fileType)
{
	# read the outcome data file
	inputFile <- paste(folder, fileName, sep="")
	con  <- file(inputFile, open = "r")
	
	#output variables
	times <- c()
	NoTB <- c()
	AcuteTB <- c()
	LatentTB <- c()
	ClearedTB <- c()
	NoTBp95 <- c()
	AcuteTBp95 <- c()
	LatentTBp95 <- c()
	ClearedTBp95 <- c()
	NoTBp05 <- c()
	AcuteTBp05 <- c()
	LatentTBp05 <- c()
	ClearedTBp05 <- c()
	
	# first check for correct type of data file
	firstLine <- readLines(con, n = 1, warn = FALSE)
	if (str_detect(firstLine, fileType)){
		# then step through each row and parse data
		while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
			if (str_detect(oneLine, "<type>")){
				type <- word(oneLine, 2, sep = '>')		# get outcome type
			}
			if (str_detect(oneLine, "<startTime>")){
				startTime <- as.numeric(word(oneLine, 2, sep = '>'))
			}
			if (str_detect(oneLine, "<stat>")){
				stat <- word(oneLine, 2, sep = '>')		# get stat type
			}
			if (str_detect(oneLine, "<data>")){
				numberString	<- word(oneLine, 2, sep = '>')
				numberVector	<- as.numeric(unlist(str_split(numberString, '\t')))
				if ((type=="NoTB")&& (stat=="median")){
					times			<- c(times, 1:length(numberVector))
				}
				if (stat=="median"){
					if (type=="NoTB")     { NoTB         <- c(NoTB, numberVector)}
					if (type=="AcuteTB")  { AcuteTB      <- c(AcuteTB, numberVector)}
					if (type=="LatentTB") { LatentTB     <- c(LatentTB, numberVector)}
					if (type=="ClearedTB"){ ClearedTB    <- c(ClearedTB, numberVector)}
				}
				if (stat=="p95"){
					if (type=="NoTB")     { NoTBp95         <- c(NoTBp95, numberVector)}
					if (type=="AcuteTB")  { AcuteTBp95      <- c(AcuteTBp95, numberVector)}
					if (type=="LatentTB") { LatentTBp95     <- c(LatentTBp95, numberVector)}
					if (type=="ClearedTB"){ ClearedTBp95    <- c(ClearedTBp95, numberVector)}
				}
				if (stat=="p05"){
					if (type=="NoTB")     { NoTBp05         <- c(NoTBp05, numberVector)}
					if (type=="AcuteTB")  { AcuteTBp05      <- c(AcuteTBp05, numberVector)}
					if (type=="LatentTB") { LatentTBp05     <- c(LatentTBp05, numberVector)}
					if (type=="ClearedTB"){ ClearedTBp05    <- c(ClearedTBp05, numberVector)}
				}
			}
		}
	} 
	close(con)
	output <- list(times, NoTB, AcuteTB, LatentTB, ClearedTB, 
		                  NoTBp05, AcuteTBp05, LatentTBp05, ClearedTBp05,
						  NoTBp95, AcuteTBp95, LatentTBp95, ClearedTBp95)
}