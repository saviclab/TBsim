#' @export
tb_run_sim <- function(obj = NULL,
                       ini_file = NULL,
                       bin = "TBsim",
                       keep_bin = FALSE) {
  folder <- obj$dataFolder
  config_folder <- paste0(folder, "/config")
  if (!file.exists(folder)) {
    dir.create(folder)
    dir.create(config_folder)
  }
  if(!is.null(obj)) {
    ini_file = "tmp.txt"
    tb_write_init(obj, "tmp.txt", folder=config_folder)
  } else {
    if(!is.null(ini_file)) {
#
    }
  }
  tbsim <- paste0(system.file(package="TBsim"), "/", bin)
  if(file.exists(tbsim)) {
    #setwd(system.file(package="TBsim"))
    input_folder <- paste0(system.file(package="TBsim"), "/config")
    system(paste0("cp ", tbsim, " ", folder, "/", bin))
    system(paste0("cp -R ", input_folder, "/* ", config_folder,"/"))
    if (file.exists(paste0(config_folder, "/tmp.txt"))) {
      setwd(folder)
      system(paste0("./", bin, " config/ ", "tmp.txt"))
      if(!keep_bin) {
        unlink(paste0("./", bin))
      }
    } else {
      message(paste0("Main configuration file not found!"))
    }
  } else {
    message("TBsim executable not found! Did you compile the source code?")
  }
}
