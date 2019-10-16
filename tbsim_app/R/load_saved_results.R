#' Load saved results
#'
#' @export
load_saved_results <- function(
  id,
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
  if(file.exists(paste0(folder, "/output/header.txt"))) {
    if(quick_sim) {
      res <- list(
        info  = tb_read_output(
          folder, "header",
          output_folder = TRUE),
        outc  = tb_read_output(
          folder, "outcome",
          output_folder = TRUE)
      )
    } else {
      res <- TBsim::tb_read_all_output(
        folder,
        output_folder = TRUE)
    }
  } else {
    return(NULL)
  }
  ## Get treatment end day from config file
  res$regimen <- TBsim::tb_read_init(
    file = "config/therapy.txt",
    folder = folder
  )
  res$info$treatment_end <- 0
  if(!is.null(res$regimen$drug)) {
      tmp <- stringr::str_split(res$regimen$drug, "\\|")
      tmax <- 0
      for(i in seq(tmp)) {
        start_end <- as.num(tmp[[i]][3:4])
        if(sum(start_end) > tmax) tmax <- sum(start_end)
      }
      res$info$treatment_end <- tmax
  }

  suffix <- "Pop"
  if(type == "single") {
    suffix <- ""
  }
  output$res <- res

  ## standard colors
  regimenColors <- get_standard_colors(custom_drugs)
  dummy <- plot.new() + text(0.5,0.5,"Sorry, data for plot not available.")

  if((type == "population" && !quick_sim) || type == "single") {
    output[[paste0("plotPK", suffix)]] <- renderPlot({
      pl  <- plotPK(res, cv = NULL,
        custom_drugs = custom_drugs,
        regimen_colors = regimenColors)
      return(pl)
    })
    ## Adherence plot
    # output[[paste0("plotMEMS", suffix)]] <- renderPlot({
    #   pl  <- plotMEMS(memsFile = paste0(folder, "/config/mems.csv"))
    #   return(pl)
    # })
    output[[paste0("plotAdherence", suffix)]] <- renderPlot({
      pl  <- plotAdherence(res)
      return(pl)
    })

    output[[paste0("plotDose", suffix)]] <- renderPlot({
      pl <- plotDose(folder, drug_definitions, regimen_colors = regimenColors)
      return(pl)
    })
    output[[paste0("plotKill", suffix)]] <- renderPlot({
      pl <- plotKill(res,
        custom_drugs = custom_drugs,
        regimen_colors = regimenColors)
      return(pl)
    })
    output[[paste0("plotEffect", suffix)]] <- renderPlot({
      pl <- plotEffect(res,
        custom_drugs = custom_drugs,
        regimen_colors = regimenColors)
      return(pl)
    })
    output[[paste0("plotBact", suffix)]] <- renderPlot({
      pl <- plotBact(res)
      return(pl)
    })
    output[[paste0("plotBactSplit", suffix)]] <- renderPlot({
      pl <- plotBactSplit(res)
      return(pl)
    })
    output[[paste0("plotBactRes", suffix)]] <- renderPlot({
      pl <- plotBactRes(res,
        custom_drugs = custom_drugs,
        regimen_colors = regimenColors
        )
      return(pl)
    })
    output[[paste0("plotBactResSplit", suffix)]] <- renderPlot({
      pl <- plotBactResSplit(res,
        custom_drugs = custom_drugs,
        regimen_colors = regimenColors)
      return(pl)
    })
    output[[paste0("plotImmuneCytoLung", suffix)]] <- renderPlot({
      pl <- plotImmuneCytoLung(res)
      return(pl)
    })
    output[[paste0("plotImmuneCytoLymph", suffix)]] <- renderPlot({
      pl <- plotImmuneCytoLymph(res)
      return(pl)
    })
    output[[paste0("plotImmuneCytoDendr", suffix)]] <- renderPlot({
      pl <- plotImmuneCytoDendr(res)
      return(pl)
    })
    output[[paste0("plotImmuneTLung", suffix)]] <- renderPlot({
      pl <- plotImmuneTLung(res)
      return(pl)
    })
    output[[paste0("plotImmuneTHelper", suffix)]] <- renderPlot({
      pl <- plotImmuneTHelper(res)
      return(pl)
    })
    output[[paste0("plotImmuneTNaive", suffix)]] <- renderPlot({
      pl <- plotImmuneTNaive(res)
      return(pl)
    })
  } else {
    # create dummy plots
    plots <- c("plotPK", "plotDose", "plotKill",
      "plotEffect", "plotBact", "plotBactSplit",
      "plotBactRes", "plotImmuneCytoLung", "plotImmuneCytoLymph",
      "plotImmuneCytoDendr", "plotImmuneTLung", "plotImmuneTNaive",
      "plotImmuneTHelper")
    for(i in seq(plots)) {
      output[[paste0(plots[i], suffix)]] <- renderPlot({ dummy })
    }
  }

  ## Read therapy
  therapy <- NULL
  if(file.exists(paste0(folder, "/output/config/therapy.txt"))) {
    therapy <- load_regimen(folder = paste0(folder, "/output/config"))
  }
  output[[paste0("simTherapy",suffix)]] <- renderTable(therapy, striped=TRUE)

  ## Summary of settings
  output$bootstrap <- FALSE
  if(file.exists(paste0(folder, "/config/sim.txt"))) {
    tmp_tab <- read_settings_summary(folder, settingsInfo)
    output[[paste0("simSummary",suffix)]] <- renderTable(tmp_tab, striped=TRUE, spacing="s")
    output$config <- tmp_tab
    bs <- output$config[output$config$Setting == "isBootstrap",]$Value
    if(bs == 1) {
      output$bootstrap <- TRUE
    }
  }

  ## Outcome table and plot
  if(type == "population") {
    output$outcome <- renderText({
      outc <- signif((1-res$outc$AcuteTB) * 100,3)
      txt <- paste0("Outcome: ", tail(outc[!is.na(outc)], 1), "%")
      return(txt)
    })
    output$outcome_ci <- NULL
    if(output$bootstrap) {
      outc05 <- signif((1-res$outc$AcuteTBp05) * 100,3)
      outc95 <- signif((1-res$outc$AcuteTBp95) * 100,3)
      output$outcome_ci <- renderText({
        paste0("95% confidence interval: ", tail(outc95[!is.na(outc95)], 1), "–", tail(outc05[!is.na(outc05)], 1), "%")
      })
    }
    output$plotOutcome <- renderPlot({
      pl <- plotOutcome(res)
      return(pl)
    })
  }

  return(output)
}
