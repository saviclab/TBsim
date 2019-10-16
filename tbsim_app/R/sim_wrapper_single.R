#' Wrapper for single subject simulation
#' @export
sim_wrapper_single <- function(
  user = NULL,
  input = input,
  userData = NULL,
  nPatients = 1,
  output,
  description = "No description",
  progress = NULL,
  regimen = NULL,
  drugNames = c(),
  memsFile = NULL) {

  if(is.null(user)) {
    stop("No user specified, can't continue!")
  }
  if(!is.null(memsFile)) {
    memsFile <- paste0("/data/tbsim/", user, "/mems/", memsFile, ".rds")
    if(!file.exists(memsFile)) {
      memsFile <- NULL
      message("No MEMS file selected.")
    }
  }
  if(!input$adherenceType == "MEMS") {
    memsFile <- NULL
  }
  res <- do_sim(
    user = user,
    input = input,
    description = description,
    userData = userData,
    nPatients = nPatients,
    regimen = regimen,
    drugNames = drugNames,
    memsFile = memsFile)
  if(!is.null(progress)) {
    progress$set(value = 0.6, detail = "Plotting...")
  }
  return(res)
}
