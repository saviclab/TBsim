#' @export
tb_read_adherence <- function(folder) {
  y1 <- read.table(paste(folder, "/adherence.txt", sep=""), header=FALSE, sep="\t", skip=1)
  y2 <- y1[,1:600]
  y2[,1:180] <- 1
  y2[,361:600] <- 1
  adh <- data.matrix(y2)
  adh
}
