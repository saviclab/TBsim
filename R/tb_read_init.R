#' @export
tb_read_init <- function (file, folder=NULL) {
  if(length(grep("txt", file))==0) {
    file <- paste0(file, ".txt")
  }
  if(is.null(folder)) {
    folder <- paste0(system.file(package="TBsim"), "/config")
  }
  filename <- paste0(folder, "/", file)
  if (file.exists(filename)) {
    ini <- readLines(filename)
  } else {
    stop("File not found!")
  }
  obj <- list()
  for (i in seq(ini)) {
    ini[i] <- gsub("<", "", ini[i])
    tmp <- strsplit(ini[i], ">")[[1]]
    if(length(tmp) == 2) {
      suppressWarnings({
        if(!is.na(as.numeric(tmp[2]))) {
          obj[[tmp[1]]] = as.numeric(tmp[2])
        } else {
          obj[[tmp[1]]] = tmp[2]
        }
      })
    } else {
      warning(paste0("Parsing failed for: ", ini[i]))
    }
  }
  return (obj)
}
