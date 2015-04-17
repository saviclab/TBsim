#' @export
tb_read_macro <- function(folder) {
  dat <- tb_read_file(folder, "macro.txt", "macro")
  out <- list (
    times = output[[1]],
    compartments = output[[2]],
    Ma50 = output[[3]],
    Mr50 = output[[4]],
    Mr50 = output[[5]]
  )
}
