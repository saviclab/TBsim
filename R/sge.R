#' @param cmd command to execute
#' @param script_file script file called by submit command
#' @export
sge <- list(
  submit = function(cmd, script_file = "job.sh", submit_cmd = "qsub") {
    script <- c("#!/bin/bash", "#", "#$ -cwd", "#$ -j y", "#$ -S /bin/bash","#",
                cmd)
    fileConn <- file(script_file)
    writeLines(script, fileConn)
    close(fileConn)
    out <- system(paste(submit_cmd = submit_cmd, script_file), intern=TRUE)
    jobId <- NULL
    if(stringr::str_detect(out[1], "Your job")) {
      jobId <- stringr::str_split(
        stringr::str_split(out[1], "Your job ")[[1]][2],
        " \\("
      )[[1]][1]
    }
    return(jobId)
  },
  qstat = function(
    cmd = "qstat",
    flags = "",
    filter = NULL,
    exact = TRUE) {
    ## RK: parsing of output and handling of colnames
    ##     is very crappy, fix!
    out <- system(paste(cmd, flags), intern=TRUE)
    cols <- out[1]
    data <- out[-c(1,2)]
    tmp <- stringr::str_split(data,"\\s")
    tmp <- data.frame(t(data.frame(
      lapply(tmp, function(x) { x[x != ""] })
    )), row.names=NULL)
    col_spl <- stringr::str_split(cols,"\\s")[[1]]
    col_spl <- col_spl[col_spl != ""]
    colnames(tmp) <- col_spl[1:length(tmp[1,])]
    if(!is.null(filter)) {
      for(i in 1:length(names(filter))) {
        if(exact) {
          filt <- tmp[[names(filter)[i]]] == filter[[names(filter)[i]]]
        } else {
          filt <- !is.na(stringr::str_match(tmp[[names(filter)[i]]], filter[[names(filter)[i]]]))
        }
        tmp <- tmp[filt, ]
      }
    }
    return(tmp)
  }
)
