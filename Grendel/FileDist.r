# Copy run directories and setup parameters
# Author: Lars Dalby
# Date: January 2017

library(data.table)
library(ralmass)

# The base directory with all input files except ParameterValues.txt
# The ParameterValues.txt file is written further down.
basedir = '/home/lars/ALMaSS/WorkDirectory'
# The parent directory of all the work directories
pathtodirs = '/home/lars/ALMaSS/tempdirectory'
# Setup the directories
npar = 2  # Specifies the number of run directories
basename = 'WD'  # The prefix to the directories
# Make the directories and copy the files:
for (i in 1:npar) 
{
	dir.create(file.path(pathtodirs, paste0(basename,i)))
  file.copy(from = file.path(basedir, dir(basedir)),
	          to = file.path(pathtodirs, paste0(basename,i)),
	          overwrite = TRUE)
}

dirs = dir(pathtodirs) 
# Edit the scripts to reflect the correct paths:
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	AppendWorkDir(WorkDir = wd, InScript = file.path(wd,'goosebatchr.r'), OutScript = 'batchr.r') 
	AppendWorkDir(WorkDir = wd, InScript = file.path(wd,'PreRunSetup.r'), OutScript = 'PreRunSetup.r') 
}

#------ Below we ditribute the different parameters ------#

# ----
# Goose parameter fitting
# ----
# Distribute the paramter values to run:
nsteps = 11  # the number of intervals to split the parameter in
# Openness
openval = round(seq(0, 100, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[1])
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openval, write = TRUE, path = wdpath)
# Max appetite scaler
appetiteval = seq(1, 7, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[2])
GenerateParams('GOOSE_MAXAPPETITESCALER' = appetiteval, write = TRUE, path = wdpath)

# Edit the bat, ini and cfg files to match the parameters set above:
years = 2  # the number of seasons to run (goose sims run over the year boundary)
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditBat(wd)
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
}
