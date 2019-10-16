#' Convert data from raw MEMS data file into format readable by TBsim
#'
#' @param filename filename to read data from (CSV)
#' @param data data.frame with MEMS data (either `filename` or `data` need to be specified)
#' @export
convert_mems_data <- function(
  filename = NULL, data = NULL, limit = NULL) {
  if(!is.null(filename)) {
    data <- read.csv(file = filename)
  }
  if(is.null(data) || !all(c("ID", "DAYS", "HOURS") %in% names(data))) {
    warning("Incorrect MEMS file format.")
    return(NULL)
  }
  mems <- data %>%
    dplyr::mutate(id = as.factor(ID)) %>%
    dplyr::group_by(ID) %>%
    dplyr::mutate(dtime = (DAYS*24 + HOURS) / 24) %>%
    dplyr::mutate(time_rounded = round(dtime) - min(round(dtime)))
  days_per_id <- mems %>%
    dplyr::group_by(ID) %>%
    dplyr::summarise(days = round(max(dtime) - min(dtime))) %>%
    dplyr::rename(id = ID)
  all <- list()
  n_ids <- min(limit, nrow(days_per_id))
  message(paste0("Parsing MEMS data for ", n_ids, " subjects..."))
  for(i in 1:n_ids) {
    tmp <- data.frame(id = i, day = 1:days_per_id[i,]$days, adherence = 0)
    mems_id <- mems %>%
      dplyr::filter(id == days_per_id[i,]$id)
    tmp[tmp$day %in% mems_id$time_rounded,]$adherence <- 1
    all[[i]] <- tmp$adherence
  }
  message("Done.")
  return(all)
}
