#' Get drug list
#'
#' @export
get_drug_list <- function(builtin, user) {
  drugs_folder <- paste0("/data/tbsim/", user, "/drugs")
  if(!file.exists(drugs_folder)) {
    dir.create(drugs_folder, recursive = TRUE)
  }

  files <- dir(drugs_folder, pattern="txt")
  dat <- data.frame(
    "Drug" = names(builtin),
    "Name" = unlist(builtin),
    "Type" = "built-in", row.names=NULL)
  if(length(files) > 0) {
    drugs_found <- unlist(stringr::str_replace_all(files, "\\.txt", ""))
    if(file.exists(paste0(drugs_folder, "/drugs.csv"))) {
      db <- read.csv(file=paste0(drugs_folder, "/drugs.csv"))
      idx <- match(drugs_found, db$abbr)
      drugs <- db[idx,]$name
      dat2 <- data.frame(
                "Drug" = db[idx]$abbr,
                "Name" = drugs,
                "Type" = "custom"
              )
      ## renew Db file
      db <- data.frame(abbr = dat2$Drug, name = dat2$Name)
      write.csv(db, paste0(drugs_folder, "/drugs.csv"), row.names=F, quote=F)
      dat <- data.frame(rbind(dat, dat2), row.names=NULL)
    }
  }
  for(i in 1:3) {
    dat[,i] <- as.character(dat[,i])
  }
  return(dat)
}
