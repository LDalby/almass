# Distribute work directories
library(R.utils)
library(ralmass)

# Setup the directories
npar = 5  # Number to run in parallel
basedir = 'BaseWD'
basename = 'Hunter'
resultpath = 'd:/almass/Results/GooseManagement/Hunter/HunterTestingAug2015/' 
setwd('d:/almass/WorkDirectories/Hunter/HunterTestingAug2015/')

# Make the scenarios to run
val = seq(1000, 9500, length.out = 5)
val2 = seq(10, 100, length.out = 10)
GenerateParams('BGOOSE_FOLLOWINGLIKELYHOOD (int)' = val, 'GOOSE_ROOSTLEAVINGLIKELYHOOD (int)' = val2, splits = 5)

# Copy the files
for (i in 1:npar) 
{
	copyDirectory(basedir, to = paste0(basename,i))  # Copy the almass work directory
	dir.create(paste0(resultpath, basename, i))  # Set up the result storage
	paramfile = paste0('ParameterValues', i, '.txt')
	file.copy(paramfile, to = paste0(basename, i,'/ParameterValues.txt'))  # Move the parameter settings for each scenario
	file.remove(paramfile)
	file.copy('C:/Users/lada/Git/almass/batchr.r', to = paste0(basename, i,'/batchr.r'), overwrite = TRUE)  # Copy the most recent script
	file.copy('C:/Users/lada/Git/almass/PreRunSetup.r', to = paste0(basename, i,'/PreRunSetup.r'), overwrite = TRUE)  # Copy the most recent script
}
