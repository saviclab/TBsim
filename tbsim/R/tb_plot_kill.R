#===========================================================================
# plotKill.R
# EC50 kill factors
#
# John Fors, UCSF
# Oct 6, 2014
# updates Ron Keizer, 2015
#===========================================================================
#' @export
tb_plot_kill <- function(info, kill, custom_drugs = NULL){

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
  #     xlab("Time after drug treatment start [Hours]") +
  #     facet_grid(Drug ~ Compartment, scales="free_y")
  #   return(bp)
  # })
  if(!is.null(kill)) {
    kill <- as.data.frame(kill)
    kill$concs <- kill$kills
    attr(kill, "type") <- "conc"
    kill <- kill[seq(1, nrow(kill), 10), ]
    pl <- tb_plot_conc(info, kill, custom_drugs = custom_drugs)
    treatment_end <- info$nTime
    if(!is.null(info$treatment_end) && !is.na(info$treatment_end)) treatment_end <- info$treatment_end+30
    labx	<- c(seq(0, treatment_end, by = 30))
    #namesx	<- labx
    pl <- pl +
      scale_x_continuous(breaks = labx, labels = labx, limits = c(min(labx), max(labx)))
    return(pl)
  }

}
