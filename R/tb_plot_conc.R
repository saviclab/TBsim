#===========================================================================
# plotConc.R
# PK concentration profiles
#
# John Fors, UCSF
# Oct 6, 2014
# updated by Ron Keizer
#===========================================================================
#' @export
tb_plot_conc <- function(info,conc){

  # build data frame
  with(conc, {
    df <- data.frame(times, drugs, compartments, concs)
    df <- na.omit(df)
    colnames(df) <- c("Hour", "Drug", "Compartment", "Concentration")

    # apply actual drug codes
    if (!is.null(info)) {
      df$Drug <- info$drug[df$Drug]
    }

    # apply compartment labels
    compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
    df$Compartment <- compNames[df$Compartment]
    df$Compartment <- factor(df$Compartment,
                             levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))

    # generate plot
    bp <- ggplot(data=df, aes(x=Hour/24, y=Concentration)) +
      geom_line(size=0.5, colour="red") +
      ggtitle("PK Concentration Profile per Drug (Average)") +
      theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
      scale_color_brewer(palette="Set1") +
      theme(legend.title=element_blank()) +
      ylab("Concentration [mg/L]") +
      xlab("Time after first drug start [Days]") +
      facet_grid(Drug ~ Compartment, scales="free_y")
    return(bp)

  })
}
