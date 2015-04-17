#===========================================================================
# plotAdherence.R
# Adherence profile, used for more advanced adherence tracking
#
# John Fors, UCSF
# Oct 10, 2014
# updates Ron Keizer, 2015
#===========================================================================
#' @export
tb_plot_adherence <- function(info, adh){

  with(adh, {
    # build data frame
    df <- data.frame(times, adh)
    df <- na.omit(df)
    colnames(df) <- c("Day", "Adh")

    # generate plot
    bp <- ggplot(data=df, aes(x=Day, y=Adh)) +
      #geom_line(linetype="dashed", size=0.5, colour="grey") +
      geom_point(colour="red", size = 1) +
      ggtitle("Patient Drug Adherence (Median)") +
      theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
      scale_color_brewer(palette="Set1") +
      theme(legend.title=element_blank()) +
      ylab("Adherence [%]") +
      xlab("Time after infection start [Days]")
    return(bp)
  })

}
