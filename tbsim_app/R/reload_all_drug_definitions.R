#' Reload all drug definitions
#'
#' @export
reload_all_drug_definitions <- function(drugNames, user) {
  drugDefinitions <- list()
  dir_base <- paste0(system.file(package="TBsim"), "/config")
  dir_user <- paste0("/data/tbsim/", user, "/drugs")
  for(i in seq(drugNames)) {
    if(file.exists(paste0(dir_base, '/', drugNames[i], ".txt"))) {
      drugDefinitions[[drugNames[i]]] <- tb_read_init(file = drugNames[i], folder = dir_base)
    } else { # try if custom
      drugDefinitions[[drugNames[i]]] <- tb_read_init(file = drugNames[i], folder = dir_user)
    }
  }
  return(drugDefinitions)
}
