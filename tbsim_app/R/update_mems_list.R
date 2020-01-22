#' Refresh MEMS files for Shiny app
#' @export
update_mems_list <- function(cache = NULL, user = NULL, base_path = "/data/tbsim") {
    #if(is.null(id)) stop("No user ID provided")
    if(is.null(user)) {
      warning("No user specified")
    } else {
      mems_files <-
        paste0(dir(paste0(base_path, "/", user, "/mems/"), pattern = ".rds"))
      cache$mems_files <- stringr::str_replace_all(mems_files, "\\.rds", "")
    }
    return(cache)
}
