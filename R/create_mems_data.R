#' Create a matrix of MEMS data for use in TBsim from observed MEMS data
#' The function basically fills in any missing days when, and can
#' randomly draw more patients from the dataset.
#'
#' @param data Observed MEMS data (as list). See example.
#' @param n_patients number of patients to output
#' @param n_events number of days/dosing events per patient
#' @param random randomize the draw of patients?
#' @param seed randomization seed
#' @param file if not `NULL`, will write to specified CSV file
#'
#' @example
#' mems_data <- list(
#'   "a" = c(1,1,1,1,1,0,1,0,0,1,1,1,1,0,1),
#'   "b" = c(,1,1,0,1,0,1,1,1,1,1,0,1,1,1,0,1,1,0))
#' create_mems_data(mems_data, n_patients = 100, random = TRUE)
#' @export
create_mems_data <- function(
  data = NULL,
  n_patients = NULL,
  n_events = 180,
  therapy_start = 90,
  random = TRUE,
  seed = NULL,
  file = NULL
) {
  data <- as.list(data)
  if(is.null(data) || !("list" %in% class(data))) stop("MEMS data needed, specified as list object.")
  if(is.null(n_patients)) n_patients <- length(data)
  if(n_patients > length(data) && n_patients > 1) {
    data <- data[rep(1:length(data), ceiling(n_patients/length(data)))]
    data <- data[1:n_patients]
  }
  if(random) {
    if(!is.null(seed)) {
      set.seed(seed)
    }
    data <- data[order(runif(length(data)))]
    if(n_patients == 1) list(data)
  }
  if(n_patients == 0) stop("Zero patients in data or zero patients requested.")
  fill <- function(vec, n) {
    rep(vec, ceiling(n/length(vec)))[1:n]
  }
  tmp <- matrix(unlist(lapply(data, "fill", n_events)), ncol = n_events, byrow = TRUE)
  pre_treatment <- matrix(0, nrow = nrow(tmp), ncol = therapy_start)
  tmp <- cbind(pre_treatment, tmp)
  if(!is.null(file)) {
    if(n_patients > 1) {
      write.table(tmp, file = file, quote = F, row.names = F, col.names = F, sep = ",")
    } else {
      write.table(data.frame(tmp), file = file, quote = F, row.names = F, col.names = F, sep = ",")
    }
  } else {
    return(tmp)
  }
}
