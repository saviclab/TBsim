#===========================================================================
# plotAdherence.R
# Adherence profile, used for more advanced adherence tracking
#
# John Fors, UCSF
# Oct 10, 2014
# updates Ron Keizer, 2015
#===========================================================================
#' @export
tb_plot_adherence <- function(info, adh, is_from_drug_start = TRUE, ...){

  colnames(adh) <- c("Day", "Adh")

  if(is_from_drug_start){
    adh <- adh[adh$Day > info$drugStart,]
  }
  adh$Day <- adh$Day - info$drugStart

  # generate plot
  bp <- ggplot(data=adh, aes(x=Day, y=100*Adh)) +
    # geom_point(colour="#052049", size = 1) +
    geom_line(colour="#052049", size = 1) +
    ggtitle("Patient Drug Adherence (Median)") +
    theme(plot.title = element_text(size=12, vjust=2)) +
    scale_color_brewer(palette="Set1") +
    theme(legend.title=element_blank()) +
    ylab("%") +
    xlab("Time after infection (Days)")
  return(bp)

}
