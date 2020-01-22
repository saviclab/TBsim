#' Copy the default MEMS data file to a user's folder
#'
#' @export
copy_default_mems_data <- function(userId, base = "/data/tbsim") {
  if(!exists("userID")) userId <- "anon_local"
  if(!file.exists(paste0(base,"/",userId))) {
    dir.create(paste0(base,"/",userId))
  }
  if(!file.exists(paste0(base, "/", userId, "/mems"))) {
    dir.create(paste0(base, "/", userId, "/mems"))
  }
  if(!file.exists(paste0(base, "/", userId, "/mems/default_mems.rds"))) {
    file.copy(system.file("app/mems/realdata_mems.rds", package = "TBsimApp"),
              paste0(base, "/", userId, "/mems/", "default_mems.rds"))
  }
}
