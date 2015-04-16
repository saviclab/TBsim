#' @export
tb_read_outcome <- function(folder, filename = "outcome.txt", filetype = "outcome") {

  # read the outcome data file
	inputFile <- paste0(folder, "/", filename)
	con  <- file(inputFile, open = "r")

  output <- list()

	# first check for correct type of data file
	firstLine <- readLines(con, n = 1, warn = FALSE)
	if (str_detect(firstLine, filetype)){
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
				  output$times			<- c(output$times, 1:length(numberVector))
				}
				if (stat=="median"){
					if (type=="NoTB")     { output$NoTB         <- c(output$NoTB, numberVector)}
					if (type=="AcuteTB")  { output$AcuteTB      <- c(output$AcuteTB, numberVector)}
					if (type=="LatentTB") { output$LatentTB     <- c(output$LatentTB, numberVector)}
					if (type=="ClearedTB"){ output$ClearedTB    <- c(output$ClearedTB, numberVector)}
				}
				if (stat=="p95"){
					if (type=="NoTB")     { output$NoTBp95         <- c(output$NoTBp95, numberVector)}
					if (type=="AcuteTB")  { output$AcuteTBp95      <- c(output$AcuteTBp95, numberVector)}
					if (type=="LatentTB") { output$LatentTBp95     <- c(output$LatentTBp95, numberVector)}
					if (type=="ClearedTB"){ output$ClearedTBp95    <- c(output$ClearedTBp95, numberVector)}
				}
				if (stat=="p05"){
					if (type=="NoTB")     { output$NoTBp05         <- c(output$NoTBp05, numberVector)}
					if (type=="AcuteTB")  { output$AcuteTBp05      <- c(output$AcuteTBp05, numberVector)}
					if (type=="LatentTB") { output$LatentTBp05     <- c(output$LatentTBp05, numberVector)}
					if (type=="ClearedTB"){ output$ClearedTBp05    <- c(output$ClearedTBp05, numberVector)}
				}
			}
		}
	}
	close(con)
  return(output)
}
