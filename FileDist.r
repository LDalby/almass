# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
library(R.utils)
library(ralmass)

# List the parent directory of all the work directories
pathtodirs = 'u:/Hunter/'
dirs = dir(pathtodirs)[-grep('BaseWD')]  # For this to work you can't have a bunch of crap sitting in
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
# Careful here - check the index - first in dirs is 0
# 0
val = seq(100, 500, length.out = 5)
wdpath = paste0(pathtodirs, 'WD0')  
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 0)
# 1
wdpath = paste0(pathtodirs, 'WD1')
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 1)
# 2 
val = seq(100, 1000, length.out = 10)
wdpath = paste0(pathtodirs, 'WD2') 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 2)
# 3
val = seq(0, 2.2, length.out = 10)
wdpath = paste0(pathtodirs, 'WD3') 
setwd(wdpath)
GenerateParams('HUNTERS_MAXDENSITY' = val, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 3)
# 4
val = seq(100, 1000, length.out = 10)
wdpath = paste0(pathtodirs, 'WD4') 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 4)
# 5
val = seq(0, 2.2, length.out = 10)
wdpath = paste0(pathtodirs, 'WD5') 
setwd(wdpath)
GenerateParams('HUNTERS_MAXDENSITY' = val, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 5)
# 6
val = seq(100, 2000, length.out = 20)
val2 = seq(0.1, 2.5, length.out = 25)
wdpath = paste0(pathtodirs, 'WD6')) 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val,
				 'HUNTERS_MAXDENSITY' = val2, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 6)
# 7 same values as 6
wdpath = paste0(pathtodirs, 'WD7')) 
setwd(wdpath)
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val,
				 'HUNTERS_MAXDENSITY' = val2, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 7)
# 8
wdpath = paste0(pathtodirs, 'WD8')) 
setwd(wdpath)
val = seq(-0.001, -0.01, length.out = 100)
GenerateParams('CLOSESTFARMPROBPARAMONE' = val, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 8)
# 9
wdpath = paste0(pathtodirs, 'WD9')) 
setwd(wdpath)
val = seq(-0.0001, -0.01, length.out = 20)
val2 = seq(100, 2000, length.out = 20)
GenerateParams('CLOSESTFARMPROBPARAMONE' = val,
 'GOOSE_MINFORAGEOPENNESS' = val2,  write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 9)
# 10
wdpath = paste0(pathtodirs, 'WD10')) 
setwd(wdpath)
val = seq(-0.0001, -0.01, length.out = 20)
val2 = seq(500, 1400, length.out = 10)
val3 = seq(0.1, 1.5, length.out = 10)
GenerateParams('CLOSESTFARMPROBPARAMONE' = val,
 				'GOOSE_MINFORAGEOPENNESS' = val2, 
 				'HUNTERS_MAXDENSITY' = val3, write = TRUE)
EditBat(wdpath)
EditConfig(file = paste0(wdpath, '/TIALMaSSConfig.cfg'), param = 'HUNTERS_DISTRIBUTE_RULESET', value = 10)

