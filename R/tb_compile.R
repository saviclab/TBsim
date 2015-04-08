#' @export
tb_compile <- function (input_folder = NULL, bin_folder = "/opt/local/bin") {
  # xcode-select --install
  if (!is.null(input_folder)) {
    # copy files to R install folder
  }
  setwd(system.file(package="TBsim"))
  system("g++ -v")
  if (!is.null(bin_folder)) {
    system(paste0("PATH=", bin_folder, ":$PATH make -f makefiles/makefile.txt"))
  } else {
    system("make -f makefiles/makefile.txt")
  }
}
