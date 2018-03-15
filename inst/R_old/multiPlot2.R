multiPlot2 <- function(..., plotlist=NULL, file, cols=1, layout=NULL, label) {
  require(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = 8

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns
    # nrow: Number of rows
    layout <- matrix(seq(1, 8), ncol = 4, nrow = 2)
  }

    # Set up the page
    dev.new()
	grid.newpage()
	
    pushViewport(viewport(layout = grid.layout(nrow(layout)+ 1, ncol(layout), 
		heights = unit(c(1, rep(nrow(layout),4)),"null"))))
	grid.text(label, gp=gpar(fontsize=12), vp = viewport(layout.pos.row = 1, layout.pos.col = 1:ncol(layout)))

    # Make each plot, in the correct location
    for (i in 1:8) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row+1,
                                      layout.pos.col = matchidx$col))
    }
}