readImmune <- function(folder, fileName, fileType)
{
	# read the immune data file
	inputFile <- paste(folder, fileName, sep="")
	con  <- file(inputFile, open = "r")
	
	#output variables
	times <- c()
	Tp <- c()
	T1 <- c()
	T2 <- c()
	TpLN <- c()
	TLN <- c()
	IL12L <- c()
	IL12LN <- c()
	IL10 <- c()
	IL4 <- c()
	IFN <- c()
	MDC <- c()
	IDC <- c()
	
	# first check for correct type of data file
	firstLine <- readLines(con, n = 1, warn = FALSE)
	if (str_detect(firstLine, fileType)){
		# then step through each row and parse data
		while (length(oneLine <- readLines(con, n = 1, warn = FALSE)) > 0) {
			if (str_detect(oneLine, "<type>")){
				type <- word(oneLine, 2, sep = '>')		# get immune type
			}
			if (str_detect(oneLine, "<startTime>")){
				startTime <- as.numeric(word(oneLine, 2, sep = '>'))
			}
			if (str_detect(oneLine, "<data>")){
				numberString	<- word(oneLine, 2, sep = '>')
				numberVector	<- as.numeric(unlist(str_split(numberString, '\t')))
				if (type=="Tp"){
					times			<- c(times, 1:length(numberVector))
				}
				if (type=="Tp")     { Tp     <- c(Tp, numberVector)}
				if (type=="T1")     { T1     <- c(T1, numberVector)}
				if (type=="T2")     { T2     <- c(T2, numberVector)}
				if (type=="MDC")    { MDC    <- c(MDC, numberVector)}
				if (type=="IDC")    { IDC    <- c(IDC, numberVector)}
				if (type=="TLN")    { TLN    <- c(TLN, numberVector)}
				if (type=="TpLN")   { TpLN   <- c(TpLN, numberVector)}
				if (type=="IL10")   { IL10   <- c(IL10, numberVector)}
				if (type=="IL4")    { IL4    <- c(IL4, numberVector)}
				if (type=="IFN")    { IFN    <- c(IFN, numberVector)}
				if (type=="IL12L")  { IL12L  <- c(IL12L, numberVector)}
				if (type=="IL12LN") { IL12LN <- c(IL12LN, numberVector)}
			}
		}
	} 
	close(con)
	output <- list(times, Tp, T1, T2, MDC, IDC, TLN, TpLN, IL10, IL4, IFN, IL12L, IL12LN)
}