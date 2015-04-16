#' @export
tb_run_sim <- function(obj = NULL,
                       ini_file = NULL,
                       bin = "TBsim",
                       keep_bin = FALSE,
                       run = TRUE) {
  folder <- gsub("/output/", "", obj$dataFolder)
  config_folder <- paste0(folder, "/config")
  if (!file.exists(folder)) {
    dir.create(folder)
  }
  if (!file.exists(config_folder)) {
    dir.create(config_folder)
  }
  if (!file.exists(obj$dataFolder)) {
    dir.create(obj$dataFolder)
  }
  if(!is.null(obj)) {
    ini_file = "sim.txt"
    obj$drugs <- NULL
    obj$therapy <- NULL
    obj$adherence <- NULL
    tb_write_init(obj, "sim.txt", folder=config_folder)
  } else {
    message("Error: No simulation object provided!")
    stop()
  }
  tbsim <- paste0(system.file(package="TBsim"), "/", bin)
  if(file.exists(tbsim)) {
    #setwd(system.file(package="TBsim"))
    input_folder <- paste0(system.file(package="TBsim"), "/config")
    system(paste0("cp ", tbsim, " ", folder, "/", bin))
    tb_write_init(obj$therapy, "therapy.txt", config_folder)
    tb_write_init(obj$adherence, "adherence.txt", config_folder)
    for (i in seq(names(obj$drugs))) {
      nam <- names(obj$drugs)[i]
      tb_write_init(obj$drugs[[nam]], paste0(nam, ".txt"), config_folder)
    }

    #    system(paste0("cp -R ", input_folder, "/* ", config_folder,"/"))
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
