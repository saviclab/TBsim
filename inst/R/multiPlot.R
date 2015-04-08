multiPlot <- function(..., plotlist=NULL, file, cols=1, layout=NULL, label) {
  require(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
	
    pushViewport(viewport(layout = grid.layout(nrow(layout)+ 2, ncol(layout), 
		         heights = unit(c(0.5, 0.5, rep(nrow(layout),4)),"null"))))
	grid.text(label, gp=gpar(fontsize=12), vp = viewport(layout.pos.row = 1, layout.pos.col = 1:ncol(layout)))
	grid.text("Extracellular", just = "centre", gp=gpar(fontsize=11), vp = viewport(layout.pos.row = 2, layout.pos.col = 1))
	grid.text("Intracellular", just = "centre", gp=gpar(fontsize=11), vp = viewport(layout.pos.row = 2, layout.pos.col = 2))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row+2,
                                      layout.pos.col = matchidx$col))
    }
  }
}