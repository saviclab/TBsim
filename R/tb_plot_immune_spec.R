########################################################
# Generate graphs of immune cells and cytikines
# Oct 5, 2014 by John Fors
# updates Ron Keizer, 2015
########################################################

#' @export
tb_plot_immune_spec <- function(yset, names, mainTitle, subTitle, ytext, drugStart = NULL) {
  # Prepare data
  colnames(yset) <- names
  dfm2		<- reshape2::melt(yset, id="time", na.rm=TRUE)
  plot.main	<- mainTitle
  plot.sub	<- subTitle
  xtext		<- "Time after infection start (Days)"

  # Generate plot
  dfm2 <- dfm2 %>% dplyr::filter(value > 1e-6)
  if (!is.null(drugStart)) {
    dfm2$time <- dfm2$time - drugStart
    xtext		<- "Time after drug treatment start (Days)"
  }

  pl <- ggplot(data = dfm2, aes(x = time, y = value, color = variable, group=variable)) +
    geom_line(linetype="solid", size=1) +
    theme_empty() +
    scale_color_brewer(palette="Set1") +
    theme(legend.position="bottom", legend.title=element_blank()) +
    expand_limits(y=0) +
    xlab(xtext) +
    ylab(ytext) +
    theme(plot.title = element_text(size=12, vjust=2)) +
    ggtitle(mainTitle)
  if(!is.null(drugStart)) {
    pl <- pl + geom_vline(xintercept = 0, linetype = 'dashed')
  }
  return(pl)
}
