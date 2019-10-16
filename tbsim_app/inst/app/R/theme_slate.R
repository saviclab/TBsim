theme_slate <-  function () {
  dark1 <- "#1c1e22"
  dark2 <- "#272b30"
  theme(
    text = element_text(family="sans", size = 13,colour="white"),
    plot.background = element_rect(fill = dark1, colour=NA),
    plot.title = element_text(family="sans", size = 16, vjust = 1.5),
    axis.title.x = element_text(margin=margin(10,0,0,0),colour="white"),
    axis.title.y = element_text(margin=margin(0,15,0,0),colour="white"),
    axis.text.x = element_text(colour="white"),
    axis.text.y = element_text(colour="white"),
    legend.background = element_rect(fill = dark1),
    legend.position = "top",
    legend.margin=unit(0.1, "cm"),
    legend.key = element_rect(fill = dark1, colour=NA),
    legend.key.width = unit(.5, "cm"),
    plot.margin = unit(c(.1, .6, .3, 1), "cm"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.background = element_rect(fill = dark1, colour = NA),
    strip.background = element_rect(fill = dark1, colour = NA),
    strip.text = element_text(face="bold", colour = "white")
  )
}
