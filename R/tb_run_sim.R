#' @export
tb_run_sim <- function(sim = NULL,
                       bin = "TBsim",
                       keep_bin = FALSE,
                       run = TRUE) {
  folder <- gsub("/output/", "", sim$dataFolder)
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
        system(paste0("./", bin, " config/ ", "sim.txt"))
        if(!keep_bin) {
          unlink(paste0("./", bin))
        }
      }
    } else {
      message(paste0("Main configuration file not found!"))
    }
  } else {
    message("TBsim executable not found! Did you compile the source code?")
  }
}
