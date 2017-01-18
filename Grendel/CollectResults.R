# Collect results from parameter fitting
# Author: Lars Dalby
# Date: 17 Jan 2017
# Short script to combine the results form mulitple runs into one file and 
# write that to a safe place on Grendel.

# Set the local R package library (if not done already)
if(!'/home/ldalby/R/packages' %in% .libPaths()) {
	.libPaths('/home/ldalby/R/packages')
}

library(data.table)
# Get the slurm job-id (is being passed in from the shell script calling this R script)
args = commandArgs(trailingOnly=TRUE)

# The parent directory of all the work directories
pathtodirs = file.path('/scratch', args)
filename = 'ParameterFittingResults.txt'
npar = 13  # Specifies the number of run directories that was being used
basename = 'WD'  # The prefix to the directories
# Read all the files into a list
reslist = vector('list', npar)
for (i in 1:npar) 
{
	wd = paste0(basename,i)
	pathtofile = file.path(pathtodirs, wd)
	tmp = fread(file.path(pathtofile, filename))
	tmp[, WD:=wd]
	reslist[[i]] = tmp
}
allres = rbindlist(reslist)
fwrite(allres, file = '/home/ldalby/workspace/Goose/ParamFitting/Results')
