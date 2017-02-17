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

    # apply drug names
    if (is.null(info$drugNames)) { # added RK, variable did not exist in info
      info$drugNames <- info$drug
    }
    nDrugs <- length(unique(info$drugNames))
    info$drugNames[nDrugs+1] <- "Immune"
    df$Type <- info$drugNames[df$Type]
    df$Type <- factor(df$Type, levels = c(info$drugNames[1:nDrugs], info$drugNames[nDrugs+1]))

    # generate plot
    bp <- ggplot(data=df, aes(x=Hour, y=Load, colour=Type)) +
      geom_line(size=1) +
      theme_empty() +
      ggtitle("Resistant bacteria") +
      theme(plot.title = element_text(size=12, vjust=2)) +
      scale_color_brewer(palette="Set1") +
      theme(legend.title=element_blank()) +
      ylab("Load") +
      xlab("Time after first drug start [Hours]") +
      facet_grid( ~ Compartment, scales="free") 
    return(bp)

  })
}
