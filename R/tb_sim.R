#' @export
tb_sim <- function(ini = "RPT", bin = "TBsim") {
  setwd(system.file(package="TBsim"))
  if(file.exists(bin)) {
    if (file.exists(paste0("config/", ini, ".txt"))) {
      system(paste0("./", bin, " config/", ini, ".txt"))
    } else {
      message(paste0("Ini-file not found!"))
    }
  } else {
    message("TBsim executable not found! Did you compile the source code?")
  }
}
