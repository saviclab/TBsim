#' New drug from template
#'
#' @export
new_drug_from_template <- function(abbr, name, user, from) {

  ## duplicate file
  file1 <- paste0(system.file(package="TBsim"), "/config/", from, ".txt")
  drugs_folder <- paste0("/data/tbsim/",user,"/drugs")
  if(!file.exists(drugs_folder)) {
    dir.create(drugs_folder, recursive = TRUE)
  }
  file2 <- paste0(drugs_folder, "/", abbr, ".txt")
  file.copy(file1, file2)

  ## update name in file
  txt <- readLines(file2)
  for(i in seq(txt)) {
    if(stringr::str_detect(txt[i], "\\<name\\>")) {
      txt[i] <- paste0("<name>",abbr)
    }
  }
  writeLines(txt, file2)

  ## update drug DB
  if(file.exists(paste0(drugs_folder, "/drugs.csv"))) {
    db <- read.csv(file=paste0(drugs_folder, "/drugs.csv"))
  } else {
    db <- c()
  }
  db <- data.frame(rbind(db,
    cbind("abbr" = abbr, "name" = name)))
  write.csv(db, paste0(drugs_folder, "/drugs.csv"), col.names=F, row.names=F, quote=F)

  if(file.exists(file2)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}
