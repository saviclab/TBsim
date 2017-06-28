#===========================================================================
# ploBactRes.R
# Resistant bacterial results
#
# Ron Keizer, 2016
#===========================================================================
#' @export
tb_plot_bactRes <- function(info, bact = NULL,
                            type = "total", is_summary = TRUE, is_from_drug_start = TRUE) {

  # build data frame
  with(bact, {

    df <- data.frame(times, types, compartments, values)
    df <- na.omit(df)
    colnames(df) <- c("Days", "Type", "Compartment", "Load")


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

    # filter out data before drugStart
    if (is_from_drug_start){
      df <- df[df$Days > info$drugStart,]
      df$Days <- df$Days - info$drugStart
    }

    if (is_summary) {
      df <- df %>% dplyr::group_by(Type, Days) %>% dplyr::mutate(Load = sum(Load))
    }


    ## generate plot
    # df <- df %>% mutate(Load = max(1, Load))
    # RK not sure why the above line was included

    # df$Load[df$Load < 1] <- 1
    # max_load <- max(df$Load)
    # if(max_load <= 10) {
    #   max_load <- 10
    # }
    bp <- ggplot(data=df, aes(x=Days, y=Load, colour=Type)) +
      geom_line(size=1) +
      theme_empty() +
      ggtitle("Resistant bacteria") +
      theme(plot.title = element_text(size=12, vjust=2)) +
      scale_color_brewer(palette="Set1") +
      scale_y_log10() +
      theme(legend.title=element_blank()) +
      ylab("Resistant bacterial load (CFU/mL)") +
      xlab("Time after first drug start (Days)") +
      geom_hline(yintercept=1, linetype = "dashed")
    if (!is_summary) {
      bp <- bp + facet_wrap(~ Compartment, scales="free_y")
    }

      #+
      #ggplot2::ylim(c(1, max_load))
    return(bp)
  })
}
