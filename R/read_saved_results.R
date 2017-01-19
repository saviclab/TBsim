#' Read info from folder with saved runs
#' 
#' @param folder main folder where data is saved (default `/data`)
#' @param user username
#' @param read_all read all data (`TRUE``) or only header information (`FALSE`, default) from output data
#' @export
read_saved_results <- function(
  folder = '/data/tbsim',
  user = 'ronkeizer@gmail.com',
  read_all = FALSE,
  id = NULL
) {
  full_folder <- paste0(folder, '/', user)
  runs <- list()
  if(dir.exists(full_folder)) {
    all <- dir(full_folder)
    if(length(all) > 0) {
      for(i in seq(all)) {
        sub_folder <- paste0(full_folder, '/', all[i])
        tmp <- dir(sub_folder)
        if("header.txt" %in% tmp) {
          if(read_all) {
            obj <- tb_read_all_output()
          } else {
            obj <- tb_read_output(sub_folder, "header", output_folder = FALSE)
          }
          runs[[all[i]]] <- obj
        }
      }
    } 
    if(length(runs) == 0) {
      message(paste0("No results for user ", user, " were found"))
    }
  } else {
    message(paste0("No results for user ", user, " were found"))
  }
  return(runs)
}
