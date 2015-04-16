#' @export
tb_read_effect <- function(folder) {
  dat <- tb_read_file(folder, "effect.txt", "effect")
  out <- list (
    times = output[[1]],
    drugs = output[[2]],
    compartments = output[[3]],
    values = output[[4]]
  )
}

