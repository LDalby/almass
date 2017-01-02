# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
# Grendel version
library(data.table)
library(ralmass)

# The base directory with all input files except ParameterValues.txt
basedir = "/home/lars/ALMaSS/WorkDirectory"
# List the parent directory of all the work directories
pathtodirs = '/home/lars/ALMaSS/tempdirectory'
# Setup the directories
npar = 2
basename = 'WD'  # The prefix to the directories
# Copy the files
for (i in 1:npar) 
{
	dir.create(file.path(pathtodirs, paste0(basename,i)))
  file.copy(from = file.path(basedir, dir(basedir)),
	          to = file.path(pathtodirs, paste0(basename,i)),
	          overwrite = TRUE)
}

dirs = dir(pathtodirs) 

for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	AppendWorkDir(WorkDir = wd, InScript = 'goosebatchr.r', OutScript = 'batchr.r') 
	AppendWorkDir(WorkDir = wd, InScript = 'PreRunSetup.r', OutScript = 'PreRunSetup.r') 
}

#------ Below we ditribute the different parameters ------#

# ----
# Goose parameter fitting
# ----
nsteps = 11
# Distribute the paramter values to run:
# Openness
openval = round(seq(0, 100, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[1])
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openval, write = TRUE, path = wdpath)
# Max appetite scaler
appetiteval = seq(1, 7, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[2])
GenerateParams('GOOSE_MAXAPPETITESCALER' = appetiteval, write = TRUE, path = wdpath)

# Edit the bat, ini and cfg files to match the parameters set above:
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditBat(wd)
	years = 2
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
}
