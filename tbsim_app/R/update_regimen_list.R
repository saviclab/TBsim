#' Update regimen list
#' @export
update_regimen_list <- function(cache, user) {
  cache$regimenList <- load_regimen_list_default()
  regs_info <- update_regimen_list_user(user)
  for(key in names(regs_info)) {
    cache$regimenList[[key]] <- regs_info[[key]]
  }
  cache$regimenList <- cache$regimenList[order(names(cache$regimenList))]
  return(cache)
}
