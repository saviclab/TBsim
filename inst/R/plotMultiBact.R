plotMultiBact <- function(file1, file2, file3, mainTitle, subTitle, drugStart, timePeriods)
{
	y1 <- read.table(paste(folder, file1, sep=""), header=FALSE,sep="\t", skip=1)
	y1  <- makeDF(y1, "y1m")
	
	y2 <- read.table(paste(folder, file2, sep=""), header=FALSE,sep="\t", skip=1)
	y2  <- makeDF(y2, "y2m")
	
	y3 <- read.table(paste(folder, file3, sep=""), header=FALSE,sep="\t", skip=1)
	y3  <- makeDF(y3, "y3m")
	
	yset <- data.frame(timePeriods, y1$y1m, y2$y2m, y3$y3m)
	dev.new()
	plotBact(yset, c("time", "Quartile_3", "Median", "Quartile_1"),
		     mainTitle, subTitle, "Cells/mL", drugStart)
}