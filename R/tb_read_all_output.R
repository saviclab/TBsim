#' Read all output from TBsim
#'
#' @param folder folder with output
#' @param db list with information to connect to MongoDB database
#' @export
tb_read_all_output <- function(
  folder,
  output_folder = FALSE,
  id = NULL,
  s3 = NULL,
  db = NULL) {
  if(!file.exists(folder)) {
    stop("TBsim output folder not found.")
  }
  l <- list(
    info  = tb_read_output(folder, "header", output_folder = output_folder),
    outc  = tb_read_output(folder, "outcome", output_folder = output_folder),
    bact  = tb_read_output(folder, "bact", output_folder = output_folder),
    bactRes = tb_read_output(folder, "bactRes", output_folder = output_folder),
    conc  = tb_read_output(folder, "conc", output_folder = output_folder),
    dose  = tb_read_output(folder, "dose", output_folder = output_folder),
    eff   = tb_read_output(folder, "effect", output_folder = output_folder),
    kill  = tb_read_output(folder, "kill", output_folder = output_folder),
    imm   = tb_read_output(folder, "immune", output_folder = output_folder),
    macro = tb_read_output(folder, "macro", output_folder = output_folder)
  )
  if(!is.null(db)) {
    if(!is.null(db$url) && !is.null(id)) {
      l$id <- db$id
      cat("Saving output to DB...")
      con <- mongolite::mongo("output", url = db$url)
      con$insert(l)
      cat("Done.")
      rm(con)
      gc()
    } else {
      cat("Couldn't save to DB: need `db$url` and `id` arguments.")
    }
  }
  return(l)
}
