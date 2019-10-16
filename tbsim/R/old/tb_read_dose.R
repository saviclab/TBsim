#' @export
tb_read_dose <- function(folder) {
  dat <- tb_read_file(folder, "calcDose.txt", "calcDose")
  out <- list (
    times = output[[1]],
    drugs = output[[2]],
    compartments = output[[3]],
    doses = output[[4]]
  )
}

