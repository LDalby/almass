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

ScipenDefault = getOption('scipen')
options(scipen = 99)
# The base directory with all input files except ParameterValues.txt (ParameterValues.txt file is written further down):
basedir = '/home/ldalby/workspace/Goose/RunDirectory'
# The parent directory of all the work directories
pathtodirs = file.path('/scratch', args)
# Setup the directories
npar = 26  # Specifies the number of run directories
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
# Flight cost - barnacle
defaultvalue = GetParamValue('GOOSE_FLIGHTCOST_BN', config = cfg)
flightbnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[2])
GenerateParams('GOOSE_FLIGHTCOST_BN' = flightbnval, write = TRUE, path = wdpath)
# Flight cost - greylag
defaultvalue = GetParamValue('GOOSE_FLIGHTCOST_GL', config = cfg)
flightglval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[3])
GenerateParams('GOOSE_FLIGHTCOST_GL' = flightglval, write = TRUE, path = wdpath)
# Weight - pinkfoot
defaultvalue = GetParamValue('GOOSE_PINKFOOTWEIGHT', config = cfg)
weightpfval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[4])
GenerateParams('GOOSE_PINKFOOTWEIGHT' = weightpfval, write = TRUE, path = wdpath)
# Weight - barnacle
defaultvalue = GetParamValue('GOOSE_BARNACLEWEIGHT', config = cfg)
weightbnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[5])
GenerateParams('GOOSE_BARNACLEWEIGHT' = weightbnval, write = TRUE, path = wdpath)
# Weight - greylag
defaultvalue = GetParamValue('GOOSE_GREYLAGWEIGHT', config = cfg)
weightglval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[6])
GenerateParams('GOOSE_GREYLAGWEIGHT' = weightglval, write = TRUE, path = wdpath)
# Metabolic conversion
defaultvalue = GetParamValue('GOOSE_METABOLICCONVCOSTS', config = cfg)
metabolicval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[7])
GenerateParams('GOOSE_METABOLICCONVCOSTS' = metabolicval, write = TRUE, path = wdpath)
# Timed counts
# Special case - interval capped at 1. Doesn't make sense to count before the geese has left the roost.
defaultvalue = GetParamValue('GOOSE_TIMEDCOUNTS', config = cfg)
timedcountsval = seq(1,11, length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[8])
GenerateParams('GOOSE_TIMEDCOUNTS' = timedcountsval, write = TRUE, path = wdpath)
# Field forage distance - pinkfoot
defaultvalue = GetParamValue('GOOSE_FIELDFORAGEDIST_PF', config = cfg)
fieldforagepfval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[9])
GenerateParams('GOOSE_FIELDFORAGEDIST_PF' = fieldforagepfval, write = TRUE, path = wdpath)
# Field forage distance - barnacle
defaultvalue = GetParamValue('GOOSE_FIELDFORAGEDIST_BN', config = cfg)
fieldforagebnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[10])
GenerateParams('GOOSE_FIELDFORAGEDIST_BN' = fieldforagebnval, write = TRUE, path = wdpath)
# Field forage distance - greylag
defaultvalue = GetParamValue('GOOSE_FIELDFORAGEDIST_GL', config = cfg)
fieldforageglval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[11])
GenerateParams('GOOSE_FIELDFORAGEDIST_GL' = fieldforageglval, write = TRUE, path = wdpath)
# BMR constant A
defaultvalue = GetParamValue('GOOSE_BMRCONSTANTA', config = cfg)
bmrconstantaval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[12])
GenerateParams('GOOSE_BMRCONSTANTA' = bmrconstantaval, write = TRUE, path = wdpath)
# BMR constant B
defaultvalue = GetParamValue('GOOSE_BMRCONSTANTB', config = cfg)
bmrconstantbval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[13])
GenerateParams('GOOSE_BMRCONSTANTB' = bmrconstantbval, write = TRUE, path = wdpath)
# Thermal constant A - pinkfoot
defaultvalue = GetParamValue('GOOSE_THERMALCONSTANTA_PF', config = cfg)
thermalconstantapfval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[14])
GenerateParams('GOOSE_THERMALCONSTANTA_PF' = thermalconstantapfval, write = TRUE, path = wdpath)
# Thermal constant A - barnacle
defaultvalue = GetParamValue('GOOSE_THERMALCONSTANTA_BN', config = cfg)
thermalconstantabnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[15])
GenerateParams('GOOSE_THERMALCONSTANTA_BN' = thermalconstantabnval, write = TRUE, path = wdpath)
# Thermal constant A - greylag
defaultvalue = GetParamValue('GOOSE_THERMALCONSTANTA_GL', config = cfg)
thermalconstantaglval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[16])
GenerateParams('GOOSE_THERMALCONSTANTA_GL' = thermalconstantaglval, write = TRUE, path = wdpath)
# Thermal constant B
defaultvalue = GetParamValue('GOOSE_THERMALCONSTANTB', config = cfg)
thermalconstantbval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[17])
GenerateParams('GOOSE_THERMALCONSTANTB' = thermalconstantbval, write = TRUE, path = wdpath)
# Energycontent of fat
defaultvalue = GetParamValue('GOOSE_ENERGYCONTENTOFFAT', config = cfg)
energycontentoffatval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[18])
GenerateParams('GOOSE_ENERGYCONTENTOFFAT' = energycontentoffatval, write = TRUE, path = wdpath)
# Young proportion - pinkfoot
defaultvalue = GetParamValue('GOOSE_PF_YOUNG_PROPORTION', config = cfg)
youngproportionpfval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[19])
GenerateParams('GOOSE_PF_YOUNG_PROPORTION' = youngproportionpfval, write = TRUE, path = wdpath)
# Young proportion - barnacle
defaultvalue = GetParamValue('GOOSE_BN_YOUNG_PROPORTION', config = cfg)
youngproportionbnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[20])
GenerateParams('GOOSE_BN_YOUNG_PROPORTION' = youngproportionbnval, write = TRUE, path = wdpath)
# Young proportion - greylag
defaultvalue = GetParamValue('GOOSE_GL_YOUNG_PROPORTION', config = cfg)
youngproportionbnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[21])
GenerateParams('GOOSE_GL_YOUNG_PROPORTION' = youngproportionbnval, write = TRUE, path = wdpath)
# Roost leave dist mean
defaultvalue = GetParamValue('GOOSE_ROOSTLEAVEDISTMEAN', config = cfg)
roostdistleavemeanval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
wdpath = file.path(pathtodirs, dirs[22])
GenerateParams('GOOSE_ROOSTLEAVEDISTMEAN' = roostdistleavemeanval, write = TRUE, path = wdpath)
# Roost change chance - pinkfoot
defaultvalue = GetParamValue('GOOSE_ROOSTCHANGECHANCE_PF', config = cfg)
roostchangepfval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
roostchangepfval = roostchangepfval[roostchangepfval >= 0]
wdpath = file.path(pathtodirs, dirs[22])
GenerateParams('GOOSE_ROOSTCHANGECHANCE_PF' = roostchangepfval, write = TRUE, path = wdpath)
# Roost change chance - barnacle
defaultvalue = GetParamValue('GOOSE_ROOSTCHANGECHANCE_BN', config = cfg)
roostchangebnval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
roostchangebnval = roostchangebnval[roostchangebnval >= 0]
wdpath = file.path(pathtodirs, dirs[22])
GenerateParams('GOOSE_ROOSTCHANGECHANCE_BN' = roostchangebnval, write = TRUE, path = wdpath)
# Roost change chance - greylag
defaultvalue = GetParamValue('GOOSE_ROOSTCHANGECHANCE_GL', config = cfg)
roostchangeglval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
roostchangeglval = roostchangeglval[roostchangeglval >= 0]
wdpath = file.path(pathtodirs, dirs[22])
GenerateParams('GOOSE_ROOSTCHANGECHANCE_GL' = roostchangeglval, write = TRUE, path = wdpath)
# Initial energy reserve proportion
defaultvalue = GetParamValue('GOOSE_INITIALENERGYRESERVEPROPORTION', config = cfg)
initialenergyval = seq(defaultvalue-(defaultvalue*.25), defaultvalue+(defaultvalue*.25), length.out = nsteps)
initialenergyval = initialenergyval[initialenergyval >= 1]
wdpath = file.path(pathtodirs, dirs[22])
GenerateParams('GOOSE_INITIALENERGYRESERVEPROPORTION' = initialenergyval, write = TRUE, path = wdpath)


# Edit the bat, ini and cfg files to match the parameters set above:
years = 5  # the number of seasons to run (goose sims run over the year boundary)
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditBat(wd)
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'MAP_WEATHER_FILE', value = 'Vejlerne2013-2014.pre')
}

options(scipen = ScipenDefault)
