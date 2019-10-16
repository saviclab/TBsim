#' Delete drug regimen
#' @export
delete_drug_regimen <- function(user = NULL, regimenId = "dummy") {
  filename <- paste0("/data/tbsim/",user,"/regimens/", regimenId, ".rds")
  print(filename)
  if(file.exists(filename)) {
    print('yes')
    file.remove(filename)
  }
}
