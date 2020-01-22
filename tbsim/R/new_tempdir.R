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
  dir.create(new_dir, recursive = TRUE)
  if(dir.exists(new_dir)) {
    return(new_dir)
  } else {
    warning("Directory could not be created!")
  }
}
