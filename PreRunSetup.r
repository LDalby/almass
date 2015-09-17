# PreRunSetup
# Script to copy lines to TIALMaSSConfig pre run
# Author: Lars Dalby
# Date: 23 June 2015

# Setup work directory (done automatically when distributing the files, therefore blank):

# To get the line number in the parameter list in multi parameter scenarios we make a vector of line numbers for the
# first of the parameters in each run (this approach is also used for single parameter scenarios):
paramvals = fread('ParameterValues.txt')  # To figure out how many runs we have
params = nrow(unique(paramvals[, 1, with = FALSE])) # The number of paramters being modified per run 
runs = nrow(paramvals)/params
lineno = seq(1, runs*params, params)

# This is needed again as we this time read it in as single lines (and not as a data.table)
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
