################################################################
## Init
################################################################
source("global.R")
source("R/socket_serverside.R") # for some reason this cannot be separated off into TBsimAppLib

## Logging
# library(loggit)
# dir.create("/data/tbsim/log")
# loggit::setLogFile(paste0("/data/tbsim/log/loggit_",
#                           year(now()), "_", month(now()), "_", day(now()),
#                           hour(now()), "_", minute(now()), ".json"))

localServer <<- FALSE
if(Sys.getenv("LOCAL") != "-1") {
  localServer <<- TRUE
  message("Server is running in local mode.")
  #loggit::loggit("INFO", "Server is running in local mode.")
}

# source("db.R")

## Settings info
settingsInfo <<- read.csv(file="settings.csv", header=FALSE)
colnames(settingsInfo) <<- c("setting", "default", "description")

################################################################
## Main server logic
################################################################]

shinyServer(function(input, output, session) {

  session$allowReconnect(TRUE) # reconnect on connection loss.
  setGlobal("local_server", as.numeric(localServer), session)
  init <<- list(
    qstat_table = TRUE,
    queue_table = TRUE
  )
  init$userId="anon_local"
  copy_default_mems_data(init$userId)
  clickButton("singlePatientRefreshResults", session)
  clickButton("populationRefreshResults", session)
  setElementText("a[data-value='singleResultsTab']", paste0("Output (0)"), session)
  setElementText("a[data-value='populationResultsTab']", paste0("Output (0)"), session)
  setElementText("a[data-value='populationQueueTab']", paste0("Queue (0)"), session)
  setElementText("#simSubmitPop", "Start simulation", session)
  clickButton("refreshDrugs", session)
  
  # disableButton("simSaveSingle", session)
  hideElement(".outcome-box", session)
  # disableButton("editSimSettings", session)
  # disableButton("editSimSettingsPop", session)
  # disableAnchor("reportSingle", session)
  # disableAnchor("reportPopulation", session)
  # disableAnchor("downloadDataSingle", session)
  # disableAnchor("downloadDataPopulation", session)
  checkCheckbox("isQuickSim", session)
  setGlobal("docsView", "docsPK", session)

  ##################################################
  ## Google authentication
  ##################################################
  access_token <- callModule(googleAuth, "loginButton")
  user_details <- reactive({
    with_shiny(
      f=get_user_info,
      shiny_access_token = access_token()
    )
  })



  #dat <- get_results_single()
  #setElementText("a[data-value='singleResultsTab']", paste0("Output (", length(dat[,1]), ")"), session)
  #dat <- get_results_population()
  #setElementText("a[data-value='populationResultsTab']", paste0("Output (", length(dat[,1]), ")"), session)
  setElementText("#simSubmitPop", "Submit to queue", session)
  clickButton("refreshDrugs", session)
  copy_default_mems_data(paste(init$userId))
      

  cache <<- update_drug_list(cache = cache, user = init$userId, drugNames)
  cache <<- update_regimen_list(cache = cache, user = init$userId)
  cache <<- update_mems_list(cache = cache, user = init$userId)
  updateSelectInput(session, "drugRegimenSingle", choices = names(cache$regimenList), sel = cache$defaultRegimen)
  updateSelectInput(session, "drugRegimen", choices = names(cache$regimenList), sel = cache$defaultRegimen)
  reload_mems_selector <- function(cache, user) {
    if(!is.null(cache$mems_files) && length(cache$mems_files) > 0) {
      sel <- cache$mems_files[1]
      updateSelectInput(session, "useMemsFile", choices = cache$mems_files, selected = sel)
    }
  }

  reload_mems_selector(cache, user = init$userId)
  #return(ret)
  

  ##################################################
  ## Edit simulation settings
  ##################################################
  observeEvent(input$editSimSettings, {
    # don't have to open model manually, done by trigger
  })
  observeEvent(input$editSimSettingsPop, {
    openModal("editSimSettingsModal", session);
  })

  ##################################################
  ## Drug library
  ##################################################
  observeEvent(input$refreshDrugs, {
    init$userId <- "anon_local"
    output$drugLibList <- DT::renderDataTable({
        cache$drugListData <<- get_drug_list(drugNames, init$userId)
      cache$combinedDrugList <<- cache$drugListData$Drug
      cache$combinedDrugNameList <<- cache$drugListData$Name
      DT::datatable(cache$drugListData, list(pageLength = 20, lengthChange = FALSE, bPaginate = FALSE, searching=FALSE, paging = FALSE),
        selection = "single")
    }, server = FALSE)
    output$drugParamsTitle = renderText(ifelse(is.null(input$drugLibList_rows_selected), "", unlist(cache$combinedDrugList[input$drugLibList_rows_selected])))
    output$drugParamsTable <- renderRHandsontable({
      if(stringr::str_detect(init$userId, "anon_")) {
        # disableButton("newDrug", session)
        enableButton("newDrug", session)
      } else {
        # only allow saving of new drugs when logged in!
        enableButton("newDrug", session)
      }
      hot_drug <- rhandsontable(data.frame(), width = 0)
      if(!is.null(input$drugLibList_rows_selected)) {
        idx <- input$drugLibList_rows_selected
        dat <- cache$drugListData[idx,]
        if(!is.null(dat) && nrow(dat) > 0 && !is.na(dat[1,1]) ) {
          tbl <- get_drug_parameters(
            drug_id = dat$Drug,
            type = dat$Type,
            user = init$userId)
          if(dat$Type == "built-in") {
            disableButton("saveDrugParams", session)
            disableButton("deleteDrug", session)
          } else {
            enableButton("saveDrugParams", session)
            enableButton("deleteDrug", session)
          }
          as.num <- function(x) as.numeric(as.character(x))
          tbl$value <- as.character(tbl$value)
          hot_drug <- rhandsontable(tbl) %>%
            hot_col("parameter", readOnly = TRUE) %>%
            hot_col("description", readOnly = TRUE) %>%
            hot_col("unit", readOnly = TRUE)
        }
      }
      return(hot_drug)
    #   if(is.null(cache$editRegimenTableData)) {
    #     tbl <- load_regimen(
    #       input$drugRegimenSingle,
    #       regimenList,
    #       drugDefinitions = cache$combinedDrugList)
    #   } else {
    #     tbl <- cache$editRegimenTableData
    #   }
    #   cache$editRegimenTable <<- rhandsontable(tbl)
    #   return(cache$editRegimenTable)
    })
  })

  ##################################################
  ## Edit drugs
  ##################################################
  cache$editRegimenTable <- NULL
  observeEvent(input$deleteDrug, {
    if(!is.null(input$drugLibList_rows_selected)) {
      idx <- input$drugLibList_rows_selected
      dat <- cache$drugListData[idx,]
      if(file.exists(paste0("/data/tbsim/", init$userId, "/drugs/", dat$Drug[1], ".txt"))) {
        unlink(paste0("/data/tbsim/", init$userId, "/drugs/", dat$Drug[1], ".txt"))
      }
      drugsFile <- paste0("/data/tbsim/", init$userId, "/drugs/drugs.csv")
      if(file.exists(drugsFile)) {
        tmp <- read.csv(file = drugsFile)
        if("abbr" %in% names(tmp) && sum(tmp$abbr == dat$Drug[1]) > 0) {
          tmp <- tmp[tmp$abbr != dat$Drug[1],]
        }
        write.csv(tmp, file = drugsFile, quote=F)
      }
      clickButton("refreshDrugs", session)
    }
  })
  observeEvent(input$saveDrugParams, {
    tmp <- hot_to_r(input$drugParamsTable)
    name <- stringr::str_replace_all(tmp[tmp$parameter == "name",2], " ", "")
    file1 <- paste0("/data/tbsim/", init$userId, "/drugs/", name, ".txt")
    data <- paste0("<", as.character(tmp[,1]), ">", as.character(tmp[,2]))
    write.csv(data, file1, quote=F, row.names=F)
    clickButton("refreshDrugs", session)
    popup(paste0("Drug parameters for ", name, " saved"), session)
  })
  observeEvent(input$saveNewDrug, {
    drugAbbr <- stringr::str_replace_all(input$newDrugAbbr, " ", "")
    drugName <- input$newDrugName
    duplFrom <- input$selectNewDrugTemplate
    if(drugAbbr %in% cache$combinedDrugList) {
      popup("Sorry, this drug is already present, please choose a different abbreviated name.", session)
    } else {
      isOk <- new_drug_from_template(drugAbbr, drugName, init$userId, duplFrom)
      closeModal("newDrugModal", session)
      if(isOk) {
        clickButton("refreshDrugs", session)
        # popup("New drug saved.", session)
      } else {
        popup("Sorry, something went wrong saving the new drug.", session)
      }
    }
  });
  observeEvent(input$editDrugsPopulation, { # populations
    clickButton("editDrugsSingle", session)
  })
  observeEvent(input$editAdherencePopulation, {
    clickButton("editAdherenceSingle", session)
  })

  ###############################################################
  ## Edit regimens
  ###############################################################
  render_edit_regimen_table <- function(user, type = "single") {
    renderRHandsontable({
      var <- ifelse(type == "single", input$drugRegimenSingle, input$drugRegimen)
      tbl <- load_regimen(
        regimen = cache$regimenList[[var]],
        drugDefinitions = cache$drugDefinitions)
      tbl$Include <- rep(TRUE, nrow(tbl))
      cache$editRegimenTable <- rhandsontable(tbl)
      return(cache$editRegimenTable)
    })
  }
  reload_regimen_selector <- function(user, input) {
    sel <- input$editRegimenNewDescription
    if(! sel %in% names(cache$regimenList)) {
      sel <- names(cache$regimenList)[1]
    }
    updateSelectInput(session, "drugRegimenSingle", choices = names(cache$regimenList), selected = sel)
    updateSelectInput(session, "drugRegimen", choices = names(cache$regimenList), selected = sel)
  }

  observeEvent(input$editDrugRegimensSingle, {
    updateTextInput(session, "editRegimenNewDescription", value = input$drugRegimenSingle)
    cache <<- update_drug_list(cache = cache, user = init$userId, drugNames)
    output$editRegimenTable <- render_edit_regimen_table(init$userId, "single")
    openModal("editDrugRegimenModal", session)
  })
  observeEvent(input$editDrugRegimensPopulation, {
    updateTextInput(session, "editRegimenNewDescription", value = input$drugRegimen)
    cache <<- update_drug_list(cache = cache, user = init$userId, drugNames)
    output$editRegimenTable <- render_edit_regimen_table(init$userId, "population")
    openModal("editDrugRegimenModal", session)
  })
  observeEvent(input$duplicateDrugRegimensSingle, {
    updateTextInput(session, "editRegimenNewDescription", value = "New regimen")
    cache <<- update_drug_list(cache = cache, user = init$userId, drugNames)
    output$editRegimenTable <- render_edit_regimen_table(init$userId, "single")
    openModal("editDrugRegimenModal", session)
  })
  observeEvent(input$duplicateDrugRegimensPopulation, {
    updateTextInput(session, "editRegimenNewDescription", value = "New regimen")
    cache <<- update_drug_list(cache = cache, user = init$userId, drugNames)
    output$editRegimenTable <- render_edit_regimen_table(init$userId, "population")
    openModal("editDrugRegimenModal", session)
  })
  observeEvent(input$deleteDrugRegimensSingle, {
    delete_drug_regimen(user = init$userId, regimenId = cache$regimenList[[input$drugRegimenSingle]]$id)
    cache <<- update_regimen_list(cache, user = init$userId)
    reload_regimen_selector(user = init$userId, input)
  })
  observeEvent(input$deleteDrugRegimensPopulation, {
    delete_drug_regimen(user = init$userId, regimenId = cache$regimenList[[input$drugRegimen]]$id)
    cache <<- update_regimen_list(cache, user = init$userId)
    reload_regimen_selector(user = init$userId, input)
  })

  observeEvent(input$editRegimenCancel, {
    closeModal("editDrugRegimenModal", session)
  })
  observeEvent(input$editRegimenReset, {
    closeModal("editDrugRegimenModal", session)
    cache$editRegimenTable <- NULL
    cache$resetRegimen <- TRUE
    cache <<- cache
    Sys.sleep(.5)
    clickButton("editDrugsSingle", session)
  })
  observeEvent(input$editRegimenSaveAsNew, {
    if(!is.null(input$editRegimenTable)) {
      tmp <- hot_to_r(input$editRegimenTable)
      cache$editRegimenTableData <- as.data.frame(tmp)
      save_new_regimen(tmp, description = input$editRegimenNewDescription, user = init$userId)
      closeModal("editDrugRegimenModal", session)
    }
    cache <<- update_regimen_list(cache, user = init$userId)
    reload_regimen_selector(user = init$userId, input)
  })
  observeEvent(input$drugRegimenSingle, {
    if(input$drugRegimenSingle %in% names(regimenList)) {
      disableButton("editDrugRegimensSingle", session)
      disableButton("deleteDrugRegimensSingle", session)
    } else {
      enableButton("editDrugRegimensSingle", session)
      enableButton("deleteDrugRegimensSingle", session)
    }
  })
  observeEvent(input$drugRegimen, {
    if(input$drugRegimen %in% names(regimenList)) {
      disableButton("editDrugRegimensPopulation", session)
      disableButton("deleteDrugRegimensPopulation", session)
    } else {
      enableButton("editDrugRegimensPopulation", session)
      enableButton("deleteDrugRegimensPopulation", session)
    }
  })


  observeEvent(input$isQuickSim, {
    if(!is.null(input$isQuickSim)) {
      if(input$isQuickSim) {
        setElementText("#simSubmitPop", "Start simulation", session)
        # shinyjs::disable("nPatients")
        if(!input$isBootstrap) {
          shinyjs::disable("nIterations")
        }
      } else {
        setElementText("#simSubmitPop", "Submit to queue", session)
        # shinyjs::enable("nPatients")
        if(input$isBootstrap) {
          shinyjs::enable("nIterations")
        }
      }
    }
  })
  observeEvent(input$isBootstrap, {
    if(!is.null(input$isBootstrap)) {
      if(input$isBootstrap) {
        # shinyjs::disable("isQuickSim")
        shinyjs::enable("nIterations")
      } else {
        # shinyjs::enable("isQuickSim")
        if(input$isQuickSim) {
          shinyjs::disable("nIterations")
        }
      }
    }
  })

  ##################################################
  ## Results manager (single)
  ##################################################
  observeEvent(input$singlePatientRefreshResults, {
    output$singlePatientResultsTable <- DT::renderDataTable({
      dat <- get_results_single()
      if(length(dat[,1]) == 0) {
        disableButton("singlePatientLoadResults", session)
      } else {
        enableButton("singlePatientLoadResults", session)
      }
      cache$singleResults <<- dat
      setElementText("a[data-value='singleResultsTab']", paste0("Output (", length(dat[,1]), ")"), session)
      # hideElement("#reportSingle", session)
      DT::datatable(dat, list(pageLength = 10, lengthChange = FALSE, searching=FALSE), selection="single")
    })
  })

  ##################################################
  ## Results manager (populations)
  ##################################################
  get_results_population <- function() {
    init$userId="anon_local"
    res <- get_sim_results_list(user = paste(init$userId), type="population")
    dat <- pluck(res, 'datetime')
    if(length(dat)>0) {
      tab <- data.frame(cbind(
        Run = pluck(res, 'id'),
        Description = pluck(res, 'description'),
        Status = pluck(res, 'status'),
        Outcome = pluck(res, 'outcome'),
        Patients = pluck(res, 'n_patients')))
      tab$ago <- NA
      tab$ago[!is.na(dat)] <- time_to_ago(dat[!is.na(dat)], sort=FALSE, to_character = FALSE)
      tab$Finished <- NA
      tab$Finished[!is.na(dat)] <- time_to_ago(dat[!is.na(dat)], sort=FALSE, to_character = TRUE)
      tab <- tab[order(tab$ago),]
      tab <- tab[tab$Status=="finished",]#tab %>% filter(Status == "finished")
      tab$Outcome <- paste0(as.character(round(as.num(tab$Outcome) * 100,1)), " %")
      cache$summary <<- list()
      #tab[,c("Run", "Description", "Finished", "Outcome")]
      return(tab[,c("Run","Description","Finished","Outcome")])
    } else{
      return(data.frame())
    }
  }
  observeEvent(input$populationRefreshResults, {
    output$queueResultsTable <- DT::renderDataTable({
      dat <- get_results_population()
      if(length(dat[,1]) == 0) {
        disableButton("loadResults", session)
      } else {
        enableButton("loadResults", session)
      }
      cache$queueResults <<- dat
      # hideElement("#reportPopulation", session)
      setElementText("a[data-value='populationResultsTab']", paste0("Output (", length(dat[,1]), ")"), session)
      DT::datatable(dat, list(pageLength = 20, lengthChange = FALSE, searching=FALSE), selection="single")
    })
  })
  observeEvent(input$compareResults, {
    s <- input$queueResultsTable_rows_selected
    if(is.null(s) || length(s) < 2) {
      popup("Please select two or more runs to load", session)
    } else {
      activateTab("popCompare", session)
      ## ...
    }
  })

  ## Load results
  dummy_outcome <- data.frame(cbind("dummy" = "No simulation loaded."))
  output$outcomeTable <- renderTable(
    dummy_outcome, colnames = FALSE, bordered = FALSE)
  observeEvent(input$loadResults, {
    init$userId="anon_local"
    s <- input$queueResultsTable_rows_selected
    if(is.null(s)) {
      popup("Please select a run to load.", session)
    } else {
      if(length(s) > 1) {
        popup("Please select only a single run to show.", session)
      } else {
        setGlobal('population_bootstrap', 0, session)
        setGlobal('population_plots_available', 2, session) ## activate spinner
        tmp <- cache$queueResults
        if(!is.null(s) && !is.null(tmp)) {
          id <- as.character(tmp[s,]$Run)
          activateTab("popOutcomeTab", session)
          showElement(".outcome-box", session)
          progress <- shiny::Progress$new()
          on.exit(progress$close())
          progress$set(message = "Processing: ", value = 0.5, detail = "Loading results")
          cache <<- update_drug_list(cache = cache, user = init$userId, drugNames)
          tmp <- load_saved_results(
            id = id, user = init$userId, session,
            drug_definitions = cache$drugDefinitions,
            custom_drugs = cache$combinedDrugList,
            type = "population")
          cache$populationResults <<- tmp$res
          progress$set(1)
          for(key in names(tmp)) {
            if(!key %in% c("config", "res", "bootstrap")) {
              output[[key]] <- tmp[[key]]
            }
          }
          setGlobal('population_plots_available', 1, session)
          if(!is.null(tmp$config)) {
            if(tmp$bootstrap) {
              setGlobal('population_bootstrap', 1, session)
            }
          }
          if(!is.null(tmp$res$conc)) {
            setGlobal('population_quick_sim', 0, session)
            showTab("popPharmacokineticsTab", session)
            showTab("popBacterialLoadTab", session)
            showTab("popResistanceTab", session)
            showTab("popEffectTab", session)
            showTab("popImmuneTab", session)
          } else {
            setGlobal('population_quick_sim', 1, session)
            hideTab("popPharmacokineticsTab", session)
            hideTab("popBacterialLoadTab", session)
            hideTab("popResistanceTab", session)
            hideTab("popEffectTab", session)
            hideTab("popImmuneTab", session)
          }
        } else {
          setGlobal('population_plots_available', 0, session)
        }
      }
    }
  })

  ##################################################
  ## Download report
  ##################################################
  output$reportSingle <- downloadHandler(
    filename = function() {
      paste0("results_single_", cache$single_selected_id, ".pdf")
    },
    content = function(file) {
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy(paste0(base_dir,"/report.Rmd"), tempReport, overwrite = TRUE)
      id <- cache$single_selected_id
      if(!is.null(id)) {
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(value = 0.3, message = "Processing: ", detail = "Creating plots...");
        tmp_results <- gather_plots(
          id = id, user = init$userId, session = session,
          drug_definitions = cache$drugDefinitions,
          custom_drugs = cache$combinedDrugList,
          type = "single"
        )
        progress$set(value = 0.8, message = "Processing: ", detail = "Rendering PDF...");
        rmarkdown::render(tempReport, output_file = file,
          params = list(output = tmp_results),
          envir = new.env(parent = globalenv())
        )
        progress$set(value = 1, message = "Done", detail = "");
      }
    }
  )
  output$reportPopulation <- downloadHandler(
    filename = function() {
      paste0("results_pop_", cache$population_selected_id, ".pdf")
    },
    content = function(file) {
      tempReport <- file.path(tempdir(), "report.Rmd")
      file.copy(paste0(base_dir,"/report.Rmd"), tempReport, overwrite = TRUE)
      id <- cache$population_selected_id
      if(!is.null(id)) {
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(value = 0.3, message = "Processing: ", detail = "Creating plots...");
        tmp_results <- gather_plots(
          id = id, user = init$userId, session = session,
          drug_definitions = cache$drugDefinitions,
          custom_drugs = cache$combinedDrugList,
          type = "population"
        )
        progress$set(value = 0.8, message = "Processing: ", detail = "Rendering PDF...");
        rmarkdown::render(tempReport, output_file = file,
          params = list(output = tmp_results),
          envir = new.env(parent = globalenv())
        )
        progress$set(value = 1, message = "Done", detail = "");
      }
    }
  )

  observeEvent(input$single_selected_id,{
    cache$single_selected_id <<- input$single_selected_id
  })
  observeEvent(input$population_selected_id, {
    cache$population_selected_id <<- input$population_selected_id
  })

  ##################################################
  ## Upload MEMS
  ##################################################
  observeEvent(input$memsFile, {
    mems_folder <- paste0("/data/tbsim/", init$userId, "/mems")
    dir.create(mems_folder, recursive=TRUE)
    name <- input$memsFile$name
    setGlobal('mems_file_parsing', 1, session)
    mems <- TBsimApp::convert_mems_data(filename = input$memsFile$datapath)
    setGlobal('mems_file_parsing', 0, session)
    if(is.null(mems)) {
      popup("Sorry, couldn't parse this datafile. Please see documentation for appropriate MEMS file layout.", session)
    } else {
      filename <- paste0("/data/tbsim/", init$userId, "/mems/", stringr::str_replace(input$memsFile$name, ".csv", ""), ".rds")
      saveRDS(mems, filename)
      popup(paste0("MEMS file parsed. Found dosing data for ", length(mems), " subjects."), session)
      cache <<- update_mems_list(cache = cache, user = init$userId)
      reload_mems_selector(cache, user = init$userId)
      # set selected MEMS to new upload
    }
  })

  ##################################################
  ## Download results
  ##################################################
  output$downloadDataSingle <- downloadHandler(
    filename = function() {
      paste0("data_single_", cache$single_selected_id, ".zip")
    },
    contentType = "application/zip",
    content = function(file) {
      folder <- paste0("/data/tbsim/", init$userId, "/", cache$single_selected_id)
      system(paste("cd", folder, "; /usr/bin/zip -r ", file, "*"))
    }
  )
  output$downloadDataPopulation <- downloadHandler(
    filename = function() {
      paste0("data_pop_", cache$population_selected_id, ".zip")
    },
    contentType = "application/zip",
    content = function(file) {
      folder <- paste0("/data/tbsim/", init$userId, "/", cache$population_selected_id)
      system(paste("cd", folder, "; /usr/bin/zip -r ", file, "*"))
    }
  )

  ##################################################
  ## Delete results
  ##################################################
  observeEvent(input$deleteResults, {
    s <- input$queueResultsTable_rows_selected
    if(!is.null(s)) {
      tmp <- get_results_population()
      id <- as.character(tmp[s,]$Run)
      folder <- paste0("/data/tbsim/", init$userId, "/", id)
      unlink(folder, recursive = TRUE, force = TRUE)
      clickButton("populationRefreshResults", session)
    }
  })
  observeEvent(input$singlePatientDeleteResults, {
    s <- input$singlePatientResultsTable_rows_selected
    if(!is.null(s)) {
      tmp <- get_results_single()
      id <- as.character(tmp[s,]$Run)
      folder <- paste0("/data/tbsim/", init$userId, "/", id)
      unlink(folder, recursive = TRUE, force = TRUE)
      clickButton("singlePatientRefreshResults", session)
    }
  })

  ##################################################
  ## SGE manager
  ##################################################
  observeEvent(input$killJob, {
    s <- input$qstatTable_rows_selected
    if(!is.null(s)) {
      tmp <- cache$qstat_runs
      id <- as.num(tmp[s,]$Job)
      Rge::qdel(id = id, force = TRUE)
      session$sendCustomMessage(
         type = "refreshJobs",
         message = list(2000)
      )
    }
  })

  observeEvent(input$refreshJobQueue, {
    dat <- get_jobs()
    setElementText("a[data-value='populationQueueTab']", paste0("Queue (", length(dat[,1]),")"), session)
    output$qstatTable <- DT::renderDataTable({
      DT::datatable(dat, list(pageLength = 20, lengthChange = FALSE, searching=FALSE), selection="single")
    })
  })

  ##################################################
  ## Submit new simulation population
  ##################################################
  observeEvent(input$simSubmitPop, {
    init$userId="anon_local"
    if(is.null(input$jobDescription) || stringr::str_replace_all(input$jobDescription, " ", "") == "") {
      popup(paste0('Please enter a description for this simulation.'), session)
    } else {
      if(input$isQuickSim) {
        setGlobal('population_plots_available', 2, session)
        disableButton("simRefreshPop", session)
        disableButton("simResetPop", session)
        progress <- shiny::Progress$new()
        on.exit(progress$close())
        progress$set(message = "Processing: ", value = 0.5, detail = "Simulating...")
        res <- sim_wrapper_single(
          user = init$userId,
          input = input,
          userData = access_token(),
          nPatients = min(c(200, input$nPatients)), # hard-coded max
          output = output,
          description = input$jobDescription,
          progress = progress,
          regimen = cache$regimenList[[input$drugRegimen]],
          drugNames = cache$combinedDrugList,
          memsFile = input$useMemsFile
         )
         progress$set(value = 1)
         cache$populationResults <<- res
         tmp <- load_saved_results(
           id = res$id, user = init$userId, session,
           type = "population", quick_sim = TRUE,
           drug_definitions = cache$drugDefinitions,
           custom_drugs = cache$combinedDrugList)
         if(is.null(tmp)) {
           setGlobal('single_plots_available', 0, session)
           popup('Sorry, something went wrong with this simulation.', session)
         } else {
           hideTab("popPharmacokineticsTab", session)
           hideTab("popBacterialLoadTab", session)
           hideTab("popResistanceTab", session)
           hideTab("popEffectTab", session)
           hideTab("popImmuneTab", session)
           for(key in names(tmp)) {
             if(!key %in% c("config", "res", "bootstrap")) {
               output[[key]] <- tmp[[key]]
             }
           }
           dat <- get_results_population()
           setElementText("a[data-value='populationResultsTab']", paste0("Output (", length(dat[,1]), ")"), session)
           clickButton("populationRefreshResults", session)
         }
         progress$set(1)
         enableButton("simRefreshPop", session)
         enableButton("simResetPop", session)
         setGlobal('population_plots_available', 1, session)
         if(!is.null(tmp$res$conc)) {
           setGlobal('population_quick_sim', 0, session)
         } else {
           setGlobal('population_quick_sim', 1, session)
         }
      } else {
        if(stringr::str_detect(init$userId, "anon_") && !localServer) {
          popup(paste0('Please log in to submit jobs to job queue.'), session)
        } else {
          if(localServer) {
	    warning(paste(input$useMemsFile))
            if(!is.null(input$useMemsFile)) {
               memsFile <- paste0("/data/tbsim/", init$userId, "/mems/", input$useMemsFile, ".rds")
              if(!file.exists(memsFile)) {
                memsFile <- NULL
                message("No MEMS file selected.")
              }
	    }
	    res <- do_sim(input = input,
                         user = init$userId,
                         userData = list(),
                         userDetails = NULL,
                         nPatients = input$nPatients,
                         description = input$jobDescription,
                         jobscheduler = TRUE,
                         memsFile = memsFile, #paste0("/data/tbsim/", init$userId, "/mems/", input$useMemsFile, ".rds"),
                         regimen = cache$regimenList[[input$drugRegimen]],
                         drugNames = cache$combinedDrugList)
          } else {
            res <- do_sim(input = input,
                         userData = access_token(),
                         userDetails = user_details(),
                         nPatients = input$nPatients,
                         description = input$jobDescription,
                         jobscheduler = TRUE,
                         memsFile = input$useMemsFile, #paste0("/data/tbsim/", init$userId, "/mems/", input$useMemsFile, ".rds"),
                         regimen = cache$regimenList[[input$drugRegimen]],
                         drugNames = cache$combinedDrugList)
          }

          ## update queue
          popup(paste0('Job placed in queue.'), session)
          Sys.sleep(1)
          dat <- get_jobs()
          setElementText("a[data-value='populationQueueTab']", paste0("Queue (", length(dat[,1]),")"), session)
          output$qstatTable <- DT::renderDataTable({
            DT::datatable(dat, list(pageLength = 20,lengthChange = FALSE, searching=FALSE), selection="single")
          })
        }
      }
    }

  })

  ##################################################
  ## Regimen editor single
  ##################################################
  drugs <- names(drugDefinitions)
  output$drugSelection <- renderUI({
    tagList(
      lapply(1:length(drugs), function(i) {
        box(
          title = drugs[i],
          status = "primary",
          width = 12,
          div(class='margin0',
              checkboxInput(paste0(drugs[i],"Included"), "Included")
          ),
          conditionalPanel(
            condition = paste0("input.",drugs[i],"Included == true"),
            column(width = 3,
                   sliderInput(paste0(drugs[i], "Dose"), "Dose (mg)",
                               min = 10,
                               max = 100,
                               value = 50,
                               step = 10)
            ),
            column(width = 3,
                   selectInput(paste0(drugs[i],"Intv"), "Interval (hours)", c(6, 12, 24), selected = 12)
            ),
            column(width = 3,
                   sliderInput(paste0(drugs[i],"Dur"), "Duration (days)",
                               min = 1,
                               max = 200,
                               value = 100,
                               step = 1)
            ),
            column(width = 3,
                   sliderInput(paste0(drugs[i],"Start"), "Start day",
                               min = 0,
                               max = 200,
                               value = 0,
                               step = 1)
            )
          )
        )
      })
    )
  })

  dummy_outcome <- data.frame(cbind("dummy" = "No simulation loaded."))
  output$outcomeTable <- renderTable(
    dummy_outcome,
    colnames = FALSE, bordered = FALSE)

  ##################################################
  ## Simulate single
  ##################################################
  observeEvent(input$simRefreshSingle, {
    init$userId="anon_local"
    if(is.null(input$singleRunDescription) || stringr::str_replace_all(input$singleRunDescription, " ", "") == "") {
      popup(paste0('Please enter a description for this simulation.'), session)
    } else {
      setGlobal('single_plots_available', 2, session)
      disableButton("simRefreshSingle", session)
      disableButton("simResetSingle", session)
      progress <- shiny::Progress$new()
      on.exit(progress$close())
      progress$set(message = "Processing: ", value = 0.5, detail = "Simulating...")
      init$userId="anon_local"
      res <- sim_wrapper_single(
        user = init$userId,
        input = input,
        userData = access_token(),
        nPatients = 1,
        output = output,
        description = input$singleRunDescription,
        progress = progress,
        regimen = cache$regimenList[[input$drugRegimenSingle]],
        drugNames = cache$combinedDrugList,
        memsFile = input$useMemsFile)
      progress$set(value = 1);
      tmp <- load_saved_results(
        id = res$id,
        user = init$userId, session,
        type = "single", quick_sim = FALSE,
        drug_definitions = cache$drugDefinitions,
        custom_drugs = cache$combinedDrugList)
      if(is.null(tmp)) {
        setGlobal('single_plots_available', 0, session)
        popup('Sorry, something went wrong with this simulation.', session)
      } else {
        cache$singleResults <<- tmp$res
        progress$set(1)
        for(key in names(tmp)) {
          if(!key %in% c("config", "res", "bootstrap")) {
            output[[key]] <- tmp[[key]]
          }
        }
        dat <- get_results_single()
	print(dat)
        setElementText("a[data-value='singleResultsTab']", paste0("Output (", length(dat[,1]), ")"), session)
        clickButton("singlePatientRefreshResults", session)
        setGlobal('single_plots_available', 1, session)
        enableButton("simRefreshSingle", session)
        enableButton("simResetSingle", session)
      }
      enableButton("simRefreshSingle", session)
      enableButton("simResetSingle", session)
    }
  })

  observeEvent(input$pkTimeSliderPop, {
    if(!is.null(cache$populationResults) && !is.null(cache$populationResults$conc)) {
      output$plotPKPop <- renderPlot({
        pl  <- plotPK(cache$populationResults,
          time_filter = ((input$pkTimeSliderPop-1) * 7) + c(0,7),
          custom_drugs = cache$combinedDrugList,
          regimen_colors = get_standard_colors(cache$combinedDrugList)
        )
        return(pl)
      })
    }
  })

  observeEvent(input$pkTimeSliderSingle, {
    if(!is.null(cache$singleResults) && !is.null(cache$singleResults$conc)) {
      output$plotPK <- renderPlot({
        pl  <- plotPK(cache$singleResults,
          time_filter = ((input$pkTimeSliderSingle-1) * 7) + c(0,7),
          custom_drugs = cache$combinedDrugList,
          regimen_colors = get_standard_colors(cache$combinedDrugList)
        )
        return(pl)
      })
    }
  })

  observeEvent(input$singlePatientLoadResults, {
    s <- input$singlePatientResultsTable_rows_selected
    if(is.null(s)) {
      popup("Please select a run to load.", session)
    } else {
      if(length(s) > 1) {
        popup("Please select only a single run to show.", session)
      } else {
        tmp <- get_results_single()
        if(!is.null(s) && !is.null(tmp)) {
          setGlobal('single_plots_available', 2, session)
          id <- as.character(tmp[s,]$Run)
          activateTab("singlePharmacokineticsTab", session)
          showElement(".outcome-box", session)
          progress <- shiny::Progress$new()
          on.exit(progress$close())
          progress$set(message = "Processing: ", value = 0.5, detail = "Loading results")
          tmp <- load_saved_results(id = id, user = "anon_local", session,
            type = "single",
            drug_definitions = cache$drugDefinitions,
            custom_drugs = cache$combinedDrugList)
          cache$singleResults <<- tmp$res
          progress$set(1)
          for(key in names(tmp)) {
            if(!key %in% c("config", "res", "bootstrap")) {
              output[[key]] <- tmp[[key]]
            }
          }
          setGlobal('single_plots_available', 1, session)
        }
      }
    }
  })

  observeEvent(input$simResetPop, {
    setGlobal('population_plots_available', 0, session)
  })

  observeEvent(input$simResetSingle, {
    setGlobal('single_plots_available', 0, session)
  })

  ################################################
  ## Documentation
  ################################################

  observeEvent(input$docsPK, {
    setGlobal('docsView', 'docsPK', session)
  })
  observeEvent(input$docsBact, {
    setGlobal('docsView', 'docsBact', session)
  })
  observeEvent(input$docsImmune, {
    setGlobal('docsView', 'docsImmune', session)
  })
  observeEvent(input$docsFull, {
    setGlobal('docsView', 'docsFull', session)
  })

})
