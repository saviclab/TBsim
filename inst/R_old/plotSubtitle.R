########################################################
# Add subtitle to plots, with data file information
# Dec 23, 2012 by John Fors
########################################################

plotSubtitle <- function(nPatients, doseText, rText, gText, iText) 
{
	title(paste(nPatients, " pts; ",
		        doseText,  "; ",
 				rText,     "; ",
				gText,     "; ",
				iText,
				sep=""), line=1, cex.main = 0.8, font.main=1)
}