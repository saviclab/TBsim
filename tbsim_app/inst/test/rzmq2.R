library(devtools)
library(RzmqJobQueue)


init_server(redis.flush=TRUE) # WARNING: it will FLUSH the redis server with index 1
set_init_job( new("job", fun=function() { # some init scripts here
}))
push_job_queue( new("job", fun=base:::mean, argv=list(x = rnorm(100))) )

# start a listener
init_server(redis.flush=FALSE)
wait_worker(path="tcp://*:12345")

library(Rbridgewell)
init_worker("tcp://localhost:12345")
while(TRUE) {
  do_job("tcp://localhost:12345")
  system(sprintf("rm %s/*", tempdir()))
}


library(shiny)
runApp(system.file("shiny", package="RzmqJobQueue"))
