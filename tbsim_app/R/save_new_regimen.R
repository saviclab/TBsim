#' Save regimen specified as table into TBsim format
#' @export
save_new_regimen <- function(reg, description, user) {
  folder <- paste0("/data/tbsim/", user, "/regimens")
  if(!file.exists(folder)) {
    dir.create(folder)
  }
  therapy <- tb_read_init("standardTB4.txt") # read in template
  if(!is.null(reg)) {
    therapy$drug <- regimen_table_to_TBsim_format(reg)
    therapy$description <- description
    therapy$name <- description
    tmp_file <- paste0("regimen_",TBsim::random_string(5))
    therapy$id <- tmp_file
    
    ## delete existing regimen with same name
    regs <- dir(paste0("/data/tbsim/",user,"/regimens"), pattern = ".rds")
    for( i in seq(regs)) {
      reg_file <- paste0("/data/tbsim/",user,"regimens","/",regs[i])
      tmp <- readRDS(file = reg_file)
      if(!is.null(tmp$name) && tmp$name == therapy$name) {
        unlink(reg_file)
      }
    }

    ## save new regimen
    saveRDS(therapy, file = paste0("/data/tbsim/", user, "/regimens/", tmp_file, ".rds"))
  }
  return(therapy)
}
