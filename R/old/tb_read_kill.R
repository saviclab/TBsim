#' @export
tb_read_kill <- function(folder) {
  dat <- tb_read_file(folder, "calcKill.txt", "calcKill")
  out <- list (
    times = output[[1]],
    drugs = output[[2]],
    compartments = output[[3]],
    kills = output[[4]]
  )
}


