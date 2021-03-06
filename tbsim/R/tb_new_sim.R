#' @export
tb_new_sim <- function(template_file = NULL,
                       template_folder = NULL,
                       central_folder = "/data/tbsim/",
                       folder = NULL,
                       id = NULL,
                       drugVariability = TRUE,
                       seed = NULL,
                       description = "No description",
                       user = NULL,
                       therapy = NULL,
                       adherence = NULL,
                       drugs = NULL,
                       nPatients = 100,
                       nTime = 365,
                       nPopulations = 1,
                       nThreads = 4,
                       immune=NULL,
                       memsFile = NULL,
                       ... ) {
  if(is.null(folder)) {
    folder <- new_tempdir()
  }
  if(is.null(id)) {
    id <- TBsim::random_string()
  }
  folder <- gsub("~", path.expand("~"), folder)
  if (is.null(template_folder)) {
    template_folder <- paste0(system.file(package="TBsim"), "/config")
  }
  if(is.null(template_file)) {
    obj <- tb_read_init("TBinit.txt", folder = template_folder)
  } else {
    obj <- tb_read_init(template_file, folder = template_folder)
  }
  if(is.null(folder)) {
    message(paste0("Warning: working directory not specified, using '", path.expand("~"), "/tb_run'."))
    folder <- paste0(path.expand("~"), "/tb_run")
  }
  obj$id <- id
  if(is.null(user) && Sys.getenv("USER") != "") {
    user <- Sys.getenv("USER")
  }
  obj$user <- user
  obj$description <- gsub("\n", "", description)
  obj$dataFolder <- paste0(folder, "/output/")
  obj$batchMode <- 1
  obj$therapy <- therapy
  obj$drugs <- drugs
  obj$adherence <- adherence
  obj$immune <- immune
  obj$therapyFile <- "therapy.txt"
  obj$drugFile <- c()
  for(i in seq(names(drugs))) {
    obj$drugFile <- c(obj$drugFile, c(paste0(names(drugs)[i], ".txt")))
  }
  obj$memsFile <- memsFile
  obj$adherenceFile <- "adherence.txt"
  obj$nPatients <- nPatients
  obj$nTime <- nTime
  obj$nPopulations <- nPopulations
  obj$nThreads <- nThreads
  obj$drugVariability <- drugVariability
  if(!is.null(seed)) {
    obj$seed <- seed
  }
  args <- names(list(...))
  for (i in seq(args)) {
    if(args[i] %in% names(allowed_args)) {
      obj[[args[i]]] <- list(...)[[args[i]]]
    } else {
      message(paste0("Warning: argument '", args[i], "' is unknown, and will not be passed to the TBsim tool. Please list 'allowed_args' for list of possible arguments."))
    }
  }
  class(obj) <- c(class(obj), "TBsim")
  return(obj)
}
