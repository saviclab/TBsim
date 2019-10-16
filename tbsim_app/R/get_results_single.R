#' Get results for single simulation
#'
#' @export
get_results_single <- function() {
  init$userId="anon_local"
  res <- get_sim_results_list(user = init$userId, type="single")
  dat <- pluck(res, 'datetime')
  if(length(dat)>0) {
    tab <- data.frame(cbind(
      Run = pluck(res, 'id'),
      Description = pluck(res, 'description'),
      Status = pluck(res, 'status')))
    if(!is.null(tab) && nrow(tab > 0)) {
      tab$ago <- NA
      tab$ago[!is.na(dat)] <- time_to_ago(dat[!is.na(dat)], sort=FALSE, to_character = FALSE)
      tab$Finished <- NA
      tab$Finished[!is.na(dat)] <- time_to_ago(dat[!is.na(dat)], sort=FALSE, to_character = TRUE)
      tab <- tab[order(tab$ago),]
      tab <- tab[tab$Status=="finished",]#tab %>% filter(Status == "finished")
    }
    tab[,c("Run", "Description", "Finished")]
  }
}
