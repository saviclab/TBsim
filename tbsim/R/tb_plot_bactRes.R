#===========================================================================
# ploBactRes.R
# Resistant bacterial results
#
# Ron Keizer, 2016
#===========================================================================
#' @export
tb_plot_bactRes <- function(info, bact = NULL,
                            type = "total", is_summary = TRUE,
                            is_from_drug_start = FALSE) {

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
    }
    df$Days <- df$Days - info$drugStart

    if (is_summary) {
      df <- df %>% dplyr::group_by(Type, Days) %>% dplyr::mutate(Load = sum(Load))
    }

    labx	<- c(seq(-300, info$nTime, by = 30))
    namesx	<- labx
    xlabel <- "Time after drug start (Days)"

    ## generate plot
    # df <- df %>% mutate(Load = max(1, Load))
    # RK not sure why the above line was included

    # df$Load[df$Load < 1] <- 1
    # max_load <- max(df$Load)
    # if(max_load <= 10) {
    #   max_load <- 10
    # }
    pl <- ggplot(data=df, aes(x=Days, y=Load * 1e6, colour=Type))
    if(!is.null(info$treatment_end)) {
      pl <- pl +
        geom_vline(xintercept = c(0, info$treatment_end), linetype = 'dashed') +
        geom_rect(aes(xmin = 0, xmax = info$treatment_end, ymin = 0, ymax = Inf),
          fill = "#efefef", colour=NA)
    }
    pl <- pl +
      geom_line(size=1) +
      theme_empty() +
      ggtitle("Resistant bacteria") +
      theme(plot.title = element_text(size=12, vjust=2)) +
      scale_color_brewer(palette="Set1") +
      scale_y_log10() +
      scale_x_continuous(breaks = labx, labels = namesx) +
      # scale_y_continuous(labels = scales::scientific) +
      theme(legend.title=element_blank()) +
      ylab("Resistant bacterial load (CFU/mL)") +
      xlab(xlabel) +
      geom_hline(yintercept=1, linetype = "dashed")
    if (!is_summary) {
      pl <- pl + facet_wrap(~ Compartment, scales="free_y")
    }
    return(pl)
  })
}
