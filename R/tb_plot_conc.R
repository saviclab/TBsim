#===========================================================================
# plotConc.R
# PK concentration profiles
#
# John Fors, UCSF
# Oct 6, 2014
# updated by Ron Keizer
#===========================================================================
#' @export
tb_plot_conc <- function(info, conc, filter=TRUE){

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

    df$Day <- floor(df$Hour / 24)
    df$Week <- floor(df$Day / 7)
    pl_data <- df %>%
      dplyr::group_by(Week, Compartment, Drug) %>%
      dplyr::mutate(minConc = min(Concentration), maxConc = max(Concentration), medianConc = median(Concentration)) %>%
      dplyr::filter(Hour == max(Hour)) # take min/max within every week

    # generate plot
    bp <- ggplot(data=pl_data, aes(x=Week*7, colour=Drug)) +
      geom_ribbon(aes(ymin = minConc, ymax=maxConc), size = 0, fill='#dfdfdf') +
      geom_line(aes(y = medianConc), size = 1) +
      theme_empty() +
      theme(plot.title = element_text(size=12, vjust=2),
            plot.margin = unit(c(.5,.5,.5,.3), "cm")) +
      scale_color_brewer(palette="Set1") +
      guides(colour=FALSE) +
      ylab("Concentration [mg/L]") +
      xlab("Time after first drug start (Days)") +
      facet_grid(Drug ~ Compartment, scales="free_y")
    return(bp)

  })
}
