#' Run TBsim simulation
#'
#' @param sim sim simulation definition
#' @param bin binary file
#' @param keep_bin keep binary file after execution
#' @param run run the simulation?
#' @param jobscheduler submit to job scheduler?
#' @param submit_cmd job scheduler submit command to prepend
#' @export
tb_run_sim <- function(sim = NULL,
                       bin = "TBsim",
                       keep_bin = FALSE,
                       run = TRUE,
                       jobscheduler = FALSE,
                       queue = "main.q",
                       results_folder = "/data/tbsim",
                       submit_cmd = "qsub") {
  folder <- sim$dataFolder
  if(dir.exists(folder)) {
    stop("Output folder already exists, not starting new job.")
  }
  config_folder <- paste0(folder, "/config")
  if (!file.exists(folder)) {
    dir.create(folder)
  }
  if (!file.exists(config_folder)) {
    dir.create(config_folder)
  }
  if (!file.exists(sim$dataFolder)) {
    dir.create(sim$dataFolder)
  }
  # write config files to disk
  tb_write_init(sim$therapy, "therapy.txt", config_folder)
  tb_write_init(sim$adherence, "adherence.txt", config_folder)
  for (i in seq(names(sim$drugs))) {
    nam <- names(sim$drugs)[i]
    tb_write_init(sim$drugs[[nam]], paste0(nam, ".txt"), config_folder)
  }
  if(!is.null(sim)) {
    sim$drugs <- NULL
    sim$therapy <- NULL
    sim$adherence <- NULL
    tb_write_init(sim, "sim.txt", folder = config_folder)
  } else {
    message("Error: No simulation object provided!")
    stop()
  }
  tbsim <- paste0(system.file(package="TBsim"), "/", bin)
  if(file.exists(tbsim)) {
    system(paste0("cp ", tbsim, " ", folder, "/", bin))
    if (file.exists(paste0(config_folder, "/sim.txt"))) {
      if(run) {
        setwd(folder)
        cmd <- paste0("./", bin, " config/ ", "sim.txt")
        if(!jobscheduler) {
          cat("Starting execution: ", cmd, "\n")
          system(cmd)
          jobId <- NULL
          output_folder <- folder
        } else {
          keep_bin <- TRUE
          name <- paste0(
            "tbsim_", sim$id
          )
          output_folder <- paste0(results_folder, "/", stringr::str_trim(sim$id))
          if(!is.null(sim$user)) {
            output_folder <- paste0(results_folder, "/", sim$user, "/", sim$id)
          }
          cmd <- paste0(cmd, " && mkdir -p ", output_folder," && cp -R *.txt ", output_folder, "/")
          cat(paste0("Submitting job ", sim$id, "\n"))
          jobId <- Rge::qsub(cmd = cmd, name = name, queue = queue)
        }
        if(!keep_bin) {
          unlink(paste0("./", bin))
        }
        return(list(run_folder = folder,
                    output_folder = output_folder,
                    jobId = jobId,
                    name = name))
      }
    } else {
      message(paste0("Main configuration file not found!"))
    }
  } else {
    message("TBsim executable not found! Did you compile the source code?")
  }
}
