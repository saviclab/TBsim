#' Random string
#'
#' @param len length of random character string
#' @export
random_string <- function(len = 6) {
  return(paste(sample(c(rep(0:9,each=5),LETTERS,letters),len,replace=TRUE),collapse=''))
}

#' Write lines of text to file
#'
#' @param text vector of lines
#' @param f file name
#' @export
text_to_file <- function(text, f) {
  fileConn <- file(f)
  writeLines(text, fileConn)
  close(fileConn)
}

#' Read text from file
#'
#' @param f file name
#' @export
file_to_text <- function(f) {
  readChar(f, file.info(f)$size)
}

#' Create new temp folder
#'
#' @param base base folder
#' @param len length of random character string
#' @export
new_tempdir <- function(base = '/data/tbsim', user = "ronkeizer@gmail.com", id = NULL, len = 6) {
  if(is.null(id)) {
      id <- random_string(len)
  }
  new_dir <- paste0(base, "/", user, "/", id)
  dir.create(new_dir)
  if(dir.exists(new_dir)) {
    return(new_dir)
  }
}
