# Distribute work directories
library(R.utils)
library(ralmass)

# Setup the directories
npar = 9  # Number to run in parallel
basedir = 'BaseWD'
basename = 'WD'
# resultpath = 'e:/almass/Results/GooseManagement/Goose/Results08032016/' 
setwd('u:/Hunter/')
rulesets = c(0:7,10)
# Copy the files
for (i in 1:npar) 
{
	copyDirectory(basedir, to = paste0(basename,rulesets[i]))  # Copy the almass work directory
#	dir.create(paste0(resultpath, basename, i))  # Set up the result storage
}
