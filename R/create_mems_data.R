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
  n_events = 300,
  random = TRUE,
  seed = NULL,
  file = NULL
) {
  data <- as.list(data)
  if(random) data <- data[order(runif(length(data)))]
  if(is.null(data) || !("list" %in% class(data))) stop("MEMS data needed, specified as list object.")
  if(is.null(n_patients)) n_patients <- length(data)
  if(n_patients == 0) stop("Zero patients in data or zero patients requested.")
  fill <- function(vec, n) {
    rep(vec, ceiling(n/length(vec)))[1:n]
  }
  tmp <- matrix(unlist(lapply(data, "fill", n_patients)), ncol = n_events, byrow=TRUE)
  id <- 1:n_patients
  if(n_patients > length(data)) {
    tmp <- tmp[rep(1:nrow(tmp), ceiling(n_patients/nrow(tmp)))[1:n_patients],]
  }
  tmp <- tmp[1:n_patients,]
  if(random) {
    if(!is.null(seed)) {
      set.seed(seed)
    }
    if(n_patients > 1) tmp <- tmp[order(runif(n_patients)),]
  }
  if(!is.null(file)) {
    if(n_patients > 1) {
      write.table(tmp, file = file, quote = F, row.names = F, col.names = F, sep = ",")
    } else {
      write.table(t(data.frame(tmp)), file = file, quote = F, row.names = F, col.names = F, sep = ",")
    }
  } else {
    return(tmp)
  }
}
