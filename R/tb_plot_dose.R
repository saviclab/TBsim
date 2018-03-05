#===========================================================================
# plotDose.R
# Actual dose profiles
#
# John Fors, UCSF
# Oct 6, 2014
# Updated Ron Keizer, Apr 2015
#===========================================================================
#' @export
tb_plot_dose <- function(info, dose){

  dat <- data.frame(
    cbind(t = dose$times,
          drug = info$drug[dose$drugs],
          dose = as.num(dose$doses))
  )
  dat$t <- as.num(dat$t)
  dat$dose <- as.num(dat$dose)
  dat$dose_start <- NA
  dat <- dat %>% filter(t < max(t))
  drugs <- unique(info$drug)
  add_dose_start <- function(tmp) {
    tmp <- dat %>% filter(drug == drug)
    tmp$dose_start <- NA
    id <- c(FALSE, diff(tmp$dose) > 0)
    tmp$dose_start[id] <- tmp$dose[id]
    tmp
  }
  dat <- dat %>% group_by(drug) %>% add_dose_start()
  dat$drug <- factor(dat$drug, levels=drug_factors)
  labx	<- c(seq(-300, info$nTime, by = 30))
  namesx	<- labx

  pl <- ggplot(dat %>%
         filter(t < max(t)) %>%
         filter(dose > 0),
         aes(x = t, y = 1, group=drug, colour=drug)) +
    geom_line(size=10) +
    geom_text(aes(x = t + max(t/20), label = dose_start), colour="#ffffff") +
    facet_grid(drug ~ .) +
    xlab("Time after drug treatment start (days)") + ylab("") +
    scale_x_continuous(breaks = labx, labels = namesx) +
    xlim(c(0, max(dat$t))) +
    theme_empty() +
    theme(axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          plot.margin = unit(c(.5,.5,.5, 1.26), "cm")) +
    guides(colour=FALSE, fill=FALSE)

  return(pl)
}
