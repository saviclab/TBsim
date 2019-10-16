#' Update regimen list user
#' @export
update_regimen_list_user <- function(user = NULL) {
  regs <- dir(paste0("/data/tbsim/", user, "/regimens"), pattern = ".rds")
  regs_info <- list()
  for(i in seq(regs)) {
    tmp <- readRDS(file = paste0("/data/tbsim/", user, "/regimens", "/", regs[i]))
    regs_info[[tmp$name]] <- tmp
  }
  return(regs_info)
}
