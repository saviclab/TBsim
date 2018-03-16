#' @export
tb_read_output <- function(folder = "~/tb_run", type = NULL, output_folder = TRUE) {

  if(is.null(type)) {
  	stop("type argument required!")
  }
  if(output_folder) {
    folder <- paste0(folder, "/output")
  }

  ## Non-standard output files:
  tmp <- NULL
  if(type == "header") {
  	tmp <- tb_read_headerfile(folder)
  }
  if(type == "outcome") {
  	tmp <- tb_read_outcome(folder)
  }
  if(type == "bact") {
  	tmp <- tb_read_bact_totals(folder)
  }
  if(type == "immune") {
  	tmp <- tb_read_immune(folder)
  }
  if(type == "macro") {
  	tmp <- tb_read_macro(folder)
  }
  if(type == "granuloma") {
  	tmp <- tb_read_granuloma(folder)
  }
  if(type == "adherence") {
    tmp <- tb_read_adherence(folder)
  }

  if(!is.null(tmp)) {
  	attr(tmp, "type") <- type
   	return(tmp)
  }

  ## standard output files
  def <- NULL
  type_def <- type
  if(type == "granuloma") {
  	def <- c("times", "iterations", "formation", "breakup")
  }
  if(type == "conc") {
  	def <- c("times", "drugs", "compartments", "concs")
  	type_def <- "calcConc"
  }
  if(type == "bactRes") {
    def <- c("times", "types", "compartments", "values")
    type_def <- "bactRes"
  }
  if(type == "dose") {
  	def <- c("times", "drugs", "compartments", "doses")
  	type_def <- "calcDose"
  }
  if(type == "kill") {
  	def <- c("times", "drugs", "compartments", "kills")
  	type_def <- "calcKill"
  }
  if(type == "effect") {
  	def <- c("times", "types", "compartments", "values")
  }
  if(type == "adherence") {
    def <- c("times", "adh")
  }
  dat <- tb_read_file(folder, paste0(type_def, ".txt"), type_def)
  if (!is.null(def)) {
  	out <- list()
  	for(i in seq(def)) {
  		out[[def[i]]] <- dat[[i]]
  	}
	attr(out, "type") <- type
	return(out)
  } else {
  	message("Output type not recognized.")
  }
}
