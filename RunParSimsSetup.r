# Distribute work directories
library(R.utils)
library(ralmass)

# Setup the directories
npar = 13  # Number to run in parallel
basedir = 'e:/almass/WorkDirectories/BaseWD'
basename = 'WD'
# resultpath = 'e:/almass/Results/GooseManagement/Goose/Results08032016/' 
setwd('e:/almass/WorkDirectories/Goose/')
# Copy the files
for (i in 1:npar) 
{
	copyDirectory(basedir, to = paste0(basename,i))  # Copy the almass work directory
#	dir.create(paste0(resultpath, basename, i))  # Set up the result storage
}
