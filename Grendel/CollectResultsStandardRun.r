# Collect results from standard runs
# Author: Lars Dalby
# Date: 14 Feb 2017
# Collect the result files from a standard run and 
# write them to a safe place on Grendel.

# Set the local R package library (if not done already)
if(!'/home/ldalby/R/packages' %in% .libPaths()) {
	.libPaths('/home/ldalby/R/packages')
}

library(data.table)
# Get the slurm job-id (is being passed in from the shell script calling this R script)
args = commandArgs(trailingOnly=TRUE)

# The parent directory of all the work directories
pathtodirs = file.path('/scratch', args)
filenames = c('GooseFieldForageData.txt', 'GoosePopulationData.txt', 'GooseWeightStats.txt')
destdir = '/home/ldalby/workspace/Goose/StandardRun/Output/'  # Files are copied here

npar = 2  # Specifies the number of run directories that was being used
basename = 'WD'  # The prefix to the directories

# Copy all the files
for (i in 1:npar) 
{
	wd = paste0(basename,i)
	pathtofiles = file.path(pathtodirs, wd)
	dir.create(file.path(destdir,wd))
	filenames = file.path(pathtofiles, filenames)
	sapply(filenames, FUN = file.copy, to = file.path(destdir, wd))
}
