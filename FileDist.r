# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
library(R.utils)
library(ralmass)

# List the parent directory of all the work directories
pathtodirs = 'u:/Hunter/'
dirs = dir(pathtodirs)[-grep('BaseWD',dir(pathtodirs))]  # For this to work you can't have a bunch of crap sitting in
						# in pathtodirs. Only the subdirectories

# A common use for this would be to copy a fresh exe along with
# resetting the counter, clearing the error file and copying
# the batchr and prerunsetup file.
file1 = 'o:/ST_GooseProject/ALMaSS/Executables/ALMaSS_CmdLine.exe' 
file2 = 'C:/Users/lada/git/almass/counter.txt' 
file3 = 'C:/Users/lada/git/almass/hunterbatchr.r'	
file4 = 'C:/Users/lada/git/almass/ErrorFile.txt'
file5 = 'C:/Users/lada/git/almass/PreRunSetup.r'
# Species specific things:
file6 = 'C:/Users/lada/git/ALMaSS_inputs/GooseManagement/Vejlerne/Hunter/HunterHomeLocations.txt'
file7 = 'o:/ST_GooseProject/ALMaSS/HunterModelTesting/SurveyResults/HunterSurveyResultsDensity.csv'
file8 = 'o:/ST_GooseProject/ALMaSS/HunterModelTesting/SurveyResults/HunterSurveyResultsDistanceJuly2015.txt'
file9 = 'o:/ST_GooseProject/ALMaSS/HunterModelTesting/SurveyResults/HunterSurveyResultsFarm.csv'

filestodist = c(file1, file2, file3, file4, file5, file6, file7, file8, file9)

# We overwrite, so be sure you actually want to do this!
for (i in seq_along(dirs)) {
	wd = paste0(pathtodirs, dirs[i])
	for (j in seq_along(filestodist)) {
		file.copy(filestodist[j], to = wd, overwrite = TRUE)
	}
	AppendWorkDir(WorkDir = wd, InScript = file3, OutScript = 'batchr.r') 
	AppendWorkDir(WorkDir = wd, InScript = file5, OutScript = 'PreRunSetup.r') 
}

#------ Below here we ditribute the different parameters ------#
#------ Hunter parameter fitting ------#
# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
library(R.utils)
library(ralmass)

# List the parent directory of all the work directories
pathtodirs = 'e:/almass/WorkDirectories/Goose/'
dirs = dir(pathtodirs)  # For this to work you can't have a bunch of crap sitting in
						# in pathtodirs. Only the subdirectories

# A common use for this would be to copy a fresh exe along with
# resetting the counter, clearing the error file and copying
# the batchr and prerunsetup file.
file1 = 'c:/MSV/ALMaSS_CmdLine/x64/Release/ALMaSS_CmdLine.exe' 
file2 = 'C:/Users/lada/Git/almass/counter.txt' 
file3 = 'C:/Users/lada/Git/almass/goosebatchr.r'	
file4 = 'C:/Users/lada/Git/almass/ErrorFile.txt'
file5 = 'C:/Users/lada/Git/almass/PreRunSetup.r'
# Species specific things:
file6 = 'o:/ST_GooseProject/Field data/Fugledata/fugledata_20150320_obs_clean.csv'
file7 = 'o:/ST_GooseProject/Field data/Fugledata/HabitatUseAll2014.csv'
file8 = 'o:/ST_GooseProject/Field data/observations_PG_01Jan2010-18Jan2016_API.xlsx'
file9 = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Goose/GooseRoosts.txt'
file10 = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Goose/PfYoungDist.txt'

filestodist = c(file1, file2, file3, file4, file5, file6, file7, file8, file9, file10)

# We overwrite, so be sure you actually want to do this!
for (i in seq_along(dirs)) {
	wd = paste0(pathtodirs, dirs[i])
	for (j in seq_along(filestodist)) {
		file.copy(filestodist[j], to = wd, overwrite = TRUE)
	}
	AppendWorkDir(WorkDir = wd, InScript = file3, OutScript = 'batchr.r') 
	AppendWorkDir(WorkDir = wd, InScript = file5, OutScript = 'PreRunSetup.r') 
}

#------ Below here we ditribute the different parameters ------#

# Distribute the paramter values to run:
# Goose parameter fitting
# Openness
val = round(seq(0, 2000, length.out = 10))
wdpath = paste0(pathtodirs, dirs[1])
setwd(wdpath) 
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
EditBat(wdpath)  # Inserts the right number of runs from the file written with GenerateParams above  
# Following likelyhood
val = seq(0, 10000, length.out = 10)
val1 = seq(0, 10000, length.out = 10)
val2 = seq(0, 10000, length.out = 10)
wdpath = paste0(pathtodirs, dirs[2])
setwd(wdpath) 
GenerateParams('BGOOSE_FOLLOWINGLIKELYHOOD' = val,
			   'PFGOOSE_FOLLOWINGLIKELYHOOD' = val1,
			   'GLGOOSE_FOLLOWINGLIKELYHOOD' = val2,
			    write = TRUE)
EditBat(wdpath)
# Max appetite scaler
val = seq(1, 10, length.out = 10)
wdpath = paste0(pathtodirs, dirs[3])
setwd(wdpath) 
GenerateParams('GOOSE_MAXAPPETITESCALER' = val, write = TRUE)
EditBat(wdpath)
# Max energy reserve proportion
val = seq(1, 10, length.out = 10)
wdpath = paste0(pathtodirs, dirs[4])
setwd(wdpath) 
GenerateParams('GOOSE_MAXENERGYRESERVEPROPORTION' = val, write = TRUE)
EditBat(wdpath)
# The leaving threshold
val = seq(0.5, 1.5, length.out = 10)
wdpath = paste0(pathtodirs, dirs[5])
setwd(wdpath) 
GenerateParams('GOOSE_LEAVINGTHRESHOLD' = val, write = TRUE)
EditBat(wdpath)
# Forage distance
val = seq(5000, 20000, length.out = 10)
val1 = seq(10000, 30000, length.out = 10)
val2 = seq(1000, 10000, length.out = 10)
wdpath = paste0(pathtodirs, dirs[6])
setwd(wdpath) 
GenerateParams('GOOSE_FORAGEDIST_BN' = val,
			   'GOOSE_FORAGEDIST_PF' = val1,
			   'GOOSE_FORAGEDIST_GL' = val2,
			    write = TRUE)
EditBat(wdpath)
# Min forage decay rate
val = seq(0.9, 1, length.out = 10)
wdpath = paste0(pathtodirs, dirs[7])
setwd(wdpath) 
GenerateParams('GOOSE_MINFORAGEDECAYRATE' = val, write = TRUE)
EditBat(wdpath)
# Energy calibration
val = seq(0.9, 1, length.out = 10)
wdpath = paste0(pathtodirs, dirs[8])
setwd(wdpath) 
GenerateParams('GOOSE_ENERGYCALIBRATION' = val, write = TRUE)
EditBat(wdpath)
# Goose feeding time
val = seq(0.75, 1, length.out = 10)
wdpath = paste0(pathtodirs, dirs[9])
setwd(wdpath) 
GenerateParams('GOOSE_FEEDINGTIME' = val, write = TRUE)
EditBat(wdpath)
# Roost leaving likelyhood
val = seq(0, 100, length.out = 10)
wdpath = paste0(pathtodirs, dirs[11])
setwd(wdpath) 
GenerateParams('GOOSE_ROOSTLEAVINGLIKELYHOOD' = val, write = TRUE)
EditBat(wdpath)
# Distance penalty
val = seq(0.001, 1, length.out = 10)
wdpath = paste0(pathtodirs, dirs[12])
setwd(wdpath) 
GenerateParams('GOOSE_MEM_DISTPENALTY' = val, write = TRUE)
EditBat(wdpath)
# Memory duration
val = seq(0, 100, length.out = 10)
wdpath = paste0(pathtodirs, dirs[13])
setwd(wdpath) 
GenerateParams('GOOSE_MEM_MINMEMVALUE' = val, write = TRUE)
EditBat(wdpath)
# Grain decay rate
val = seq(0.7, 1, length.out = 10)
wdpath = paste0(pathtodirs, dirs[14])
setwd(wdpath) 
GenerateParams('GOOSE_GRAINDECAYRATE' = val, write = TRUE)
EditBat(wdpath)

#------ Hunter parameter fitting ------#
# Careful here - check the index - first in dirs is 0
openvals = seq(400, 1400, by = 200)
densityvals = seq(0.1, 1.6, length.out = 6)
probvals = seq(-0.0006, -0.0106, by = -0.001)

# 0 - Random
wdpath = paste0(pathtodirs, 'WD0')  
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 0)
# 1 - Closest
wdpath = paste0(pathtodirs, 'WD1')
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 1)
# 2 - RandomOpen
wdpath = paste0(pathtodirs, 'WD2') 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 2)
# 3 - RandomMaxDensity
wdpath = paste0(pathtodirs, 'WD3') 
setwd(wdpath)
GenerateParams('HUNTERS_MAXDENSITY' = densityvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 3)
# 4 - ClosestOpen
wdpath = paste0(pathtodirs, 'WD4') 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 4)
# 5
wdpath = paste0(pathtodirs, 'WD5') 
setwd(wdpath)
GenerateParams('HUNTERS_MAXDENSITY' = densityvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 5)
# 6
wdpath = paste0(pathtodirs, 'WD6')) 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openvals,
				 'HUNTERS_MAXDENSITY' = densityvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 6)
# 7 same values as 6
wdpath = paste0(pathtodirs, 'WD7')) 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val,
				 'HUNTERS_MAXDENSITY' = val2, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 7)
# 10
wdpath = paste0(pathtodirs, 'WD10')) 
setwd(wdpath)
GenerateParams('CLOSESTFARMPROBPARAMONE' = probvals,
 				'GOOSE_MINFORAGEOPENNESS' = openvals, 
 				'HUNTERS_MAXDENSITY' = densityvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 10)



