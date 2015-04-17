#===========================================================================
# plotEffect.R
# Plot bacterial killing contribution per drug and immune system
# and totals or per compartment
#
# John Fors, UCSF
# Oct 20, 2014
# Updates Ron Keizer, 2015
#===========================================================================
tb_plot_effect <- function(info, effect){

  timePeriods <- 1:info$nTime

  with (effect, {
    # build dataframe 1
    df1 <- data.frame(times, types, compartments, values)
    colnames(df1) <- c("Day", "Type", "Compartment", "Median")

    # filter out data before drugStart
    isFromDrugStart <- 1
    if (isFromDrugStart==1){
      df1 <- df1[df1$Day > info$drugStart,]
    }

    # filter out to have 1/5 of points, for more smooth curve
    df1 <- df1[seq(1, nrow(df1), 5), ]

    # create 2 subsets, one for relative data, and one for totals
    yset1 <- df1[df1$Type>0,]
    yset1 <- yset1[!is.na(yset1$Type), ]
    yset1 <- data.frame(yset1$Day, yset1$Type, yset1$Compartment, yset1$Median)
    colnames(yset1)  <- c("Day", "Type", "Compartment", "Median")

    # RK this data is not available, so don't make pl2
#     yset2 <- df1[df1$Type==0,]
#     yset2 <- yset2[!is.na(yset2$Type), ]
#     yset2 <- data.frame(yset2$Day, yset2$Compartment, yset2$Median)
#     colnames(yset2)	<- c("Day", "Compartment", "Median")

    # apply compartment labels
    compNames <- c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma")
    yset1$Compartment <- compNames[yset1$Compartment]
    yset1$Compartment <- factor(yset1$Compartment,
                                levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))
#     yset2$Compartment <- compNames[yset2$Compartment]
#     yset2$Compartment <- factor(yset2$Compartment,
#                                 levels = c("Extracellular", "Intracellular", "Extracell Granuloma", "Intracell Granuloma"))

    # apply drug names
    if (is.null(info$drugNames)) { # added RK, variable did not exist in info
      info$drugNames <- info$drug
    }
    info$drugNames[info$nDrugs+1] <- "Immune"
    yset1$Type <- info$drugNames[yset1$Type]
    yset1$Type <- factor(yset1$Type, levels = c(info$drugNames[1:info$nDrugs], info$drugNames[info$nDrugs+1]))

    xlabel		<- "Time after infection start [Days]"
    ylabel		<- "Bactericidal effect [% of total]"
    titleText	<- "Relative Bactericidal Effect per Drug and Immune System "

    # The palette with grey:
    cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#0072B2", "#F0E442", "#D55E00", "#CC79A7")
    pl1 <- ggplot(data = yset1, aes(x = Day, y=Median, group=Type, colour=Type)) +
      geom_line(size=1.0) +
      theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
      xlab(xlabel) +
      ylab(ylabel) +
      scale_colour_manual(values=cbPalette) +
      ggtitle(titleText) +
      facet_wrap(~Compartment, nrow=1)

#     ylabel		<- "Bactericidal [CFU/day]"
#     titleText	<- "Absolute Killing per Compartment (note scale)"
#     pl2 <- ggplot(data = yset2, aes(x = Day)) +
#       geom_line(aes(y=Median), colour="blue", size=1.0) +
#       theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
#       xlab(xlabel) +
#       ylab(ylabel) +
#       ggtitle(titleText) +
#       facet_wrap(~Compartment, nrow=1, scales="free_y")

    return(pl1)
  })
}
