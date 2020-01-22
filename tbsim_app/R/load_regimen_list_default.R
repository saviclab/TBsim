#' Update the cached drug regimen list with
#' @export
load_regimen_list_default <- function() {
   tmp <- list(
    "HRZE daily 8 wks, HR daily 18 wks" = tb_read_init("standard_HRZE8_7wkl_HR18_7wkl.txt"),
    "HRZE daily 8 wks, HR 3x/week 18 wks" = tb_read_init("standard_HRZE8_7wkl_HR18_3wkl.txt"),
    "HRZE 3x/week 8 wks, HR 3x/week 18 wks" = tb_read_init("standard_HRZE8_3wkl_HR18_3wkl.txt"),
    "HRZE daily 2 wks, HRZE 2x/wk 6 wks, HR 2x/week 18 wks" = tb_read_init("standard_HRZE2_7wkl_HRZE6_2wkl_HR18_2wkl.txt")
  )
  return(tmp)
}
