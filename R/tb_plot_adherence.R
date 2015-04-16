#===========================================================================
# plotAdherence.R
# Adherence profile, used for more advanced adherence tracking
#
# John Fors, UCSF
# Oct 10, 2014
# updates Ron Keizer, 2015
#===========================================================================
#' @export
tb_plot_adherence <- function(info, adh){
  timePeriods <- 1:info$nTime

  mat <- adh
  tmat <- t(adh)

  y <- (1:nrow(tmat))
  x <- (1:ncol(tmat))
  # clear values in initial 180 days before therapy starts

  image(y, x, tmat, xlab="Time (days)",ylab="Patient")
  meanRow <- apply(tmat, 1, mean)
  varRow  <- apply(tmat, 1, var)
  meanAll <- mean(mat[,180:360])

  # distibution of non-adherence events - per event duration, across patients
  tmatRows <- pasteCols(tmat, sep="")
  r.1 <- str_count(tmatRows, "101")
  r.2 <- str_count(tmatRows, "1001")
  r.3 <- str_count(tmatRows, "10001")
  r.4 <- str_count(tmatRows, "100001")
  r.5 <- str_count(tmatRows, "1000001")
  r.6 <- str_count(tmatRows, "10000001")
  r.7 <- str_count(tmatRows, "100000001")
  r.8 <- str_count(tmatRows, "1000000001")
  r.9 <- str_count(tmatRows, "10000000001")
  r.10 <-str_count(tmatRows, "100000000001")
  tmatRows <- cbind(r.1, r.2, r.3, r.4, r.5, r.6, r.7, r.8, r.9, r.10)
  tmatSum <- apply(tmatRows, 2, mean)
  tmatQuart <- apply(tmatRows, 2, quantile)
  dev.new()
  bp <- barplot(tmatSum, ylim=c(0,1.5*max(tmatQuart[4,])),
                main="Number of non-adherence events per duration \n (average and quartiles across patients)",
                names.arg=c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10"),
                xlab="Days of Non-adherence")

  segments(bp, tmatQuart[2,], bp, tmatQuart[4,], lwd=2)
  segments(bp - 0.1, tmatQuart[2,], bp + 0.1, tmatQuart[2,], lwd=2)
  segments(bp - 0.1, tmatQuart[4,], bp + 0.1, tmatQuart[4,], lwd=2)

  # distribution of non-adherence, total non-adherence time per patients
  adhTot <- (600 - apply(mat, 1, sum))
  dev.new()
  br1 = c(0,5,10,15,20,25,30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95, 100)

  H1 <- hist(adhTot)
  barplot(H1$counts/info$nPatients, main="Non-adherent days per patient", ylim=c(0,1.5*max(H1$counts/info$nPatients)),
          names.arg=round(H1$mids, digits=1), xlab="Sum of non-adherent days", ylab="Probability")

  # distribution of non-adherence, total count occurences non-adherence per patients
  adhCount <- apply (tmatRows, 1, sum)
  dev.new()
  br2 = c(0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30)

  H2 <- hist(adhCount)
  barplot(H2$counts/info$nPatients, main="Non-adherence events per patient", ylim=c(0,1.5*max(H2$counts/info$nPatients)),
          names.arg=round(H2$mids, digits=1), xlab="Count of non-adherence events", ylab="Probability")
}
