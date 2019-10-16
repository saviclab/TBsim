#' Plot MEMS
#' @export
plotMEMS <- function(memsFile) {
  # dat <- read.csv("/data/tbsim/anon_local/2kmAUy/config/mems.csv")
  dat <- read.csv(memsFile)
  adh <- apply(dat, 2, "sum") %>%
    data.frame() %>%
    tidyr::gather(day, adh) %>%
    dplyr::mutate(day = 1:ncol(dat), adh = adh / 200)
  #if(nrow(dat) > 1) {
  pl <- ggplot2::ggplot(adh, aes(x = day, y = adh * 100)) +
      geom_line() +
      xlab("Treatment") + ylab("Mean adherence (%)") +
      ggtitle("Adherence") +
      theme_empty() +
      theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom") +
      ylim(c(0, 100))
  # }
  return(pl)
}

#' Plot adherence
#' @export
plotAdherence <- function(res) {
  ## filter only treatment period
  res$adherence <- res$adherence[res$adherence$time < (res$info$drugStart + res$info$treatment_end),]
  pl <- TBsim::tb_plot (
    res$info, res$adherence,
    theme = NULL, is_from_drug_start = TRUE) +
    ggtitle("Adherence") +
    theme_empty() +
    xlab("Day") +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom") +
    ylim(c(0, 100))
  return(pl)
}

#' Plot PK
#' @export
plotPK <- function(res, time_filter=c(0, 7), cv = NULL,
  custom_drugs = NULL, regimen_colors = NULL) {
  pl <- TBsim::tb_plot (res$info, res$conc,
    theme=NULL, time_filter = time_filter, cv = cv,
    custom_drugs = custom_drugs) +
    ggtitle("PK Concentration Profile per Drug") +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom")
  if(!is.null(regimen_colors)) {
    pl <- pl + scale_colour_manual(values = regimen_colors)
  }
  return(pl)
}

#' Plot Outcome
#' @export
plotOutcome <- function(res) {
  library(ggplot2)
  pl <- TBsim::tb_plot (res$info, res$outc, theme=NULL) +
    ggtitle(paste0("% patients cleared of TB (from n=", res$info$nPatients, " simulated patients)")) +
    theme(
      # plot.title=element_blank(),
      legend.position="none",
      # legend.position = c(.4, .8),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      legend.background = element_blank(),
      legend.key = element_rect(fill="#e0e0e0", size=0),
      # panel.background = element_rect(fill="#e0e0e0", size=0),
      plot.background = element_rect(fill = "#ffffff", size=0)
    ) +
    xlab("Day") + ylab("%") + ylim(c(0, 100))
  return(pl)
}

#' Plot Dose
#' @export
plotDose <- function(
  folder, 
  drugDefinitions,
  regimen_colors = NULL) {
  get_standard_colors(cache$combinedDrugList)
  pl <- plot_regimen(folder, drugDefinitions) +
    ggtitle("Dosing regimen") +
    theme_empty() +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom") +
    xlab("Day")
  if(!is.null(regimen_colors)) {
    pl <- pl + scale_colour_manual(values = regimen_colors)
  }
  return(pl)
}

#' Plot Regimen
#' @export
plot_regimen <- function(folder, drugDefinitions = NULL) {
  reg <- load_regimen(folder = paste0(folder, "/config"),
                      drugDefinitions = drugDefinitions)
  names(reg) <- c("Drug", "Dose", "Start", "Duration", "Frequency", "Include")
  reg2 <- data.frame(
    rbind(cbind(as.character(reg$Drug), as.num(reg$Dose), as.num(reg$Start), as.character(reg$Frequency), 1),
          cbind(as.character(reg$Drug), as.num(reg$Dose), as.num(reg$Start) + as.num(reg$Duration), as.character(reg$Frequency), 0)))
  colnames(reg2) <- c("Drug", "Dose", "Treatment", "Frequency", "Start")
  reg2$grp <- rep(1:length(reg$Drug), 2)
  reg2$Dose <- as.num(reg2$Dose)
  reg2$Treatment <- as.num(reg2$Treatment)
  reg2$Frequency <- as.character(reg2$Frequency)
  trans <- list(
    "Once daily" = "1dd",
    "Once weekly" = "1/wk",
    "Twice weekly" = "2/wk",
    "Thrice weekly" = "3/wk"
  )
  reg2$Frequency <- trans[reg2$Frequency]
  reg2$lab <- paste0(reg2$Dose, " ", reg2$Frequency)
  nam <- names(drugDefinitions)
  nam <- nam[nam %in% reg2$Drug]
  reg2$Drug <- factor(reg2$Drug, levels = nam)
  labx	<- c(seq(0, 300, by = 30))
  namesx	<- labx
  pl <- ggplot(reg2, aes(x = Drug, y = Treatment)) + geom_line(
    aes(group = grp, colour = Drug), size = 10) +
    geom_text(data = reg2 %>% dplyr::filter(Start == 1),
      aes(y = Treatment + 5, label = lab), hjust = 0, size=3.5, color='white') +
    coord_flip() + 
    xlab("") +
    scale_y_continuous(breaks = labx, labels = namesx) +
    scale_x_discrete() +
    guides(colour=FALSE, fill=FALSE)
  return(pl)
}

#' Plot kill
#' @export
plotKill <- function(res,
  custom_drugs = NULL, 
  regimen_colors = NULL) {

  dummy <- plot.new() + text(0.5,0.5,"Sorry, data for plot not available.")
  if(!is.null(res$kill)) {
    res$kill$kills <- ifelse(res$kill$kills > 1, 1, res$kill$kills) # set max
    pl <- TBsim::tb_plot(res$info, res$kill, theme=NULL,
      custom_drugs = custom_drugs) +
      ggtitle("EC50 Kill Factor per Drug") +
      scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
              labels = scales::trans_format("log10", scales::math_format(10^.x)))
    if(!is.null(regimen_colors)) {
      pl <- pl + scale_colour_manual(values = regimen_colors)
    }
      # theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom") +
      # scale_colour_manual(values = regimen_colors) +
      # ylab("Kill factor")
  } else {
    pl <- dummy
  }
  return(pl)
}

#' Plot effect
#' @export
plotEffect <- function(res,
  custom_drugs = NULL, regimen_colors = NULL) {
    dummy <- plot.new() + text(0.5,0.5,"Sorry, data for plot not available.")
    if(!is.null(res$eff) && "types" %in% names(res$eff)) {
      pl <- TBsim::tb_plot (res$info, res$eff, theme=NULL) +
        theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom") +
        scale_colour_manual(values = regimen_colors)
    } else {
      pl <- dummy
    }
  return(pl)
}

#' Plot Immune Cyto Lung
#' @export
plotImmuneCytoLung <- function(res) {
  imm_pl <- TBsim::tb_plot(res$info, res$imm, theme=NULL)
  lims <- calc_log_breaks(imm_pl$cytokines_lung$data$value)
  pl <- imm_pl$cytokines_lung +
    scale_y_log10(breaks = lims, limits = range(lims)) +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom")+
    scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
            labels = scales::trans_format("log10", scales::math_format(10^.x)))

  return(pl)
}

#' Plot Immune Cyto Lymph
#' @export
plotImmuneCytoLymph <- function(res) {
  imm_pl <- TBsim::tb_plot(res$info, res$imm, theme=NULL)
  lims <- calc_log_breaks(imm_pl$cytokines_lymph$data$value)
  pl <- imm_pl$cytokines_lymph +
    scale_y_log10(breaks = lims, limits = range(lims)) +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom")+
    scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
            labels = scales::trans_format("log10", scales::math_format(10^.x)))

  return(pl)
}

#' Plot Immune Cyto Dendr
#' @export
plotImmuneCytoDendr <- function(res) {
  imm_pl <- TBsim::tb_plot(res$info, res$imm, theme=NULL)
  lims <- calc_log_breaks(c(
    imm_pl$cytokines_dendr$data$value,
    imm_pl$t_naive$data$value
  ))
  pl <- imm_pl$cytokines_dendr +
    scale_y_log10(breaks = lims, limits = range(lims)) +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom")+
    scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
            labels = scales::trans_format("log10", scales::math_format(10^.x)))

  return(pl)
}

#' Plot Immune T Lung
#' @export
plotImmuneTLung <- function(res) {
  imm_pl <- TBsim::tb_plot(res$info, res$imm, theme=NULL)
  lims <- calc_log_breaks(imm_pl$t_cells_lung$data$value)
  pl <- imm_pl$t_cells_lung +
    scale_y_log10(breaks = lims, limits = range(lims)) +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom")+
    scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
            labels = scales::trans_format("log10", scales::math_format(10^.x)))


  return(pl)
}

#' Plot Immune T Helper
#' @export
plotImmuneTHelper <- function(res) {
  imm_pl <- TBsim::tb_plot(res$info, res$imm, theme=NULL)
  lims <- calc_log_breaks(imm_pl$t_helper$data$value)
  pl <- imm_pl$t_helper +
    scale_y_log10(breaks = lims, limits = range(lims)) +
      theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom")+
      scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
              labels = scales::trans_format("log10", scales::math_format(10^.x)))

  return(pl)
}

#' Plot Immune T Naive
#' @export
plotImmuneTNaive <- function(res) {
  imm_pl <- TBsim::tb_plot(res$info, res$imm, theme=NULL)
  lims <- calc_log_breaks(c(
    imm_pl$cytokines_dendr$data$value,
    imm_pl$t_naive$data$value
  ))
  pl <- imm_pl$t_naive +
    scale_y_log10(breaks = lims, limits = range(lims)) +
    theme(plot.title = element_text(size=12, vjust=2), legend.position="bottom")+
    scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
            labels = scales::trans_format("log10", scales::math_format(10^.x)))

  return(pl)
}

#' Plot Bacterial load
#' @export
plotBact <- function(res) {
  pl <- TBsim::tb_plot (res$info, res$bact, type = "total",
    is_summary = TRUE,
    #is_from_drug_start = FALSE,
    theme=NULL) +
      ggtitle("Bacterial load, total") +
      theme(plot.title = element_text(size=12, face=NULL, vjust=2)) +
      scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
              labels = scales::trans_format("log10", scales::math_format(10^.x)))

  # tb_plot (info, bact, type="total")
  return(pl)
}

#' Plot Bacterial load split by compartment
#' @export
plotBactSplit <- function(res) {
  pl <- TBsim::tb_plot (res$info, res$bact, type = "total",
    is_summary = FALSE,
    #is_from_drug_start = FALSE,
    theme=NULL) +
      ggtitle("Bacterial load, by compartment") +
      theme(plot.title = element_text(size=12, face=NULL, vjust=2)) +
      xlim(c(-40, ifelse(!is.null(res$info$treatment_end), res$info$treatment_end + 30, 250))) +
      scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
              labels = scales::trans_format("log10", scales::math_format(10^.x)))

  # tb_plot (info, bact, type="total")
  return(pl)
}

#' Plot bacterial resistance
#' @export
plotBactRes <- function(res,
  custom_drugs = NULL, regimen_colors = NULL) {
  pl <- TBsim::tb_plot (res$info, res$bactRes, theme=NULL,
    is_from_drug_start = FALSE,
    is_summary = TRUE) +
    theme(plot.title = element_text(size=12, face=NULL, vjust=2), legend.position="bottom") +
    scale_colour_manual(values = regimen_colors) +
    scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
            labels = scales::trans_format("log10", scales::math_format(10^.x)))


  return(pl)
}

#' Plot Bacterial resistance split by compartment
#' @export
plotBactResSplit <- function(res,
  custom_drugs = NULL, regimen_colors = NULL) {
  pl <- TBsim::tb_plot (res$info, res$bactRes, theme=NULL,
     is_summary = FALSE,
     is_from_drug_start = FALSE
     ) +
    theme(plot.title = element_text(size=12, face=NULL, vjust=2), legend.position="bottom") +
    scale_colour_manual(values = regimen_colors) +
    xlim(c(-40, ifelse(!is.null(res$info$treatment_end), res$info$treatment_end + 30, 250)))+
    scale_y_log10(breaks = scales::trans_breaks("log10", function(x) 10^x),
            labels = scales::trans_format("log10", scales::math_format(10^.x)))

  return(pl)
}
