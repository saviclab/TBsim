#===========================================================================
# plotBactTotals.R
# Total wild-type and All-type bacteria
#
# John Fors, UCSF
# Oct 6, 2014
# updated Ron Keizer, Apr 2015
#===========================================================================

#' @export
tb_plot_bact <- function(info = NULL, bact = NULL, 
                                type = "total", is_summary = TRUE, is_from_drug_start = TRUE) {
  if(is.null(info)) {
    stop("This function requires input of an object created by tb_read_header().")
  }
  if(is.null(bact)) {
    stop("This function requires input of an object created by tb_read_bact_totals().")
  }

  # read header file
  timePeriods <- 1:info$nTime

  if (type=="wild") {
    p05		<- bact$wilds05
    median	<- bact$wilds50
    p95		<- bact$wilds95
  }
  if (type=="total") {
    p05		<- bact$totals05
    median	<- bact$totals50
    p95		<- bact$totals95
  }

  # build dataframe 1
  df1 <- data.frame(bact$times, bact$compartments, p05)
  colnames(df1) <- c("Day", "Compartment", "p05")

  # build dataframe 2
  df2 <- data.frame(bact$times, bact$compartments, median)
  colnames(df2) <- c("Day", "Compartment", "Median")

  # build dataframe 3
  df3 <- data.frame(bact$times, bact$compartments, p95)
  colnames(df3) <- c("Day", "Compartment", "p95")

  # if summary across all compartments then create sum
  if (is_summary==1){
    df1 <-aggregate(df1, by=list(df1$Day), FUN=sum, na.rm=TRUE)
    df2 <-aggregate(df2, by=list(df2$Day), FUN=sum, na.rm=TRUE)
    df3 <-aggregate(df3, by=list(df3$Day), FUN=sum, na.rm=TRUE)
    df1$Day <- df1$Group.1
    df2$Day <- df2$Group.1
    df3$Day <- df3$Group.1
  }

  # Combine data into single data frame
  # apply log transform
  yset <- data.frame(df1$Day, df1$Compartment, log10(df2$Median), log10(df1$p05), log10(df3$p95))
  colnames(yset)	<- c("time", "Compartment", "Median", "p05", "p95")
  yset <- yset[yset$time<info$nTime+1,]

  # filter out data before drugStart
  if (is_from_drug_start){
    yset <- yset[yset$time>info$drugStart,]
  }

  # filter out to have 1/5 of points, for more smooth curve
  #yset <- yset[seq(1, nrow(yset), 5), ]

  # apply compartment labels
  compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")

  xlabel <- "Time after infection start [Days]"
  if (is_from_drug_start) {
    xlabel <- "Time after drug start [Days]"
  }
  ylabel <- "Bacterial load [log(CFU/ml)]"
  mainTitle <- "Total Bacteria Population"

  labx	<- c(seq(0, info$nTime, by = 30))
  namesx	<- labx
  laby	<- log10(c(0.01, 0.1, 1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000, 1000000000))
  namesy	<- expression(10^-2, 10^-1, 10^0, 10^1, 10^2, 10^3, 10^4, 10^5, 10^6, 10^7, 10^8, 10^9)

  if (type=="wild")  {titleText <- "Wild-type Bacteria - "}
  if (type=="total") {titleText <- "Total Bacteria - "}

  if (is_summary==0){
    # Generate plot per compartment
    for (i in 1:4){
      yset2 <- yset[yset$Compartment==i,]
      pl <- ggplot(data = yset2, aes(x = time)) +
        geom_ribbon(aes(ymin=p05, ymax=p95), alpha=0.2) +
        geom_line(aes(y=Median), colour="blue", size=0.5) +
        theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
        scale_y_continuous(breaks = laby, labels = namesy) +
        scale_x_continuous(breaks = labx, labels = namesx) +
        xlab(xlabel) +
        ylab(ylabel) +
        #ylim(c(-2, 9)) +
        ggtitle(paste(titleText, compNames[i]))
      return(pl)
    }
  }
  if (is_summary){
    # Generate plot sum across all compartments
    pl <- ggplot(data = yset, aes(x = time)) +
      theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
      geom_ribbon(aes(ymin=p05, ymax=p95), alpha=0.2) +
      geom_line(aes(y=Median), colour="blue", size=0.5) +
      scale_y_continuous(breaks = laby, labels = namesy) +
      scale_x_continuous(breaks = labx, labels = namesx) +
      xlab(xlabel) +
      ylab(ylabel) +
      ggtitle(paste(titleText, " All Compartments"))
    return(pl)
  }
}
