#' @export
tb_new_sim <- function(template_file = NULL,
                       template_folder = NULL,
                       folder = NULL) {
  if (is.null(template_folder)) {
    template_folder <- paste0(system.file(package="TBsim"), "/config")
  }
  if(is.null(template_file)) {
    obj <- tb_read_init("TBinit.txt", folder = template_folder)
  } else {
    obj <- tb_read_init(template_file, folder = template_folder)
  }
  if(is.null(folder)) {
    folder <- paste0(path.expand("~"), "/tb_run")
  }
  obj$batchMode <- 1
  obj$dataFolder <- folder
  class(obj) <- c(class(obj), "TBsim")
  return(obj)
}
