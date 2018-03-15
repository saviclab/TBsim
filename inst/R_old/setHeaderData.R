setHeaderData <- function(folder)
{
	list <- readHeaderFile(folder)
	timeStamp		<- list[[1]] # this is concatenated with version ID
	nTime			<- list[[2]]
	nSteps			<- list[[3]]
	drugStart		<- list[[4]]
	nPatients		<- list[[5]]
	isResistance	<- list[[6]]
	isImmuneKill	<- list[[7]]
	isGranuloma		<- list[[8]]
	isPersistance   <- list[[9]]
	diseaseText		<- list[[10]]
	nDrugs			<- list[[11]]
	doseText		<- list[[12]]
	outcomeIter		<- list[[13]]
	drug			<- list[[14]]

	rText <- "Resist. OFF"
	if (isResistance>0) { rText <-"Resist. ON"}

	iText <- "Immune OFF"
	if (isImmuneKill>0) { iText <- "Immune ON"}

	gText <- "Gran. OFF"
	if (isGranuloma>0) { gText <- "Gran. ON"}

	d1 <- drug[1]
	d2 <- " "
	d3 <- " "
	d4 <- " "
	if (length(drug)>1) { d2 <- drug[2]}
	if (length(drug)>2) { d3 <- drug[3]}
	if (length(drug)>3) { d4 <- drug[4]}

	timePeriods <- 1:nTime
	
	return(yout)
}