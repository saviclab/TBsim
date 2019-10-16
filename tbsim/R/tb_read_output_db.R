#' Read output info from Db
#'
#' @param db list with information to connect to MongoDB database
#' @export
tb_read_output_db <- function(
  id,
  db = list()) {
  if(!is.null(id) && !is.null(db)) {
    if(!is.null(db$url) && !is.null(db)) {
      cat("Getting output from DB...")
      con <- mongolite::mongo("output", url = db$url)
      out <- con$find()
      cat("Done.")
      rm(con)
      gc()
      return(out)
    } else {
      cat("Couldn't read from DB: need `url`.")
    }
  }
}
