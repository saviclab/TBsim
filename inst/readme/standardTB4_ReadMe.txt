<name>Standard of care TB : Description of drug therapy
<description>2EHRZ/4HR	  : Sub title, usually used to describe dose pattern
<drug>RIF|600|0|182|1|	  : Each <drug> entry is used for a separate drug
<drug>INH|300|0|182|1|	  : drug name | dose | start day | end day | interval 
<drug>PZA|1500|0|61|1|	  : for example, interval=1 is daily dosing
<drug>EMB|1200|0|61|1|    :              interval=7 is weekly dosing
						  : 1) drug name must be included in TBinit file
						  : 2) therapy 'name' and 'description' are purely
						  :    descriptive
						  : 3) any number of lines can be added
						  : 4) same 'drug' can be repeated multiple times
						  :    and all dose lines are added up
						  : 5) dose starts on 'start day'
						  : 6) dose ends the day before 'end day'
						  : 7) the file name of the therapy must be
						  :    included in the TBinit.txt file