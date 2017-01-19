#' Random string
#' 
#' @param len length of random character string
random_string <- function(len = 6) {
  return(paste(sample(c(rep(0:9,each=5),LETTERS,letters),len,replace=TRUE),collapse=''))
}

#' Create new temp folder
#' 
#' @param base base folder
#' @param len length of random character string
#' @export
new_tempdir <- function(base = '/tmp/', len = 6) {
  new_dir <- paste0(base, random_string(len))
  dir.create(new_dir)
  if(dir.exists(new_dir)) {
    return(new_dir)
  }
}
