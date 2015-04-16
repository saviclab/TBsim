#' @export
tb_read_conc <- function(folder) {
  dat <- tb_read_file(folder, "calcConc.txt", "calcConc")
  out <- list (
    times = output[[1]],
    drugs = output[[2]],
    compartments = output[[3]],
    concs = output[[4]]
  )
}
