#' Generate PDF report
#' @export
generate_pdf_report <- function(file) {

  # Copy the report file to a temporary directory before processing it, in
  # case we don't have write permissions to the current working dir (which
  # can happen when deployed).
  tempReport <- file.path(tempdir(), "report.Rmd")
  file.copy("report.Rmd", tempReport, overwrite = TRUE)

  # Set up parameters to pass to Rmd document
  params <- list(n = 100)

  # Knit the document, passing in the `params` list, and eval it in a
  # child of the global environment (this isolates the code in the document
  # from the code in this app).
  rmarkdown::render(tempReport, output_file = file,
    params = params,
    envir = new.env(parent = globalenv())
  )
}
