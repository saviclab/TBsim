plotMultiBactRes <- function(nDrugs, file1, file2, file3, file4, mainTitle, 
							 subTitle, drugStart, timePeriods, d1, d2, d3, d4)
{
	if (nDrugs>0){
		y1	<- read.table(paste(folder, file1, sep=""), header=FALSE,sep="\t", skip=1)
		y1  <- makeDF(y1, "y1m")
	}
	if (nDrugs>1){
		y2	<- read.table(paste(folder, file2, sep=""), header=FALSE,sep="\t", skip=1)
		y2  <- makeDF(y2, "y2m")
	}
	if (nDrugs>2){
		y3	<- read.table(paste(folder, file3, sep=""), header=FALSE,sep="\t", skip=1)
		y3  <- makeDF(y3, "y3m")
	}
	if (nDrugs>3){
		y4	<- read.table(paste(folder, file4, sep=""), header=FALSE,sep="\t", skip=1)
		y4  <- makeDF(y4, "y4m")
	}

	if (nDrugs==1){
		yset <- data.frame(timePeriods, y1$y1m)
		plotBactRes(yset, c("time", d1), mainTitle, subTitle, "CFU/mL", drugStart)
	}
	if (nDrugs==2){
		yset <- data.frame(timePeriods, y1$y1m, y2$y2m)
		plotBactRes(yset, c("time", d1, d2), mainTitle, subTitle, "CFU/mL", drugStart)
	}
	if (nDrugs==3){
		yset <- data.frame(timePeriods, y1$y1m, y2$y2m, y3$y3m)
		plotBactRes(yset, c("time", d1, d2, d3), mainTitle, subTitle, "CFU/mL", drugStart)
	}
	if (nDrugs==4){
		yset <- data.frame(timePeriods, y1$y1m, y2$y2m, y3$y3m, y4$y4m)
		plotBactRes(yset, c("time", d1, d2, d3, d4), mainTitle, subTitle, "CFU/mL", drugStart)
	}
}