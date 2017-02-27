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
