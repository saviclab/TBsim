#===========================================================================
# plotKill.R
# EC50 kill factors
#
# John Fors, UCSF
# Oct 6, 2014
# updates Ron Keizer, 2015
#===========================================================================
#' @export
tb_plot_kill <- function(info, kill){

  # with(kill, {
  #   # build data frame
  #   df <- data.frame(times, drugs, compartments, kills)
  #   df <- na.omit(df)
  #   colnames(df) <- c("Hour", "Drug", "Compartment", "Kill")
  #
  #   # apply actual drug codes
  #   df$Drug <- info$drug[df$Drug]
  #
  #   # apply compartment labels
  #   compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
  #   df$Compartment <- compNames[df$Compartment]
  #   df$Compartment <- factor(df$Compartment,
  #                            levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))
  #
  #   # generate plot
  #   bp <- ggplot(data=df, aes(x=Hour, y=Kill)) +
  #     geom_line(size=0.5, colour="red") +
  #     ggtitle("EC50 Kill Factor per Drug") +
  #     theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
  #     scale_color_brewer(palette="Set1") +
  #     theme(legend.title=element_blank()) +
  #     ylab("Kill factor [0..1]") +
  #     xlab("Time after first drug start [Hours]") +
  #     facet_grid(Drug ~ Compartment, scales="free_y")
  #   return(bp)
  # })

  kill$concs <- kill$kill
  attr(kill, "type") <- "conc"
  pl <- tb_plot_conc(info, kill)
  return(pl)

}
