#' Gather TBsim plots into an object for showing in Shiny
#'
#' @export
gather_plots <- function(id,
  user,
  session,
  type = "population",
  quick_sim = NULL,
  drug_definitions = NULL,
  custom_drugs = NULL) {

    output <- list()
    res <- list()
    folder <- paste0("/data/tbsim/", user, "/", id)
    if(is.null(quick_sim)) {
      if(file.exists(paste0(folder, "/output/bactTotals.txt"))) {
        quick_sim <- FALSE
      } else {
        quick_sim <- TRUE
      }
    }
    if(quick_sim) {
      res <- list(
        info  = tb_read_output(folder, "header", output_folder = TRUE),
        outc  = tb_read_output(folder, "outcome", output_folder = TRUE)
      )
    } else {
      res <- TBsim::tb_read_all_output(
        folder,
        output=TRUE)
    }
    suffix <- "Pop"
    if(type == "single") {
      suffix <- ""
    }
    output$res <- res

    ## standard colors
    regimenColors <- get_standard_colors(custom_drugs)

    ## Create plots
    if(!is.null(res$conc)) {
      output[[paste0("plotPK", suffix)]] <- plotPK(res, cv = NULL,
          custom_drugs = custom_drugs,
          regimen_colors = regimenColors)
    }
    if(!is.null(res$dose)) {
      output[[paste0("plotDose", suffix)]] <- plotDose(folder, drug_definitions)
    }
    if(!is.null(res$kill)) {
      output[[paste0("plotKill", suffix)]] <- plotKill(res,
          custom_drugs = custom_drugs,
          regimen_colors = regimenColors)
    }
    # output[[paste0("plotEffect", suffix)]] <- plotEffect(res,
        # custom_drugs = custom_drugs,
        # regimen_colors = regimenColors)
    if(!is.null(res$bact)) {
      output[[paste0("plotBact", suffix)]] <- plotBact(res)
      output[[paste0("plotBactSplit", suffix)]] <- plotBactSplit(res)
    }
    if(!is.null(res$bactRes)) {
      output[[paste0("plotBactRes", suffix)]] <- plotBactRes(res,
        custom_drugs = custom_drugs,
        regimen_colors = regimenColors)
    }
    if(!is.null(res$outc)) {
      output[[paste0("plotOutcome", suffix)]] <- plotOutcome(res)
      output$outc <- signif((1 - res$outc$AcuteTB) * 100,3)
    }
    # output[[paste0("plotImmuneCytoLung", suffix)]] <- plotImmuneCytoLung(res)
    # output[[paste0("plotImmuneCytoLymph", suffix)]] <- plotImmuneCytoLymph(res)
    # output[[paste0("plotImmuneCytoDendr", suffix)]] <- plotImmuneCytoDendr(res)
    # output[[paste0("plotImmuneTLung", suffix)]] <- plotImmuneTLung(res)
    # output[[paste0("plotImmuneTHelper", suffix)]] <- plotImmuneTHelper(res)
    # output[[paste0("plotImmuneTNaive", suffix)]] <- plotImmuneTNaive(res)

    output$settings <- read_settings_summary(folder, settingsInfo)

    return(output)
}
