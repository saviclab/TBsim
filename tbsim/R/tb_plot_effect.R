#===========================================================================
# plotEffect.R
# Plot bacterial killing contribution per drug and immune system
# and totals or per compartment
#
# John Fors, UCSF
# Oct 20, 2014
# Updates Ron Keizer, 2015
#===========================================================================
tb_plot_effect <- function(info, effect,
  is_from_drug_start = FALSE){

  timePeriods <- 1:info$nTime

  with (effect, {

    # build dataframe 1
    unq <- length(unique(types)) * length(unique(compartments))
    times_new <- rep(
      1:(length(types) / unq),
      unq)
    df1 <- data.frame(
      times_new,
      types,
      compartments,
      values)
    colnames(df1) <- c("Day", "Type", "Compartment", "Median")

    # filter out data before drugStart
    # isFromDrugStart <- 1
    # if (isFromDrugStart==1){
    #   df1 <- df1[df1$Day > info$drugStart,]
    # }

    # filter out to have 1/5 of points, for more smooth curve
    df1 <- df1[seq(1, nrow(df1), 5), ]

    # create 2 subsets, one for relative data, and one for totals
    yset1 <- df1[df1$Type>0,]
    yset1 <- yset1[!is.na(yset1$Type), ]
    yset1 <- data.frame(yset1$Day, yset1$Type, yset1$Compartment, yset1$Median)
    colnames(yset1)  <- c("Day", "Type", "Compartment", "Median")

    # filter out data before drugStart
    if (is_from_drug_start){
      yset1 <- yset1[yset1$Day > info$drugStart,]
    }
    yset1$Day <- yset1$Day - info$drugStart

    # apply compartment labels
    compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
    yset1$Compartment <- compNames[yset1$Compartment]
    yset1$Compartment <- factor(yset1$Compartment,
                                levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))
    # apply drug names
    if (is.null(info$drugNames)) { # added RK, variable did not exist in info
      info$drugNames <- info$drug
    }
    info$drugNames[[info$nDrugs+1]] <- "Immune"
    yset1$Type <- info$drugNames[yset1$Type]
    yset1$Type <- factor(yset1$Type, levels = info$drugNames)

    labx	<- c(seq(-300, info$nTime, by = 60))
    namesx	<- labx
    xlabel		<- "Time after drug treatment start (Days)"
    ylabel		<- "Bactericidal effect (% of total)"
    titleText	<- "Bactericidal Effect per Drug and Immune System "

    # The palette with grey:
    cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#0072B2", "#F0E442", "#D55E00", "#CC79A7")
    pl <- ggplot(data = yset1, aes(x = Day, y=Median * 100, group=Type, colour=Type))
    if(!is.null(info$treatment_end)) {
      pl <- pl +
        geom_vline(xintercept = c(0, info$treatment_end), linetype = 'dashed') +
        geom_rect(aes(xmin = 0, xmax = info$treatment_end, ymin = 0, ymax = Inf),
          fill = "#efefef", colour=NA)
    }
    pl <- pl +
      geom_line(size=1.0) +
      theme_empty() +
      theme(plot.title = element_text(size=12, vjust=2)) +
      xlab(xlabel) +
      ylab(ylabel) +
      scale_x_continuous(breaks = labx, labels = namesx) +
      scale_color_brewer(palette="Dark2") +
  #    scale_colour_manual(values=cbPalette) +
      ggtitle(titleText) +
      facet_wrap(~Compartment, nrow=1)

    return(pl)
  })
}
