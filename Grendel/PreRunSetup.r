#!/usr/local/bin/r
# PreRunSetup
# Script to copy lines to TIALMaSSConfig pre run
# Author: Lars Dalby
# Date: 25 Sep 2015

# Set the local R package library (if not done already)
if(!'/home/ldalby/R/packages' %in% .libPaths()) {
	.libPaths('/home/ldalby/R/packages')
}

library(data.table)
library(ralmass)
# Setup work directory (done automatically when distributing the files, therefore blank):

# To get the line number in the parameter list in multi parameter scenarios we make a vector of line numbers for the
# first of the parameters in each run (this approach is also used for single parameter scenarios):
paramvals = fread('ParameterValues.txt')  # To figure out how many runs we have
numberofparams = length(paramvals[,unique(V1)]) # The number of paramters being modified per run 
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
	stri = GetParamString(TheParam)
	specialhunt = c('HuntingDays', 'WeekdayHunterChance', 'GooseLookChance', 'Efficiency')
	if(stri %in% specialhunt) {
		theval = GetParamValue(param = TheParam)
		hhlpath = 'Hunter_Hunting_Locations.txt'
		file = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Hunter/746_VejlerneHuntersDiffGLC.txt'
		if(stri %in% c('HuntingDays', 'Efficiency')) {
		EditHunterInput(file = file, hhlpath = hhlpath, parameter = stri, change = theval, huntersubset = 'all')
		}
		if(stri %in% c('WeekdayHunterChance', 'GooseLookChance')) {
		EditHunterInput(file = file, hhlpath = hhlpath, parameter = stri, change = theval, huntersubset = 'all')
	}
	}
	if(!stri %in% specialhunt) 
	{
		write(TheParam, 'TIALMaSSConfig.cfg', append = TRUE)
	}
}

if(counter == runs)
{
	write(paste0('#----------- End auto change ', Sys.time(), ' -----------#'), 'TIALMaSSConfig.cfg', append = TRUE)
}
