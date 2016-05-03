# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
# library(R.utils)
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
file11 = 'C:/MSV/ALMaSS_inputs/GooseManagement/TIALMaSSConfig.cfg'

filestodist = c(file1, file2, file3, file4, file5, file6, file7, file8, file9, file10, file11)

# We overwrite, so be sure you actually want to do this!
for (i in seq_along(dirs)) {
	wd = paste0(pathtodirs, dirs[i])
	wd = paste0(pathtodirs, 'WD11')
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
openval = round(seq(0, 1000, length.out = 21))
wdpath = paste0(pathtodirs, 'WD1')
setwd(wdpath) 
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openval, write = TRUE)
EditBat(wdpath)  # Inserts the right number of runs from the file written with GenerateParams above  
# Max appetite scaler
appetiteval = seq(3.02, 9.06, length.out = 21)
wdpath = paste0(pathtodirs, 'WD2')
setwd(wdpath) 
GenerateParams('GOOSE_MAXAPPETITESCALER' = appetiteval, write = TRUE)
EditBat(wdpath)
# Max energy reserve proportion
energyval = seq(0.1, 0.5, length.out = 21)
wdpath = paste0(pathtodirs, 'WD3')
setwd(wdpath) 
GenerateParams('GOOSE_MAXENERGYRESERVEPROPORTION' = energyval, write = TRUE)
EditBat(wdpath)
# The leaving threshold
leavingval = seq(1.0, 1.3, length.out = 21)
wdpath = paste0(pathtodirs, 'WD4')
setwd(wdpath) 
GenerateParams('GOOSE_LEAVINGTHRESHOLD' = leavingval, write = TRUE)
EditBat(wdpath)
# After dark time
afterdarkval = round(seq(0, 60, length.out = 21))
wdpath = paste0(pathtodirs, 'WD5')
setwd(wdpath) 
GenerateParams('GOOSE_AFTERDARKTIME' = afterdarkval, write = TRUE)
EditBat(wdpath) 
# Min forage decay rate
foragedecayval = seq(0.9, 1, length.out = 21)
wdpath = paste0(pathtodirs, 'WD6')
setwd(wdpath) 
GenerateParams('GOOSE_MINFORAGEDECAYRATE' = foragedecayval, write = TRUE)
EditBat(wdpath)
# Goose feeding time
feedingval = seq(0.6, 1, length.out = 21)
wdpath = paste0(pathtodirs, 'WD7')
setwd(wdpath) 
GenerateParams('GOOSE_FEEDINGTIME' = feedingval, write = TRUE)
EditBat(wdpath)
# Roost leaving likelyhood
leavingnlikelyhoodval = round(seq(51, 200, length.out = 21))
wdpath = paste0(pathtodirs, 'WD8')
setwd(wdpath) 
GenerateParams('GOOSE_ROOSTLEAVINGLIKELYHOOD' = leavingnlikelyhoodval, write = TRUE)
EditBat(wdpath)
# Expected foraging time
expectedval = round(seq(10, 240, length.out = 21))
wdpath = paste0(pathtodirs, 'WD9')
setwd(wdpath) 
GenerateParams('GOOSE_MEM_EXPECTEDFORAGINGTIME' = expectedval, write = TRUE)
EditBat(wdpath)
# Grain decay rate
grainval = seq(0.9, 1, length.out = 21)
wdpath = paste0(pathtodirs, 'WD10')
setwd(wdpath) 
GenerateParams('GOOSE_GRAINDECAYRATE' = grainval, write = TRUE)
EditBat(wdpath)
# Memory duration
memoryval = 0:20
wdpath = paste0(pathtodirs, 'WD11')
setwd(wdpath) 
GenerateParams('GOOSE_MEM_MINMEMVALUE' = memoryval, write = TRUE)
EditBat(wdpath)
# Following likelyhood
followingval = round(seq(0, 10000, length.out = 21))
followingval1 = round(seq(0, 10000, length.out = 21))
followingval2 = round(seq(0, 10000, length.out = 21))
wdpath = paste0(pathtodirs, 'WD12')
setwd(wdpath) 
GenerateParams('BGOOSE_FOLLOWINGLIKELYHOOD' = followingval,
			   'PFGOOSE_FOLLOWINGLIKELYHOOD' = followingval1,
			   'GLGOOSE_FOLLOWINGLIKELYHOOD' = followingval2,
			    write = TRUE, expand = FALSE)
EditBat(wdpath)
# Forage distance
foragedistval = round(seq(1000, 20000, length.out = 21))
foragedistval = c(foragedistval, 35000)  # This effectively turns the cfg off.
wdpath = paste0(pathtodirs, 'WD13')
setwd(wdpath) 
GenerateParams('GOOSE_FORAGEDIST_BN' = foragedistval,
			   'GOOSE_FORAGEDIST_PF' = foragedistval,
			   'GOOSE_FORAGEDIST_GL' = foragedistval,
			    write = TRUE, expand = FALSE)
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
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 4)
# 5
wdpath = paste0(pathtodirs, 'WD5') 
setwd(wdpath)
GenerateParams('HUNTERS_MAXDENSITY' = densityvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 5)
# 6
wdpath = paste0(pathtodirs, 'WD6')) 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openvals,
				 'HUNTERS_MAXDENSITY' = densityvals, write = FALSE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 6)
# 7 same values as 6
wdpath = paste0(pathtodirs, 'WD7')) 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val,
				 'HUNTERS_MAXDENSITY' = val2, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 7)
# 10
wdpath = paste0(pathtodirs, 'WD10')) 
setwd(wdpath)
GenerateParams('CLOSESTFARMPROBPARAMONE' = probvals,
 				'GOOSE_MINFORAGEOPENNESS' = openvals, 
 				'HUNTERS_MAXDENSITY' = densityvals, write = TRUE, replicates = 10)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), config = 'HUNTERS_DISTRIBUTE_RULESET', value = 10)



