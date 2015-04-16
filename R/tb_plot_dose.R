#===========================================================================
# plotDose.R
# Actual dose profiles
#
# John Fors, UCSF
# Oct 6, 2014
# Updated Ron Keizer, Apr 2015
#===========================================================================
#' @export
tb_plot_dose <- function(info, dose){

  with(dose, {
    # build data frame
    df <- data.frame(times, drugs, doses)
    df <- na.omit(df)
    colnames(df) <- c("Day", "Drug", "Dose")

    # apply actual drug codes
    if (!is.null(info)) {
      df$Drug <- info$drug[df$Drug]
    }

    # filter out zero values at start and end
    df_temp <- df[df$Dose>0,]
    minI <- df_temp$Day
    maxI <- df_temp$Day
    minTime <- max(min(minI[!is.na(minI)]) - 10, 1)
    maxTime <- min(max(maxI[!is.na(maxI)]) + 10, info$nTime)
    df <- df[df$Day>minTime,]
    df <- df[df$Day<maxTime,]

    # generate plot
    dev.new()
    bp <- ggplot(data=df, aes(x=Day, y=Dose)) +
      #geom_line(linetype="dashed", size=0.5, colour="grey") +
      geom_point(colour="red", size = 1) +
      ggtitle("Effective Dose per Drug (Median)") +
      theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
      scale_color_brewer(palette="Set1") +
      theme(legend.title=element_blank()) +
      ylab("Dose [mg]") +
      xlab("Time after infection start [Days]") +
      facet_wrap(~Drug, nrow=1, scales="free")
    return(bp)
  })
}
