#' Pluck (like in JavaScript)
#' @export
pluck <- function (x, i, type) {
    if (missing(type)) {
        as.character(unlist(lapply(x, .subset2, i)))
    } else {
        as.character(unlist(vapply(x, .subset2, i, FUN.VALUE = type)))
    }
}
