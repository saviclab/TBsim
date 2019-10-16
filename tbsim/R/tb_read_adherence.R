#' @export
tb_read_adherence <- function(folder) {
  suppressWarnings({
    dat <- as.numeric(as.character(read.table(paste(folder, "/adherence.txt", sep=""))$V1))
  })
  dat <- dat[!is.na(dat)]
  adh <- data.frame(time = 1:length(dat), adherence = dat)
  return(adh)
}
