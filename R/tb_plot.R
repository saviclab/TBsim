#' @export
tb_plot <- function(info, data, theme = theme_plain, ...) {
	pl <- do.call(paste0("tb_plot_", attr(data, "type")), list(info, data, ...))
	if(!is.null(theme)) {
	  if("list" %in% class(pl)) {
	    for (i in seq(names(pl))) {
	      pl[[names(pl)[i]]] <- pl[[names(pl)[i]]] + theme()
	    }
	  } else {
	    pl <- pl + theme()
	  }
	}
	return(pl)
}
