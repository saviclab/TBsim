#' Convert Regimen Table to TBsim format
#' @export
regimen_table_to_TBsim_format <- function(dat) {
  r <- c()
  if(!is.null(dat$Include)) {
    dat <- dat[dat$Include,]
  }
  freq <- list(
    "Twice daily" = 0.5,
    "Once daily" = 1,
    "Twice weekly" = 3.5,
    "Thrice weekly" = 2.33,
    "Once weekly" = 7)
  dat$Frequency <- as.num(lapply(dat$Frequency, function(x) { freq[[as.character(x)]] }))
  dat[["Duration (days)"]] <- as.character(as.num(dat[["Duration (days)"]]) + (as.num(dat[["Start (days)"]]))-1)
  for(i in 1:nrow(dat)) {
    r <- c(r, paste0(
      as.character(dat[i,1]), "|",
      stringr::str_c(dat[i,2:5], collapse="|"), "|"))
  }
  return(r)
}
