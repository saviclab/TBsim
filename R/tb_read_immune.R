#' @export
tb_read_immune <- function(folder) {

  # read the immune data file
  inputFile <- paste0(folder, "/immune.txt")
  if(!file.exists(inputFile)) {
    warning(paste0("Couldn't find file ", inputFile))
    return(NULL)
  }
  con <- file(inputFile, open = "r")

  #output variables
  output <- list()

  # first check for correct type of data file
  firstLine <- readLines(con, n = 1, warn = FALSE)
  if (stringr::str_detect(firstLine, "immune")){
    # then step through each row and parse data
    while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
      if (stringr::str_detect(oneLine, "<type>")){
        type <- stringr::word(oneLine, 2, sep = '>')		# get immune type
      }
      if (stringr::str_detect(oneLine, "<startTime>")){
        startTime <- as.numeric(stringr::word(oneLine, 2, sep = '>'))
      }
      if (stringr::str_detect(oneLine, "<data>")){
        numberString	<- stringr::word(oneLine, 2, sep = '>')
        numberVector	<- as.numeric(unlist(stringr::str_split(numberString, '\t')))
        if (type=="Tp"){
          output$times			<- c(output$times, 1:length(numberVector))
        }
        if (type=="Tp")     { output$Tp     <- c(output$Tp, numberVector)}
        if (type=="T1")     { output$T1     <- c(output$T1, numberVector)}
        if (type=="T2")     { output$T2     <- c(output$T2, numberVector)}
        if (type=="MDC")    { output$MDC    <- c(output$MDC, numberVector)}
        if (type=="IDC")    { output$IDC    <- c(output$IDC, numberVector)}
        if (type=="TLN")    { output$TLN    <- c(output$TLN, numberVector)}
        if (type=="TpLN")   { output$TpLN   <- c(output$TpLN, numberVector)}
        if (type=="IL10")   { output$IL10   <- c(output$IL10, numberVector)}
        if (type=="IL4")    { output$IL4    <- c(output$IL4, numberVector)}
        if (type=="IFN")    { output$IFN    <- c(output$IFN, numberVector)}
        if (type=="IL12L")  { output$IL12L  <- c(output$IL12L, numberVector)}
        if (type=="IL12LN") { output$IL12LN <- c(output$IL12LN, numberVector)}
      }
    }
  }
  close(con)
  return(output)
}
