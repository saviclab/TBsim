################################################################
## Socket functions
################################################################

#' @export
clickButton <- function(id, session) {
  session$sendCustomMessage(
       type = "clickButton",
       message = list(id)
  )
}

#' @export
enableButton <- function(id, session) {
  session$sendCustomMessage(
       type = "setButtonState",
       message = list(id, "enabled")
  )
}

#' @export
disableButton <- function(id, session) {
  session$sendCustomMessage(
       type = "setButtonState",
       message = list(id, "disabled")
  )
}

#' @export
enableAnchor <- function(id, session) {
  session$sendCustomMessage(
       type = "setAnchorState",
       message = list(id, "enabled")
  )
}

#' @export
disableAnchor <- function(id, session) {
  session$sendCustomMessage(
       type = "setAnchorState",
       message = list(id, "disabled")
  )
}

#' @export
hideElement <- function(id, session) {
  session$sendCustomMessage(
       type = "hideElement",
       message = list(id)
  )
}

#' @export
showElement <- function(id, session) {
  session$sendCustomMessage(
       type = "showElement",
       message = list(id)
  )
}

#' @export
popup <- function(message, session) {
  session$sendCustomMessage(
     type = "popup",
     message = list(message)
  )
}

#' @export
activateTab <- function(tab, session) {
  session$sendCustomMessage(
     type = "activateTab",
     message = list(tab)
  )
}

#' @export
showTab <- function(tab, session) {
  session$sendCustomMessage(
     type = "showTab",
     message = list(tab)
  )
}

#' @export
hideTab <- function(tab, session) {
  session$sendCustomMessage(
     type = "hideTab",
     message = list(tab)
  )
}

#' @export
setGlobal <- function(var, value, session) {
  session$sendCustomMessage(
    type = 'setGlobal',
    message = list(var, value)
  )
}

#' @export
toggleGlobal <- function(var, session) {
  session$sendCustomMessage(
    type = 'toggleGlobal',
    message = list(var)
  )
}

#' @export
setElementText <- function(id, text, session) {
  session$sendCustomMessage(
    type = 'setElementText',
    message = list(id, text)
  )
}

#' @export
checkCheckbox <- function(id, session) {
  session$sendCustomMessage(
    type = 'checkCheckbox',
    message = list(id)
  )
}

#' @export
uncheckCheckbox <- function(id, session) {
  session$sendCustomMessage(
    type = 'uncheckCheckbox',
    message = list(id)
  )
}

#' @export
openModal <- function(id, session) {
  session$sendCustomMessage(
    type = 'openModal',
    message = list(id)
  )
}

#' @export
closeModal <- function(id, session) {
  session$sendCustomMessage(
    type = 'closeModal',
    message = list(id)
  )
}
