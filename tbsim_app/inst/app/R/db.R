## Deprecated functionality!!

library(mongolite)
library(jsonlite)

###################################################
## Init
###################################################
users <- mongo(collection = "users", url = "mongodb://shinyuser:shiny12345@ds149567.mlab.com:49567/insightrx-tbsim-shiny")

###################################################
## Wrapper functions on top of mongolite to solidify DB calls
###################################################

dbUserInfo <- function(email, users) {
  tmp <- users$find(jsonlite::toJSON(list(email = email)))[1,]
  return(as.list(unlist(tmp)))
}

dbUserExists <- function(email, users) {
  tmp <- users$find(jsonlite::toJSON(list(email = email)))
  if(!is.null(tmp$email)) {
    return(TRUE)
  } else {
    return(FALSE)
  }
}

dbUserRemove <- function(email, users) {
  users$remove(jsonlite::toJSON(list(email = email)))
}

dbUserCreate <- function(email, info, users) {
  if(class(info) == "list") {
    if(!dbUserExists(email, users)) {
      info$email <- email
      users$insert(jsonlite::toJSON(info))
    } else {
      cat("User already exists.")
    }
  } else {
    stop("The `info` argument needs to be specified as a list.")
  }
}
