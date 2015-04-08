multiPlot4 <- function(..., plotlist=NULL, file, cols=1, layout=NULL, label1, label2) {
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
    # Set up the page
    grid.newpage()
	
    pushViewport(viewport(layout = grid.layout(nrow(layout)+ 3, ncol(layout), 
				 heights = unit(c(1, 0.7, 0.7, rep(nrow(layout),4)),"null"))))
	grid.text(label1, gp=gpar(fontsize=12, fontface="bold"), vp = viewport(layout.pos.row = 1, layout.pos.col = 1:ncol(layout)))
	grid.text(label2, gp=gpar(fontsize=10), vp = viewport(layout.pos.row = 2, layout.pos.col = 1:ncol(layout)))
	grid.text("Extracellular", gp=gpar(fontsize=10, fontface="italic"), vp = viewport(layout.pos.row = 3, layout.pos.col = 1))
	grid.text("Intracellular", gp=gpar(fontsize=10, fontface="italic"), vp = viewport(layout.pos.row = 3, layout.pos.col = 2))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row+3,
                                      layout.pos.col = matchidx$col))
    }
}