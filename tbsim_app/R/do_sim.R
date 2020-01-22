
#' Run simulation wrapper
#' @export
do_sim <- function(
  user = NULL,
  input = list(),
  userData = NULL,
  userDetails = NULL,
  jobscheduler = FALSE,
  description = "No description",
  nPatients = 1,
  regimen = NULL,
  memsFile = NULL,
  drugNames = c()) {

  if(!is.null(userData)) {
    cat("Saving results to database!!")
  }

  ## read in templates and define some constants
  therapy <- regimen
  adherence <- tb_read_init("adh2.txt")
  immune <- tb_read_init("Immune.txt")
  if(!is.null(input$id)) {
    message("Created random string!")
    id <- TBsim::random_string()
  } else {
    if(!is.null(input$id)) {
      id <- input$id
    } else {
      id <- TBsim::random_string()
      warning("No run ID specified, created random id.")
    }
  }
  if(!is.null(userDetails)) {
    user <- userDetails$emails$value[1]
    folder <- TBsim::new_tempdir(user = user, id = id)
  } else {
    if(is.null(user)) {
      stop("No userID specified!")
    }
    folder <- TBsim::new_tempdir(user = user, id = id)
  }
  suffix <- "Single"
  if(nPatients > 1) {
    suffix <- "Pop"
  }
  output_data <- ifelse(nPatients > 1 && input$isQuickSim, 0, 1)
  is_bootstrap <- ifelse(input$isBootstrap, 1, 0)
  settings <- list(
    isBootstrap = is_bootstrap, # not sure what this is...
    isImmuneKill = ifelse(input[[paste0("isImmuneKill",suffix)]] == "Yes", 1, 0),
    isDrugEffect = 1,
    isResistance = ifelse(input[[paste0("isResistance",suffix)]] == "Yes", 1, 0),
    isClearResist = input$isClearResist * 1, # checkbox
    isGradualDiffusion = input$isGradualDiffusion * 1,
    isAdherence = 1,
    isGranuloma = input$isGranuloma * 1,
    isGranImmuneKill = input$isGranImmuneKill * 1,
    isGranulomaInfec = input$isGranulomaInfec * 1,
    isSaveAdhDose = output_data,
    isSaveConc =  output_data,
    isSaveConcKill =  output_data,
    isSaveImmune =  output_data,
    isSaveMacro =  output_data,
    isSaveBact = output_data,
    isSaveBactRes = output_data,
    isSaveEffect = output_data,
    isSavePatientResults = 0
  )
  text_inputs <- c( # or sliders
    "bactThreshold", "bactThresholdRes", "growthLimit", "resistanceRatio",
    "resistanceFitness", "isPersistance", "persistTime",
    "freeBactLevel", "latentBactLevel", "infI", "infII", "infIII", "infIV",
    "immuneMean", "initialValueStdv", "parameterStdv", "timeStepStdv", "immuneStdv",
    "adherenceSwitchDay", "nTime",
    "adherenceMean", "therapyStart", "nPopulations")
  for(i in seq(text_inputs)) {
    settings[[text_inputs[i]]] <- input[[text_inputs[i]]]
  }
  settings$adherenceType1 <- 9
  settings$adherenceType2 <- 9
  settings$adherenceMEMS <- 0
  if(input$adherenceType == "Random draw") {
    settings$adherenceType1 <- 0
    settings$adherenceType2 <- 0
  }
  if(input$adherenceType == "Switched") {
    if(input$adherenceType1 == "Random draw") {
      settings$adherenceType1 <- 0
    }
    if(input$adherenceType2 == "Random draw") {
      settings$adherenceType2 <- 0
    }
  }
  if(input$adherenceType == "MEMS") {
    settings$adherenceType1 <- 0
    settings$adherenceType2 <- 0
    settings$adherenceMEMS <- 1
  }
  Stdv <- list(
    initialValueStdv = settings$initialValueStdv,
    parameterStdv = settings$parameterStdv,
    timeStepStdv = 0.05,
    immuneStdv = settings$immuneStdv
  )
  drugVariability <- 1
  seed <- input$simSeed
  if(nPatients == 1) seed <- NULL
  if(nPatients == 1 && input$patientTypeSingle == "Typical") {
    for(key in names(Stdv)) { Stdv[[key]] <- 0 }
    drugVariability <- 0
  }

  ## get drug definitions
  drugDefinitions <- reload_all_drug_definitions(drugNames, user)

  immune <- tb_read_init("Immune.txt")
  #print(immune)
  sim1 <- TBsim::tb_new_sim(
     folder = folder,
     id = id,
     user = user,
     description = description,
     therapy = therapy,
     adherence = adherence,
     immune=immune,
     drugs = drugDefinitions,
     memsFile = memsFile,
     nPatients = nPatients,
     therapyStart = as.numeric(as.character(settings$therapyStart)),
     drugVariability = drugVariability,
     nTime = settings$nTime, # TBsim::max_time_from_therapy(therapy) + as.num(settings$therapyStart),
     isBootstrap = settings$isBootstrap, # not sure what this is...
     isImmuneKill = settings$isImmuneKill,
     isDrugEffect = settings$isDrugEffect,
     isResistance = settings$isResistance,
     isPersistance = settings$isPersistance,
     persistTime = settings$persistTime,
     bactThreshold = settings$bactThreshold,
     bactThresholdRes = settings$bactThresholdRes,
     growthLimit = settings$growthLimit,
     isClearResist = settings$isClearResist,
     resistanceRatio = settings$resistanceRatio,
     resistanceFitness = settings$resistanceFitness,
     freeBactLevel = settings$freeBactLevel,
     latentBactLevel = settings$latentBactLevel,
     infI = settings$infI,
     infII = settings$infII,
     infIII = settings$infIII,
     infIV = settings$infIV,
     immuneMean = settings$immuneMean,
     isGradualDiffusion = settings$isGradualDiffusion,
     isGranuloma = settings$isGranuloma,
     isGranImmuneKill = settings$isGranImmuneKill,
     isGranulomaInfec = settings$isGranulomaInfec,
     initialValueStdv = Stdv$initialValueStdv,
     parameterStdv = Stdv$parameterStdv,
    #  timeStepStdv = settings$timeStepStdv,
     immuneStdv = Stdv$immuneStdv,
     isAdherence = settings$isAdherence,
     adherenceType1 = settings$adherenceType1,
     adherenceType2 = settings$adherenceType2,
     adherenceSwitchDay = as.numeric(settings$adherenceSwitchDay) + as.numeric(as.character(settings$therapyStart)),
     adherenceMean = settings$adherenceMean,
     adherenceStdv = input$adherenceStdv,
     adherenceStdvDay = input$adherenceStdvDay,
     adherenceMEMS = settings$adherenceMEMS,
     nPopulations = settings$nPopulations,
     nIterations = input$nIterations,
     isSaveAdhDose = settings$isSaveAdhDose,
     isSaveConc = settings$isSaveConc,
     isSaveConcKill = settings$isSaveConcKill,
     isSaveImmune = settings$isSaveImmune,
     isSaveMacro = settings$isSaveMacro,
     isSaveBact = settings$isSaveBact,
     isSaveBactRes = settings$isSaveBactRes,
     isSaveEffect = settings$isSaveEffect,
     isSavePopulationResults = 1,
     isSavePatientResults = settings$isSavePatientResults,
     adherenceType1 = 9,
     adherenceType2 = 9,
     seed = seed)

  ## Start the simulation based on the given definitions
  res <- TBsim::tb_run_sim (sim1, jobscheduler = jobscheduler,queue="all.q")
  res$id <- id

  return(res)
}
