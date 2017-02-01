#!/usr/local/bin/r
# Copy run directories and setup parameters
# Author: Lars Dalby
# Date: January 2017

# Set the local R package library (if not done already)
if(!'/home/ldalby/R/packages' %in% .libPaths()) {
	.libPaths('/home/ldalby/R/packages')
}

library(data.table)
library(ralmass)
# Get the slurm job-id (is being passed in from the shell script calling this R script)
args = commandArgs(trailingOnly=TRUE)

# The base directory with all input files except ParameterValues.txt (ParameterValues.txt file is written further down):
basedir = '/home/ldalby/workspace/Goose/RunDirectory'
# The parent directory of all the work directories
pathtodirs = file.path('/scratch', args)
# Setup the directories
npar = 15  # Specifies the number of run directories
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
# Read in the config so we can get the default values: 
# cfg = readLines('/home/ldalby/workspace/Goose/RunDirectory/TIALMaSSConfig.cfg')
#------ Below we ditribute the different parameters ------#

# ----
# Goose parameter fitting
# ----
# Distribute the paramter values to run:
nsteps = 11  # the number of intervals to split the parameter in
# Openness
# defaultvalue = GetParamValue(cfg, 'GOOSE_MINFORAGEOPENNESS')
# openval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
openval = round(seq(0, 100, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[1])
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openval, write = TRUE, path = wdpath)
# Max appetite scaler
# defaultvalue = GetParamValue(cfg, 'GOOSE_MAXAPPETITESCALER')
# appetiteval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
appetiteval = seq(1, 5, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[2])
GenerateParams('GOOSE_MAXAPPETITESCALER' = appetiteval, write = TRUE, path = wdpath)
# Max energy reserve proportion
# defaultvalue = GetParamValue(cfg, 'GOOSE_MAXENERGYRESERVEPROPORTION')
# energyval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
energyval = seq(0.15, 0.25, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[3])
GenerateParams('GOOSE_MAXENERGYRESERVEPROPORTION' = energyval, write = TRUE, path = wdpath)
# The leaving threshold
# defaultvalue = GetParamValue(cfg, 'GOOSE_LEAVINGTHRESHOLD')
# leavingval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
leavingval = seq(1.0, 1.1, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[4])
GenerateParams('GOOSE_LEAVINGTHRESHOLD' = leavingval, write = TRUE, path = wdpath)
# After dark time
# defaultvalue = GetParamValue(cfg, 'GOOSE_AFTERDARKTIME')
# afterdarkval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
afterdarkval = round(seq(0, 90, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[5])
GenerateParams('GOOSE_AFTERDARKTIME' = afterdarkval, write = TRUE, path = wdpath)
# Min forage decay rate
# defaultvalue = GetParamValue(cfg, 'GOOSE_MINFORAGEDECAYRATE')
# foragedecayval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
foragedecayval = seq(0.001, 1, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[6])
GenerateParams('GOOSE_MINFORAGEDECAYRATE' = foragedecayval, write = TRUE, path = wdpath)
# Goose feeding time
# defaultvalue = GetParamValue(cfg, 'GOOSE_FEEDINGTIME')
# feedingval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
feedingval = seq(0.7, 0.85, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[7])
GenerateParams('GOOSE_FEEDINGTIME' = feedingval, write = TRUE, path = wdpath)
# Roost leaving likelyhood
# defaultvalue = GetParamValue(cfg, 'GOOSE_ROOSTLEAVEDISTSD')
# leavedistsdval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
leavedistsdval = round(seq(0, 30, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[8])
GenerateParams('GOOSE_ROOSTLEAVEDISTSD' = leavedistsdval, write = TRUE, path = wdpath)
# Expected foraging time
# defaultvalue = GetParamValue(cfg, 'GOOSE_MEM_EXPECTEDFORAGINGTIME')
# expectedval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
expectedval = round(seq(10, 300, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[9])
GenerateParams('GOOSE_MEM_EXPECTEDFORAGINGTIME' = expectedval, write = TRUE, path = wdpath)
# Grain decay rate
# defaultvalue = GetParamValue(cfg, 'GOOSE_GRAINDECAYRATE')
# grainval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
grainval = seq(0.985, 1, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[10])
GenerateParams('GOOSE_GRAINDECAYRATE' = grainval, write = TRUE, path = wdpath)
# Memory duration
# defaultvalue = GetParamValue(cfg, 'GOOSE_MEM_MINMEMVALUE')
# memoryval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
memoryval = seq(0, 10, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[11])
GenerateParams('GOOSE_MEM_MINMEMVALUE' = memoryval, write = TRUE, path = wdpath)
# Following likelyhood - Barnacle
# defaultvalue = GetParamValue(cfg, 'BGOOSE_FOLLOWINGLIKELYHOOD')
# followingval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
followingval = round(seq(8000, 10000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[12])
GenerateParams('BGOOSE_FOLLOWINGLIKELYHOOD' = followingval,
               write = TRUE, path = wdpath, expand = FALSE)
# Following likelyhood - Pinkfoot
# defaultvalue = GetParamValue(cfg, 'PFGOOSE_FOLLOWINGLIKELYHOOD')
# followingval1 = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
followingval1 = round(seq(8000, 10000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[13])
GenerateParams('PFGOOSE_FOLLOWINGLIKELYHOOD' = followingval1,
               write = TRUE, path = wdpath, expand = FALSE)
# Following likelyhood - Greylag
# defaultvalue = GetParamValue(cfg, 'GLGOOSE_FOLLOWINGLIKELYHOOD')
# followingval2 = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
followingval2 = round(seq(8000, 10000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[14])
GenerateParams('GLGOOSE_FOLLOWINGLIKELYHOOD' = followingval2,
               write = TRUE, path = wdpath, expand = FALSE)
# Forage distance
# defaultvalue = GetParamValue(cfg, 'GOOSE_FORAGEDIST_GL')
# foragedistval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = 11)
foragedistval = round(seq(1000, 5000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[15])
GenerateParams('GOOSE_FORAGEDIST_GL' = foragedistval, write = TRUE, path = wdpath, expand = FALSE)


# Edit the bat, ini and cfg files to match the parameters set above:
years = 5  # the number of seasons to run (goose sims run over the year boundary)
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditBat(wd)
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'MAP_WEATHER_FILE', value = 'Vejlerne2013-2014.pre')
}
