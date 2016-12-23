#===========================================================================
# ploBactRes.R
# Resistant bacterial results
#
# Ron Keizer, 2016
#===========================================================================
#' @export
tb_plot_bactRes <- function(info, bact){

  # build data frame
  with(bact, {

    df <- data.frame(times, types, compartments, values)
    df <- na.omit(df)
    colnames(df) <- c("Hour", "Type", "Compartment", "Load")


    # apply compartment labels
    compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
    df$Compartment <- compNames[df$Compartment]
    df$Compartment <- factor(df$Compartment,
                             levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))

    # generate plot
    bp <- ggplot(data=df, aes(x=Hour, y=Load)) +
      geom_line(size=0.5, colour="red") +
      ggtitle("Resistant bacteria") +
      theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
      scale_color_brewer(palette="Set1") +
      theme(legend.title=element_blank()) +
      ylab("Load") +
      xlab("Time after first drug start [Hours]") +
      facet_grid(Type ~ Compartment, scales="free")
    return(bp)

  })
}
