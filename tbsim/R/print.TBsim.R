#' @export
print.TBsim <- function(x, ... ) {
  for(i in seq(names(x))) {
    cat(paste0(names(x)[i], ": ", x[[names(x)[i]]], "\n"))
  }
}
