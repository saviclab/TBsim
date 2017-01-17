save_output_to_s3 <- function(
  s3 =  NULL,
  bucket = "tbsim-shiny",
  folder
  ) {
  if(!is.null(s3)) {
    Sys.setenv("AWS_ACCESS_KEY_ID" = s3$key_id,
               "AWS_SECRET_ACCESS_KEY" = s3$key,
               "AWS_DEFAULT_REGION" = s3$region)
    # get_bucket(s3$bucket)
  }
  ## tar files
  tmp <- stringr::str_split(folder, "/")[[1]]
  tmp <- tmp[tmp!='']
  id <- tail(tmp,1)
  base_folder <- paste(c("/", tmp[-length(tmp)]), collapse="/")
  out <- system2("tar", paste0("-zcvf ", base_folder, "/", id, ".tar.gz", " ",  folder))
  res <- put_object(file = paste0(base_folder, "/", id, ".tar.gz"), bucket = bucket)
  if(res) {
    cat("Data saved to S3.")
  } else {
    cat("Something went wrong saving data to S3.")
  }
}
