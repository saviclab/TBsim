#' Update drug list
#'
#' @export
update_drug_list <- function(cache, user, drugNames) {
    cache$drugListData <- get_drug_list(drugNames, user)
    cache$combinedDrugList <- cache$drugListData$Drug
    cache$combinedDrugNameList <- cache$drugListData$Name
    cache$drugDefinitions <- reload_all_drug_definitions(cache$combinedDrugList, user)
    return(cache)
}
