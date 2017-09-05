#' Gggplot2 is not very good at labeling the y-axis on log plots,
#' so always make sure we have at least one order of magnitude
#' on the scale, and 3 ticks.
#'
#' @param dat y values
#' @export
calc_log_breaks <- function(dat) {
  magn <- 10^(-20:20)
  dat <- dat[!is.na(dat)]
  if(length(dat) == 0) return(c(0,1))
  dat <- dat[dat > 0]
  if(length(dat) == 0) return(c(0,1))
  rng <- range(dat)
  ymax <- magn[(magn-max(dat, na.rm=TRUE))>0][1]
  ymin <- tail(magn[(magn-min(dat, na.rm=TRUE))<0],1)
  betwn <- c()
  if(length(ymin) == 0) ymin <- ymax / 10
  magn_diff <- round(log10(ymax / ymin))
  if(magn_diff == 1) {
    # if only one order of magnitude, then
    # put some values between
    betwn <- ymin * 5*10^(0:(round(log10(ymax / ymin)-1)))
  } else {
    # just put break at every order of magnitude
    betwn <- ymin * 10^(1:(magn_diff-1))
  }
  scal <- c(ymin, betwn, ymax)
  return(scal)
}
