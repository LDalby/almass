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
npar = 18  # Specifies the number of run directories
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
cfg = readLines('/home/ldalby/workspace/Goose/RunDirectory/TIALMaSSConfig.cfg')
#------ Below we ditribute the different parameters ------#

# ----
# Goose parameter fitting
# ----
# Distribute the paramter values to run:
nsteps = 11  # the number of intervals to split the parameter in
# Openness
defaultvalue = GetParamValue('GOOSE_MINFORAGEOPENNESS', config = cfg)
openval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
openval = openval[openval >= 0]
# openval = round(seq(0, 100, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[1])
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openval, write = TRUE, path = wdpath)
# Max appetite scaler
defaultvalue = GetParamValue('GOOSE_MAXAPPETITESCALER', config = cfg)
appetiteval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
appetiteval = appetiteval[appetiteval >= 1]
# appetiteval = seq(1, 5, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[2])
GenerateParams('GOOSE_MAXAPPETITESCALER' = appetiteval, write = TRUE, path = wdpath)
# Max energy reserve proportion
defaultvalue = GetParamValue('GOOSE_MAXENERGYRESERVEPROPORTION', config = cfg)
energyval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
energyval = energyval[energyval >= 0 & energyval <= 1]
# energyval = seq(0.15, 0.25, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[3])
GenerateParams('GOOSE_MAXENERGYRESERVEPROPORTION' = energyval, write = TRUE, path = wdpath)
# The leaving threshold
# +-25% not possible for this parameter. Anything over 1.1 and the birds leave immediately in the autumn,
# anything over 1.22 and the birds leave immediately both autumn and spring.
leavingval = seq(1.0, 1.2, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[4])
GenerateParams('GOOSE_LEAVINGTHRESHOLD' = leavingval, write = TRUE, path = wdpath)
# After dark time
defaultvalue = GetParamValue('GOOSE_AFTERDARKTIME', config = cfg)
afterdarkval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
afterdarkval = afterdarkval[afterdarkval >= 0]
# afterdarkval = round(seq(0, 90, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[5])
GenerateParams('GOOSE_AFTERDARKTIME' = afterdarkval, write = TRUE, path = wdpath)
# Min forage decay rate
defaultvalue = GetParamValue('GOOSE_MINFORAGEDECAYRATE', config = cfg)
foragedecayval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
foragedecayval = foragedecayval[foragedecayval > 0 & foragedecayval <= 1]
# foragedecayval = seq(0.001, 1, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[6])
GenerateParams('GOOSE_MINFORAGEDECAYRATE' = foragedecayval, write = TRUE, path = wdpath)
# Goose feeding time
defaultvalue = GetParamValue('GOOSE_FEEDINGTIME', config = cfg)
feedingval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
feedingval = feedingval[feedingval >= 0 & feedingval <= 1]
# feedingval = seq(0.7, 0.85, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[7])
GenerateParams('GOOSE_FEEDINGTIME' = feedingval, write = TRUE, path = wdpath)
# Roost leaving likelyhood
defaultvalue = GetParamValue('GOOSE_ROOSTLEAVEDISTSD', config = cfg)
leavedistsdval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
leavedistsdval = leavedistsdval[leavedistsdval >= 0]
# leavedistsdval = round(seq(0, 30, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[8])
GenerateParams('GOOSE_ROOSTLEAVEDISTSD' = leavedistsdval, write = TRUE, path = wdpath)
# Expected foraging time
defaultvalue = GetParamValue('GOOSE_MEM_EXPECTEDFORAGINGTIME', config = cfg)
expectedval = round(seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps))
expectedval = expectedval[expectedval >= 20]
# expectedval = round(seq(20, 300, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[9])
GenerateParams('GOOSE_MEM_EXPECTEDFORAGINGTIME' = expectedval, write = TRUE, path = wdpath)
# Grain decay rate
defaultvalue = GetParamValue('GOOSE_GRAINDECAYRATE', config = cfg)
grainval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
grainval = grainval[grainval <= 1 & grainval >= 0]
# grainval = seq(0.985, 1, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[10])
GenerateParams('GOOSE_GRAINDECAYRATE' = grainval, write = TRUE, path = wdpath)
# Memory duration
# +-25% doesn't really make sense here.
# defaultvalue = GetParamValue('GOOSE_MEM_MINMEMVALUE', config = cfg)
# memoryval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
# memoryval = round(memoryval[memoryval >= 0])
memoryval = round(seq(0, 10, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[11])
GenerateParams('GOOSE_MEM_MINMEMVALUE' = memoryval, write = TRUE, path = wdpath)
# Following likelyhood
rangemax = 10000
# Following likelyhood - Barnacle
defaultvalue = GetParamValue('GOOSE_FOLLOWINGLIKELYHOOD_BN', config = cfg)
followingval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
followingval = round(c(followingval[followingval < rangemax], rangemax))
# followingval = round(seq(8000, 10000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[12])
GenerateParams('GOOSE_FOLLOWINGLIKELYHOOD_BN' = followingval,
               write = TRUE, path = wdpath, expand = FALSE)
# Following likelyhood - Pinkfoot
defaultvalue = GetParamValue('GOOSE_FOLLOWINGLIKELYHOOD_PF', config = cfg)
followingval1 = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
followingval1 = round(c(followingval1[followingval1 < rangemax], rangemax))
# followingval1 = round(seq(8000, 10000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[13])
GenerateParams('GOOSE_FOLLOWINGLIKELYHOOD_PF' = followingval1,
               write = TRUE, path = wdpath, expand = FALSE)
# Following likelyhood - Greylag
defaultvalue = GetParamValue('GOOSE_FOLLOWINGLIKELYHOOD_GL', config = cfg)
followingval2 = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
followingval2 = round(c(followingval2[followingval2 < rangemax], rangemax))
# followingval2 = round(seq(8000, 10000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[14])
GenerateParams('GOOSE_FOLLOWINGLIKELYHOOD_GL' = followingval2,
               write = TRUE, path = wdpath, expand = FALSE)
# Forage distance
defaultvalue = GetParamValue('GOOSE_FORAGEDIST_GL', config = cfg)
foragedistval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
foragedistval = foragedistval[foragedistval >= 0]
# foragedistval = round(seq(1000, 5000, length.out = nsteps))
wdpath = file.path(pathtodirs, dirs[15])
GenerateParams('GOOSE_FORAGEDIST_GL' = foragedistval, write = TRUE, path = wdpath, expand = FALSE)

# Field forage distance - pinkfoot
defaultvalue = GetParamValue('GOOSE_FIELDFORAGEDIST_PF', config = cfg)
fieldforagedistval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
fieldforagedistval = fieldforagedistval[fieldforagedistval >= 0]
wdpath = file.path(pathtodirs, dirs[16])
GenerateParams('GOOSE_FIELDFORAGEDIST_PF' = fieldforagedistval, write = TRUE, path = wdpath, expand = FALSE)

# Field forage distance - greylag
defaultvalue = GetParamValue('GOOSE_FIELDFORAGEDIST_GL', config = cfg)
fieldforagedistval1 = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
fieldforagedistval1 = fieldforagedistval1[fieldforagedistval1 >= 0]
wdpath = file.path(pathtodirs, dirs[17])
GenerateParams('GOOSE_FIELDFORAGEDIST_GL' = fieldforagedistval1, write = TRUE, path = wdpath, expand = FALSE)

# Field forage distance - barnacle
defaultvalue = GetParamValue('GOOSE_FIELDFORAGEDIST_BN', config = cfg)
fieldforagedistval2 = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
fieldforagedistval2 = fieldforagedistval2[fieldforagedistval2 >= 0]
wdpath = file.path(pathtodirs, dirs[18])
GenerateParams('GOOSE_FIELDFORAGEDIST_BN' = fieldforagedistval2, write = TRUE, path = wdpath, expand = FALSE)


# Edit the bat, ini and cfg files to match the parameters set above:
years = 5  # the number of seasons to run (goose sims run over the year boundary)
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditBat(wd)
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 134+years*365)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'MAP_WEATHER_FILE', value = 'Vejlerne2013-2014.pre')
}
