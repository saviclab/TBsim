#' Load a regimen from a TBsim regimen file into
#' a table format for displaying in the app
#' @export
load_regimen <- function(
  regimen = NULL,
  file = "therapy.txt",
  folder = NULL,
  drugDefinitions = NULL) {
  if(!is.null(file) && !is.null(folder)) {
    regimen_info <- TBsim::tb_read_init("therapy.txt", folder = folder)
  } else {
    regimen_info <- regimen
  }
  regimen_drugs <- regimen_info$drug

  drugs <- c()
  for(i in seq(regimen_drugs)) {
    tmp <- stringr::str_split(regimen_drugs[i], "\\|")[[1]][1:5]
    drugs <- rbind(drugs, tmp)
  }
  tbl <- data.frame(drugs)
  tbl$include <- TRUE
  colnames(tbl) <- c("Drug", "Daily dose (mg)",
    "Start (days)", "Duration (days)", "Frequency",  "Include")
  freq <- list(
    "Once daily" = 1,
    "Twice weekly" = 3.5,
    "Thrice weekly" = 2.33,
    "Once weekly" = 7)
  freq_tab <- data.frame(fr = names(freq), val = unlist(freq, use.names=F))
  id <- unlist(lapply(as.num(tbl$Frequency),
    function(x) { order(abs(x - freq_tab$val))[1] } ))
  tbl$Frequency <- names(freq)[id]
  tbl$Drug <- factor(tbl$Drug, levels = names(drugDefinitions))
  tbl$Frequency <- factor(tbl$Frequency, levels=names(freq))
  tbl[["Duration (days)"]] <- as.num(tbl[["Duration (days)"]]) - as.num(tbl$Start)
  tbl[["Daily dose (mg)"]] <- as.character(tbl[["Daily dose (mg)"]])
  tbl[["Start (days)"]] <- as.character(tbl[["Start (days)"]])
  tbl[["Duration (days)"]] <- as.character(tbl[["Duration (days)"]])
  return(tbl)
}
