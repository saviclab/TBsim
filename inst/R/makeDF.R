makeDF <- function(yin, name)
{
	yint	<- t(yin[1:(length(yin)-1)])	# remove last entry, and transpose
	yinm	<- apply(yint, 1, mean)			# calculate mean of all columns
    yout	<- data.frame(yint, yinm)		# assemble output data
	colnames(yout)[ncol(yout)] <- name		# set column name for added column
	
	return(yout)
}