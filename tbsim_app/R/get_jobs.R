#' Get jobs in queue
#' @export
get_jobs <- function() {
  ## read descriptions
  csv_file <- paste0("/data/tbsim/", init$userId, "/tbsim_runs.csv")
  csv <- c()
  if(file.exists(csv_file)) {
    csv <- read.csv(csv_file)
  }

  ## read GE queue
  tab <- Rge::qstat()
  if(!is.null(tab) && length(tab[,1]) > 0) {
    tab <- tab[,c("job-ID", "name", "t_submit_start", "state")]
    tab$name <- gsub("tbsim_", "", tab$name)
    tab$state <- as.character(tab$state)
    if(sum(tab$state == "qw") > 0) {
      tab$state[tab$state == "qw"] <- "waiting"
    }
    if(sum(tab$state == "r") > 0) {
      tab$state[tab$state == "r"] <- "running"
    }
    tab$description <- ""
    for(i in 1:nrow(tab)) {
      if(tab[i,]$name %in% csv$id) {
        tab[i,]$description <- as.character(csv[match(tab[i,]$name, csv$id),]$description)
      }
    }
    tab$t_submit_start <- round(as.numeric(difftime(
      Sys.time(),
      anytime(tab$t_submit_start), units = "mins")))
    tab$t_submit_start <- paste0(tab$t_submit_start, " mins ago")
    colnames(tab) <- c("Job", "id", "Submitted / Started", "Status", "Description")
    cache$qstat_runs <<- tab
    return(tab[,-c(1,2)][,c("Description", "Status", "Submitted / Started")])
  }
}
