#' @export
tb_read_file <- function(folder, filename = "calcConc.txt", filetype = "calcConc") {

  # read the dose data file
  inputFile <- paste0(folder, "/", filename)
  con  <- file(inputFile, open = "r")

  # starting values
  maxDrugs <- 10
  startTime <- array (data=NA, dim=c(maxDrugs))

  #counters
  type <- ""
  drugi <- 0
  countDrugs <- 0
  countCompartments <- 0
  countTime <- 0
  compartment <- 0

  #output variables
  times <- c()
  compartments <- c()
  drugs <- c()
  values <- c()

  # first check for correct type of data file
  firstLine <- readLines(con, n = 1, warn = FALSE)
  if (str_detect(firstLine, filetype)){
    # then step through each row and parse data
    while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
      if (str_detect(oneLine, "<type>")){
        drugi <- as.numeric(word(oneLine, 2, sep = '>')) + 1		# adjust index values
        countDrugs <- max(countDrugs, drugi)
      }
      if (str_detect(oneLine, "all")){
        type <- "adh"
      }
      if (str_detect(oneLine, "<startTime>")){
        startTime[drugi] <- as.numeric(word(oneLine, 2, sep = '>'))
      }
      if (str_detect(oneLine, "<compartment>")){
        compartment <- as.numeric(word(oneLine, 2, sep = '>')) + 1	# adjust index values
        countCompartments <- max(countCompartments, compartment)
      }
      if (str_detect(oneLine, "<data>")){
        numberString <- word(oneLine, 2, sep = '>')
        numberVector <- as.numeric(unlist(str_split(numberString, '\t')))
        len <- length(numberVector)-1
        #print(length(numberVector))
        #numberVector <- numberVector[1:length(numberVector)-1]
        #print(length(numberVector))
        times <- c(times, 1:len)
        if (type!="all"){
          drugs <- c(drugs, rep(drugi, len))
          compartments <- c(compartments, rep(compartment, len))
        }
        values <- c(values, numberVector[1:len])
      }
    }
  }
  close(con)
  if (type!="adh"){
    output <- list(times, drugs, compartments, values)
  }
  else{
    output <- list(times, values)
  }

}
