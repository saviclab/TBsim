library(jobqueue)

Q = Q.make()

# push computation job to queue
Q.push(Q, sin(1:1e6) )
Q.push(Q, sin(1:1e6) )
Q.push(Q, sin(1:1e6) )
Q.push(Q, sin(1:1e6) )
Q.push(Q, sin(1:1e6) )
Q.isready(Q)
Q.collect.all(Q)

# perform other computations here while the job is computed 
# in the background
a <- sin(1:1e6)

# retrieve result from job queue

# load package in the queue
Q.push(Q, library(stats4), mute=TRUE)

# set variables in the queue - you can also use Q.push or Q.sync
Q.assign(Q, "a", 5)

# close the queue and free its resources
Q.close(Q)