#' Get list of simulation results
#' @export
get_sim_results_list <- function(
  folder = "/data/tbsim",
  user = "ronkeizer@gmail.com",
  pattern = "",
  read_output = FALSE,
  write_db = TRUE,
  type = "all"
) {
  dirs <- dir(paste0(folder, "/", user), pattern = pattern)
  res <- list()
  if(length(dirs) > 0) {
    tbsim_dirs <- c()
    for(i in 1:length(dirs)) {
      if(file.exists(paste0(folder, "/", user, "/", dirs[i], "/output/description.txt"))) {
        if(!(dirs[i] %in% c("drugs", "therapy"))) {
          tbsim_dirs <- c(tbsim_dirs, dirs[i])
        }
      }
    }
    if(length(tbsim_dirs) > 0) {
      for(i in 1:length(tbsim_dirs)) {
        res_folder <- paste0(folder, "/", user, "/", tbsim_dirs[i])
        d_file <- paste0(res_folder, "/output/description.txt")
        descr <- file_to_text(d_file)
        tmp <- list(
           id = tbsim_dirs[i], description = descr,
           outcome = NA, npatients = 0,
           status = "unfinished", datetime = NA, results = NA
          )
        if(file.exists(paste0(res_folder, "/output/header.txt"))) {
          tmp$status <- "finished"
          tmp$datetime <- as.character(file.info(paste0(res_folder, "/output/header.txt"))$mtime)
          if(read_output) {
            tmp$results <- TBsim::tb_read_all_output(
              folder = res_folder,
              output_folder = TRUE
            )
          }
          sim <- TBsim::tb_read_output(res_folder, type="header")
          tmp$nPatients <- sim$nPatients
        }
        if(file.exists(paste0(res_folder, "/output/outcome.txt"))) {
          outc <- TBsim::tb_read_output(res_folder, type="outcome")
          if(!is.null(outc)) {
            tmp$outcome <- 1 - tail(outc$AcuteTB,2)[1]
          }
        }
        if(type == "all" || type == "population") {
          if(!is.null(sim$nPatients) && sim$nPatients > 1) {
            res[[tbsim_dirs[i]]] <- tmp
          }
        }
        if(type == "all" || type == "single") {
          if(!is.null(sim$nPatients) && sim$nPatients == 1) {
            res[[tbsim_dirs[i]]] <- tmp
          }
        }
      }
    }
  }
  if(write_db && length(res) > 0) { ## write to a database csv file the
    f <- paste0(folder, "/", user, "/tbsim_runs.csv")
    # csv <- c()
    # if(file.exists(f)) {
    #   csv <- read.csv(f)
    # }
    descr <- gsub("\n", "", pluck(res, "description"))
    # print(pluck(res, "datetime"))
    # print(length())
    db <- data.frame(cbind(
      id = pluck(res, "id"),
      description = descr,
      outcome = 0,
      n_patients = 0,
      started = pluck(res, "datetime")
    ))
    csv <- db #data.frame(rbind(csv, db))
    csv <- csv[!duplicated(csv$id),]
    colnames(csv) <- c("id", "description", "outcome", "n_patients", "datetime")
    write.csv(csv, file=f, quote=F, row.names=F)
    # message("Writing db file: ", f)
  }
  return(res)
}
