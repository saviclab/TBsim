#' Get maximum time from therapy object
#'
#' @param therapy object
#' @export
max_time_from_therapy <- function(therapy) {
    tmp <- stringr::str_split(therapy$drug, "\\|")
    max(unlist(lapply(tmp, function(x) { as.num(x[4]) })))
}
