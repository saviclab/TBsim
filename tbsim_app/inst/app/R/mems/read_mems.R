## Purpose: read MEMS data, make some plots, fit models
require("tidyverse")
require("ggplot2")
require("reshape")
require("vpc")

setwd("~/git/insightrx/ucsf-tbsim-shiny/app/R/mems/")
mems <- convert_mems_data("./realdata_mems.csv")

convert_mems_data <- function(filename = NULL, data = NULL) {
  if(!is.null(filename)) {
    data <- read.csv(file = filename) 
  }
  if(is.null(data)) stop("No data specified")
  mems <- data %>%
    mutate(id = as.factor(ID)) %>%
    group_by(ID) %>%
    mutate(dtime = (DAYS*24 + HOURS) / 24) %>%
    mutate(time_rounded = round(dtime) - min(round(dtime)))
  days_per_id <- mems %>%
    group_by(ID) %>%
    summarise(days = round(max(dtime) - min(dtime))) %>%
    rename(id = ID)
  message(paste0("Parsing MEMS data for ", nrow(days_per_id), " subjects..."))
  all <- c()
  for(i in 1:nrow(days_per_id)) {
    tmp <- data.frame(id = i, day = 1:days_per_id[i,]$days, adherence = 0)
    mems_id <- mems %>% filter(id == days_per_id[i,]$id)
    tmp[tmp$day %in% mems_id$time_rounded,]$adherence <- 1
    all <- bind_rows(all, tmp)
  }
  message("Done.")
  return(all)
}

ids <- unique(mems$ID)
mems[mems$DT <= 1.5,]$DT_fact <- "Adherent"
mems[mems$DT > 1.5 & mems$DT <= 2.5,]$DT_fact <- "Missed 1"
mems[mems$DT > 2.5 & mems$DT <= 5.5,]$DT_fact <- "Missed 2-5"
mems[mems$DT > 5,]$DT_fact <- "Missed >5"

cols <- c("#8ec09c", "#6e7cd9", "#fdce81","#ec6151")
sizes <- c(0.5, 1, 1.5, 2, 2.5, 3)*1.5

theme_set(theme_grey())
ggplot (mems[mems$DREL<=365 & mems$ID %in% ids[1:50],], 
        aes(x=DREL, y=ID, 
            colour=factor(DT_fact, levels=c("Adherent", "Missed 1", "Missed 2-5", "Missed >5")))) + 
  geom_point(shape = 19, aes(size=factor(DT_fact, levels=c("Adherent", "Missed 1", "Missed 2-5", "Missed >5")))) + 
  scale_colour_manual("", values = cols) + 
  scale_size_manual("", values=sizes) +
  theme (axis.ticks.y = element_blank(), axis.text.y = element_blank(), 
         panel.grid = element_blank()) +
  xlab ("Time (days)") + ylab ("Patient")
