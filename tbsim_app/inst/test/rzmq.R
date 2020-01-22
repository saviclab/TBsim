library(rzmq)

remote.exec <- function(socket,fun,...) {
  send.socket(socket,data=list(fun=fun,args=list(...)))
  receive.socket(socket)
}

substitute(expr)
context = init.context()
socket = init.socket(context,"ZMQ_REQ")
connect.socket(socket,"tcp://localhost:5555")

ans <- remote.exec(socket, sin, 1:100000)
