#' Read settings and make summary
#' @export
read_settings_summary <- function(folder, settingsInfo) {
  tmp <- TBsim::tb_read_init("sim.txt", folder = paste0(folder, "/config"))
  tmp$drugFile <- NULL
  tmp$dataFolder <- NULL
  tmp_tab <- data.frame(cbind(names(tmp), unlist(tmp, use.names=F)))
  names(tmp_tab) <- c("Setting", "Value")
  tmp_tab$Description <- unlist(lapply(as.character(tmp_tab$Setting), function(x) {
    tmp <- as.character(settingsInfo[as.character(settingsInfo$setting) == x,]$description)
    ifelse(!is.null(tmp), tmp, "")
  } ))
  filt_out <- c(
    "therapyFile", "adherenceFile", "user", "drugVariability", "folder",
    "batchMode", "nThreads", "disease", "kMax", "defaultTherapy",
    "isSolution", "isOutcome", "isSavePatientResults",
    "isSavePopulationResults", "isSaveAdhDose", "isSaveConc", "isSaveConcKill",
    "isSaveImmune", "isSaveMacro", "isSaveBact", "isSaveBactRes",
    "isSaveOutcome", "isSaveEffect", "isAdherence", "isDrugDose",
    "isConcentration", "isDrugEffect"
    )
  tmp_tab <- tmp_tab[!(tmp_tab$Setting %in% filt_out),]
  return(tmp_tab)
}
