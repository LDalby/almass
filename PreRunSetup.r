# PreRunSetup
# Script to copy lines to TIALMaSSConfig pre run
# Author: Lars Dalby
# Date: 25 Sep 2015

library(data.table)

# Setup work directory (done automatically when distributing the files, therefore blank):

# To get the line number in the parameter list in multi parameter scenarios we make a vector of line numbers for the
# first of the parameters in each run (this approach is also used for single parameter scenarios):
paramvals = fread('ParameterValues.txt')  # To figure out how many runs we have
numberofparams = nrow(unique(paramvals[, 1, with = FALSE])) # The number of paramters being modified per run 
runs = nrow(paramvals)/numberofparams
lineno = seq(1, runs*numberofparams, numberofparams)

# This is needed again as we this time read it in as single lines (and not as a data.table)
params = readLines('ParameterValues.txt')

counter = as.numeric(readLines('counter.txt'))
if(counter == 1)
{
	write(paste0('#----------- Start auto change ', Sys.time(), ' ----------#'), 'TIALMaSSConfig.cfg', append = TRUE)
}
for (i in 1:numberofparams) 
{
	TheParam = params[lineno[counter]+(i-1)]
	write(TheParam, 'TIALMaSSConfig.cfg', append = TRUE)
}

if(counter == runs)
{
	write(paste0('#----------- End auto change ', Sys.time(), ' -----------#'), 'TIALMaSSConfig.cfg', append = TRUE)
}
