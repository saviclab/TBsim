#' @export
tb_write_init <- function (obj,
                           file = NULL,
                           folder = NULL) {
  if (is.null(folder)) {
    folder <- paste0(system.file(package="TBsim"), "/run")
  }
  txt <- c()
  for (i in seq(names(obj))) {
    for (j in 1:length(unlist(obj[i]))) {
      txt <- c(txt, paste("<", names(obj)[i], ">", unlist(obj[i])[j], sep=""))
    }
  }
  if(!is.null(file)) {
    if (length(txt)>0) {
      if (!file.exists(paste0(folder))) {
        dir.create(paste0(folder))
      }
      message(paste0("Writing ", file, " config file to: ", folder, "/", file))
      conn <- file(paste0(folder, "/", file))
      writeLines(text = txt, conn)
      close(conn)
    }
  } else {
    message("No filename provided!")
  }
}
