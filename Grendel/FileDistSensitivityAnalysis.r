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
npar = 22  # Specifies the number of run directories
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
# Goose sensitivity analysis
# ----
# Distribute the paramter values to run:
nsteps = 11  # the number of intervals to split the parameter in
# Flight cost - pinkfoot
defaultvalue = GetParamValue('GOOSE_FLIGHTCOST_PF', config = cfg)
flightpfval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[1])
GenerateParams('GOOSE_FLIGHTCOST_PF' = flightpfval, write = TRUE, path = wdpath)
# Flight cost - barnnacle
defaultvalue = GetParamValue('GOOSE_FLIGHTCOST_BN', config = cfg)
flightbnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[2])
GenerateParams('GOOSE_FLIGHTCOST_BN' = flightbnval, write = TRUE, path = wdpath)
# Flight cost - greylag
defaultvalue = GetParamValue('GOOSE_FLIGHTCOST_GL', config = cfg)
flightglval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[3])
GenerateParams('GOOSE_FLIGHTCOST_GL' = flightglval, write = TRUE, path = wdpath)


# Edit the bat, ini and cfg files to match the parameters set above:
years = 5  # the number of seasons to run (goose sims run over the year boundary)
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditBat(wd)
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'MAP_WEATHER_FILE', value = 'Vejlerne2013-2014.pre')
}