#===========================================================================
# plotOutcome.R
# Therapy outcome statistics for population
#
# John Fors, UCSF
# Oct 6, 2014
# Updated Ron Keizer, Apr 2015
#===========================================================================
#' @export
tb_plot_outcome <- function(info,
                            outcome,
                            is_from_drug_start = FALSE,
                            is_combine_lat_clr = TRUE) {

  timePeriods <- 1:info$nTime

  # build dataframe
  df1c <- data.frame(outcome$times, outcome$NoTB, outcome$NoTBp05, outcome$NoTBp95)
  colnames(df1c) <- c("Day", "NoTBAvg", "NoTBp05", "NoTBp95")
  df1c <- df1c[1:info$nTime,]

  df2c <- data.frame(outcome$times, outcome$AcuteTB, outcome$AcuteTBp05, outcome$AcuteTBp95)
  colnames(df2c) <- c("Day", "AcuteTBAvg", "AcuteTBp05", "AcuteTBp95")
  df2c <- df2c[1:info$nTime,]

  df3c <- data.frame(outcome$times, outcome$ClearedTB, outcome$ClearedTBp05, outcome$ClearedTBp95)
  colnames(df3c) <- c("Day", "ClearedTBAvg", "ClearedTBp05", "ClearedTBp95")
  df3c <- df3c[1:info$nTime,]

  df4c <- data.frame(outcome$times, outcome$LatentTB, outcome$LatentTBp05, outcome$LatentTBp95)
  colnames(df4c) <- c("Day", "LatentTBAvg", "LatentTBp05", "LatentTBp95")
  df4c <- df4c[1:info$nTime,]

  # estimate the 5/95 percentiles by estimating composite variance of latent and cleared
  with(outcome, {
    LatentDiff95  <- (LatentTBp95 - LatentTB) * 0.5
    LatentDiff05	<- (LatentTB - LatentTBp05) * 0.5
    ClearedDiff95	<- (ClearedTBp95 - ClearedTB) * 0.5
    ClearedDiff05	<- (ClearedTB - ClearedTBp05) * 0.5
    cDiff95 <- sqrt(LatentDiff95 * LatentDiff95 + ClearedDiff95 * ClearedDiff95) * 2.0
    cDiff05 <- sqrt(LatentDiff05 * LatentDiff05 + ClearedDiff05 * ClearedDiff05) * 2.0

    # combined metric: cleared + latent TB
    df5c <- data.frame(times, LatentTB+ClearedTB, LatentTB+ClearedTB - cDiff95, LatentTB+ClearedTB + cDiff95)
    colnames(df5c) <- c("Day", "cTBAvg", "cTBp05", "cTBp95")
    df5c <- df5c[1:info$nTime,]

    # combine all pieces into a single data frame
    yset <- data.frame(timePeriods,
      #df1c$NoTBAvg,  df1c$NoTBp05,  	df1c$NoTBp95,
                       df2c$AcuteTBAvg,   df2c$AcuteTBp05,		df2c$AcuteTBp95,
                       df3c$ClearedTBAvg, df3c$ClearedTBp05,	df3c$ClearedTBp95,
                       df4c$LatentTBAvg,  df4c$LatentTBp05,	df4c$LatentTBp95,
                       df5c$cTBAvg,       df5c$cTBp05,			df5c$cTBp95)
    yset[,-1] <- yset[,-1] * 100
    colnames(yset) <- c("time",
                        #"NTB50", "NTBp05", "NTBp95",
                        "ATB50", "ATBp05", "ATBp95",
                        "CTB50", "CTBp05", "CTBp95",
                        "LTB50", "LTBp05", "LTBp95",
                        "cTB50", "cTBp05", "cTBp95")

    # filter out data before drugStart
    if (is_from_drug_start == 1) {
      yset <- yset[yset$time>info$drugStart,]
    }
    yset$time <- yset$time - info$drugStart

    # trim to only include every 5th data point
    yset <- yset[seq(1, nrow(yset), 5), ]

    dfm <- yset

    mainTitle   <- "Patient Population Treatment Outcome"
    labx  <- c(seq(-300, info$nTime, by = 30))
    namesx	<- labx
    laby	<- c(0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100)
    namesy	<- laby

    # Generate plot
    dfm$CTBp05 <- replace(dfm$CTBp05, dfm$CTBp05 > 100, 100)
    dfm$CTBp95 <- replace(dfm$CTBp95, dfm$CTBp95 > 100, 100)
    dfm$CTB50 <- replace(dfm$CTB50, dfm$CTB50 > 100, 100)

    pl <- ggplot(data = dfm, aes(x = time))
    if(!is.null(info$treatment_end)) {
      pl <- pl +
        geom_vline(xintercept = c(0, info$treatment_end), linetype = 'dashed') +
        geom_rect(aes(xmin = 0, xmax = info$treatment_end, ymin = 0, ymax = Inf),
          fill = "#efefef", colour=NA)
    }
    pl <- pl +
      geom_ribbon(aes(ymin=100-ATBp05, ymax=100-ATBp95), alpha=0.2) +
      geom_line(aes(y=100-ATB50), colour="blue",size=1) +
      # geom_line(aes(y=ATB50), colour="red",size=1) +
      # geom_line(aes(y=LTB50), colour="blue",size=1) +
      # geom_line(aes(y=CTB50), colour="green",size=1) +
      xlab("Time after drug start (Days)") +
      ylab("% patients cleared of TB") +
      scale_x_continuous(breaks = labx, labels = namesx) +
      scale_y_continuous(breaks = laby , labels = namesy)
    if (is_combine_lat_clr){
      pl <- pl + scale_colour_manual(name = 'Outcome',
                                     values = c('blue'='#377eb8', 'red'='#e41a1c'),
                                     labels = c('Cleared', 'Acute'))
    } else {
      pl <- pl + scale_colour_manual(name = 'Outcome',
                                     values = c('blue'='blue', 'black'='black', 'red'='red'),
                                     labels = c('Cleared', 'Latent', 'Acute'))
    }
    pl <- pl +
      expand_limits(y=0) +
      theme_empty() +
      theme(plot.title = element_text(size=16, face="bold", vjust=2)) +
      ggtitle(mainTitle)
    return(pl)

  })

}
