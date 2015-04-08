makeDFQ <- function(yin, name1, nameq1, nameq3)
{
	yint	<- t(yin[1:(length(yin)-1)])					# remove last entry, and transpose
	yinm	<- apply(100*yint, 1, mean)						# calculate mean
	yinq	<- apply(100*yint, 1, quantile, rm.na=TRUE)		# calculate quartiles 1 and 3
    yout	<- data.frame(yint, yinm, yinq[2,], yinq[4,])	# assemble output data
	
	colnames(yout)[ncol(yout)-2] <- name1					# set column name for added column
	colnames(yout)[ncol(yout)-1] <- nameq1					# set column name for added column
	colnames(yout)[ncol(yout)-0] <- nameq3					# set column name for added column
	
	return(yout)
}