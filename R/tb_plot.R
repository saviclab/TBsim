#' @export
tb_plot <- function(info, data, ...) {
	do.call(paste0("tb_plot_", attr(data, "type")), list(info, data, ...))
}