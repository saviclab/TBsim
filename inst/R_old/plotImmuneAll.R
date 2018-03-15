#===========================================================================
# plotImmuneAll.R
# All forms of immune cells and signals
#
# John Fors, UCSF
# Oct 6, 2014
#===========================================================================
plotImmuneAll <- function(){

	# read header file
	list <- readHeaderFile(folder)
	timeStamp		<- list[[1]] 
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
	
	# read immune data file
	output <- readImmune(folder, "immune.txt", "immune")
	times <- output[[1]]
	Tp <- output[[2]]
	T1 <- output[[3]]
	T2 <- output[[4]]
	MDC <- output[[5]]
	IDC <- output[[6]]
	TLN <- output[[7]]
	TpLN <- output[[8]]
	IL10 <- output[[9]]
	IL4 <- output[[10]]
	IFN <- output[[11]]
	IL12L <- output[[12]]
	IL12LN <- output[[13]]
	
	# build data frames
	df1 <- data.frame(times, IL10, IL4, IFN, IL12L)
	colnames(df1) <- c("Day", "IL10", "IL4", "IFN", "IL12L")
	
	df2 <- data.frame(times, IL12LN)
	colnames(df2) <- c("Day", "IL12LN")
						
	df3 <- data.frame(times, MDC, IDC)
	colnames(df3) <- c("Day", "MDC", "IDC")
	
	df4 <- data.frame(times, T1, T2)
	colnames(df4) <- c("Day", "T1", "T2")
	
	df5 <- data.frame(times, Tp, TpLN)
	colnames(df5) <- c("Day", "Tp", "TpLN")
	
	df6 <- data.frame(times, TLN)
	colnames(df6) <- c("Day", "TLN")
	
	# generate plots
	# Cytokines in Lung (IL4, IL10, IL12L, IFN)
	mainTitle <- "Cytokines in Lung"
	plotImmune(df1, c("time", "IL4", "IL10", "IL12L", "IFN"), mainTitle, subTitle, "pg/mL", drugStart)

	# Cytokines in Lymph Node (IL12LN)	
	mainTitle <- "Cytokines in Lymph Node (IL12LN)"
	plotImmune(df2, c("time", "IL12LN"), mainTitle, subTitle, "pg/mL", drugStart)
	
	# Dendritic Cells, (IDC and MDC)
	mainTitle <- "Dendritic Cells (IDC and MDC)"
	plotImmune(df3, c("time", "IDC", "MDC"), mainTitle, subTitle, "Cells/mL", drugStart)
	
	# T cells (T1, T2)
	mainTitle <- "T cells in Lung (T1, T2)"
	plotImmune(df4, c("time", "T1", "T2"), mainTitle, subTitle, "Cells/mL", drugStart)
	
	# T helper cells (Tp, TpLN)
	mainTitle <- "T cells in Lung (Tp, TpLN)"
	plotImmune(df5, c("time", "Tp", "TpLN"), mainTitle, subTitle, "Cells/mL", drugStart)

	# Naive T cells (TLN)
	mainTitle <- "Naive T cells in Lymph (TLN)"
	plotImmune(df6, c("time", "TLN"), mainTitle, subTitle, "Cells/mL", drugStart)
}