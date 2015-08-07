# PreRunSetup
# Script to copy lines to TIALMaSSConfig pre run
# Author: Lars Dalby
# Date: 23 June 2015

setwd('d:/almass/WorkDirectories/Hunter/HunterTestingAug2015/WD0/')  # The run directory

# To get the line number in the parameter list in multi parameter scenarios we make a vector of line numbers for the
# first of the parameters in each run (this approach is also used for single parameter scenarios):
runs = 5  # The number of runs
numberofparams = 1  # The number of paramters being modified per run 
lineno = seq(1, runs*numberofparams, numberofparams)

params = readLines('ParameterValues.txt')

counter = as.numeric(readLines('counter.txt'))
if(counter == 1)
{
	write('#---------- Start auto change ----------#', 'TIALMaSSConfig.cfg', append = TRUE)
}
write(params[lineno[counter]], 'TIALMaSSConfig.cfg', append = TRUE)
if(numberofparams > 1)
{
	for (i in 2:numberofparams) 
	{
		write(params[lineno[counter]+1], 'TIALMaSSConfig.cfg', append = TRUE)
	}
}
if(counter == runs)
{
	write('#----------- End auto change -----------#', 'TIALMaSSConfig.cfg', append = TRUE)
}