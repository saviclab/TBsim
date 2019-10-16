#' Convert a time into how long "ago" it was
#' @export
time_to_ago <- function(dat, sort = TRUE, to_character = TRUE, add_ago = TRUE) {
  df_dat <- data.frame(cbind(
    value = round(as.numeric(difftime(Sys.time(), dat, unit = "mins"))),
    unit = "mins"))
  df_dat$value <- as.num(df_dat$value)
  df_dat$unit <- as.character(df_dat$unit)
  if(sort) df_dat <- df_dat[order(df_dat$value),]
  if(to_character) {
    if(sum(df_dat$value >= (24*60)) > 0) {
      df_dat[df_dat$value >= (24*60),]$unit <- "days"
    }
    if(sum(df_dat$value >= 60 & df_dat$value < (24*60)) > 0) {
      df_dat[df_dat$value >= 60 & df_dat$value < (24*60),]$unit <- "hrs"
    }
    if(sum(df_dat$unit == "days") > 0) df_dat[df_dat$unit == "days",]$value <- round(df_dat[df_dat$unit == "days",]$value / (24*60))
    if(sum(df_dat$unit == "hrs") > 0) df_dat[df_dat$unit == "hrs",]$value <- round(df_dat[df_dat$unit == "hrs",]$value / 60)
    if(sum(df_dat$unit == "mins") > 0) df_dat[df_dat$unit == "mins",]$value <- round(df_dat[df_dat$unit == "mins",]$value)
    ago <- paste(df_dat$value, " ", df_dat$unit)
    if(any(ago == "0 mins")) { 
      ago[ago == "0 mins"] <- "less than 1 min" 
    }
    if(any(ago == "1 mins")) { 
      ago[ago == "1 mins"] <- "1min" 
    }
    if(add_ago) ago <- paste(ago, " ago")
  } else {
    ago <- df_dat$value
  }
  ago
}
