#' @export
tb_new_sim <- function(template_file = NULL,
                       template_folder = NULL,
                       folder = NULL,
                       therapy = NULL,
                       adherence = NULL,
                       drugs = NULL,
                       nPatients = 100,
                       nTime = 365,
                       nPopulations = 1,
                       nThreads = 4,
                       ... ) {
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
  obj$dataFolder <- paste0(folder, "/output/")
  obj$batchMode <- 1
  obj$therapy <- therapy
  obj$drugs <- drugs
  obj$adherence <- adherence
  obj$therapyFile <- "therapy.txt"
  obj$drugFile <- c()
  for(i in seq(names(drugs))) {
    obj$drugFile <- c(obj$drugFile, c(paste0(names(drugs)[i], ".txt")))
  }
  obj$adherenceFile <- "adherence.txt"
  obj$nPatients <- nPatients
  obj$nTime <- nTime
  obj$nPopulations <- nPopulations
  obj$nThreads <- nThreads
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
