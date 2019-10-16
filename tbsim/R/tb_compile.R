#' @export
tb_compile <- function (input_folder = NULL, cpp = "gcc") {
  if (!is.null(input_folder)) {    # copy files to R install folder
    system(paste0("cp -R ", input_folder, " ", system.file(package="TBsim")))
  }
  setwd(system.file(package="TBsim"))
  if(file.exists("obj")) {
    system("rm -rf obj")
  }
  dir.create("obj")
  system(paste0(cpp, " -v"))
  if (!is.null(cpp)) {
    system(paste0("CXX=", cpp, " make -f makefiles/makefile.txt"))
  } else {
    system("make -f makefiles/makefile.txt")
  }
}
