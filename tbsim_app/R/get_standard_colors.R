#' Use standard colors
#'
#' @export
get_standard_colors <- function(custom_drugs) {
  regimenColors <- NULL
  if(!is.null(custom_drugs)) {
    if(!("Immune" %in% custom_drugs)) custom_drugs <- c(custom_drugs, "Immune")
    if(length(custom_drugs) > 8) {
      col_func <- colorRampPalette(RColorBrewer::brewer.pal(length(custom_drugs)-8, "Paired"))
      cols <- c(
        RColorBrewer::brewer.pal(length(custom_drugs), "Dark2"),
        col_func(length(custom_drugs)-8))
    } else {
      cols <- RColorBrewer::brewer.pal(length(custom_drugs), "Dark2")
    }
    regimenColors <- list()
    for(i in seq(custom_drugs)) {
      regimenColors[[custom_drugs[i]]] <- cols[i]
    }
    regimenColors <- unlist(regimenColors, use.names=TRUE) ## ggplot2 doesn't take lists but insists on named vector
  }
  return(regimenColors)
}
