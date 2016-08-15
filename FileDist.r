# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
library(data.table)
library(ralmass)

# List the parent directory of all the work directories
pathtodirs = 'e:/almass/WorkDirectories/Goose/'
dirs = dir(pathtodirs)  # For this to work you can't have a bunch of crap sitting in
						# in pathtodirs. Only the subdirectories
dirs = dirs[grep('WD2', dirs)]  # For the full model scenarios
# dirs = c("WD23", "WD24", "WD25", "WD26", "WD27")
# A common use for this would be to copy a fresh exe along with
# resetting the counter, clearing the error file and copying
# the batchr and prerunsetup file.
file1 = 'c:/MSV/ALMaSS_CmdLine/x64/Release/ALMaSS_CmdLine.exe' 
file2 = 'C:/Users/lada/Git/almass/counter.txt' 
file3 = 'C:/Users/lada/Git/almass/goosebatchr.r'	
file4 = 'C:/Users/lada/Git/almass/ErrorFile.txt'
file5 = 'C:/Users/lada/Git/almass/PreRunSetup.r'
# Species specific things:
file6 = 'o:/ST_GooseProject/Field data/FieldobsDistancesFromRoost2016-04-25.txt'
file7 = 'o:/ST_GooseProject/Field data/Fugledata/HabitatUseAll2014.csv'
file8 = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/APIdata.txt'
file9 = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Goose/GooseRoosts.txt'
file10 = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Goose/PfYoungDist.txt'
file11 = 'C:/MSV/ALMaSS_inputs/GooseManagement/TIALMaSSConfig.cfg'
file12 = 'o:/ST_GooseProject/Field data/FieldobsFlockSizes2016-05-03.txt'
# Landscape:
# file13 = 'C:/MSV/WorkDirectory/VejlerneOpenMay2016PolyRef.txt'
# file14 = 'C:/MSV/WorkDirectory/VejlerneOpenMay2016.lsb'
# file15 = 'C:/MSV/WorkDirectory/VejlerneOpenMay2016FarmRef.txt'

filestodist = c(file1, file2, file3, file4, file5, file6, file7, file8, file9, file10,
				file11, file12)
# HHL = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Hunter/Hunter_Hunting_Locations_NoHunters.txt'
HHL = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Hunter/Hunter_Hunting_Locations_Eff33_05-07-2016.txt'
weather = 'Vejlerne2013-2014.pre'
pre = file.path('c:/MSV/ALMaSS_inputs/Weather/', weather)
# rot = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Farms'
# rots = file.path(rot, dir(rot))
# filestodist = c(filestodist, rots)
# We overwrite, so be sure you actually want to do this!
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	file.copy(filestodist, to = wd, overwrite = TRUE)
	file.copy(HHL, to = file.path(wd, 'Hunter_Hunting_Locations.txt'), overwrite = TRUE)
	file.copy(pre, to = file.path(wd, weather), overwrite = TRUE)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'MAP_WEATHER_FILE', value = weather)
	AppendWorkDir(WorkDir = wd, InScript = file3, OutScript = 'batchr.r') 
	AppendWorkDir(WorkDir = wd, InScript = file5, OutScript = 'PreRunSetup.r') 
}
# Store the results from previous round of fitting:
# StoreResults(pathtodirs, 'o:/ST_GooseProject/ALMaSS/GooseParameterFitting/ParamFittingResults/')
# Warning - the loop below will delete all Result directories 
# So be really, really sure you want to do this!!!
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i], 'Results')
	unlink(wd, recursive = TRUE)
}


#------ Below here we ditribute the different parameters ------#
# Distribute the paramter values to run:
# Goose parameter fitting
# Openness
openval = round(seq(0, 100, length.out = 11))
wdpath = file.path(pathtodirs, 'WD01')
GenerateParams('GOOSE_MINFORAGEOPENNESS' = openval, write = TRUE, path = wdpath)
# Max appetite scaler
appetiteval = seq(1, 7, length.out = 11)
wdpath = file.path(pathtodirs, 'WD02')
GenerateParams('GOOSE_MAXAPPETITESCALER' = appetiteval, write = TRUE, path = wdpath)
# Max energy reserve proportion
energyval = seq(0.15, 0.25, length.out = 11)
wdpath = file.path(pathtodirs, 'WD03')
GenerateParams('GOOSE_MAXENERGYRESERVEPROPORTION' = energyval, write = TRUE, path = wdpath)
# The leaving threshold
leavingval = seq(1.0, 1.1, length.out = 11)
wdpath = file.path(pathtodirs, 'WD04')
GenerateParams('GOOSE_LEAVINGTHRESHOLD' = leavingval, write = TRUE, path = wdpath)
# After dark time
afterdarkval = round(seq(0, 90, length.out = 11))
wdpath = file.path(pathtodirs, 'WD05')
GenerateParams('GOOSE_AFTERDARKTIME' = afterdarkval, write = TRUE, path = wdpath)
# Min forage decay rate
foragedecayval = seq(0.0, 1, length.out = 11)
wdpath = file.path(pathtodirs, 'WD06')
GenerateParams('GOOSE_MINFORAGEDECAYRATE' = foragedecayval, write = TRUE, path = wdpath)
# Goose feeding time
feedingval = seq(0.7, 0.85, length.out = 11)
wdpath = file.path(pathtodirs, 'WD07')
GenerateParams('GOOSE_FEEDINGTIME' = feedingval, write = TRUE, path = wdpath)
# Roost leaving likelyhood
leavedistsdval = round(seq(0, 30, length.out = 11))
wdpath = file.path(pathtodirs, 'WD08')
GenerateParams('GOOSE_ROOSTLEAVEDISTSD' = leavedistsdval, write = TRUE, path = wdpath)
# Expected foraging time
expectedval = round(seq(60, 350, length.out = 11))
wdpath = file.path(pathtodirs, 'WD09')
GenerateParams('GOOSE_MEM_EXPECTEDFORAGINGTIME' = expectedval, write = TRUE, path = wdpath)
# Grain decay rate
grainval = seq(0.985, 1, length.out = 11)
wdpath = file.path(pathtodirs, 'WD10')
GenerateParams('GOOSE_GRAINDECAYRATE' = grainval, write = TRUE, path = wdpath)
# Memory duration
memoryval = seq(0, 30, length.out = 11)
wdpath = file.path(pathtodirs, 'WD11')
GenerateParams('GOOSE_MEM_MINMEMVALUE' = memoryval, write = TRUE, path = wdpath)
# Following likelyhood
followingval = round(seq(5000, 10000, length.out = 11))
followingval1 = round(seq(5000, 10000, length.out = 11))
followingval2 = round(seq(5000, 10000, length.out = 11))
wdpath = file.path(pathtodirs, 'WD12')
GenerateParams('BGOOSE_FOLLOWINGLIKELYHOOD' = followingval,
			   'PFGOOSE_FOLLOWINGLIKELYHOOD' = followingval1,
			   'GLGOOSE_FOLLOWINGLIKELYHOOD' = followingval2,
			    write = TRUE, path = wdpath, expand = FALSE)
# Forage distance
foragedistval = round(seq(1000, 3000, length.out = 11))
# foragedistval = c(foragedistval, 35000)  # This effectively turns the cfg off.
wdpath = file.path(pathtodirs, 'WD13')
GenerateParams('GOOSE_FORAGEDIST_GL' = foragedistval, write = TRUE, path = wdpath, expand = FALSE)

# Set the edit the bat, ini and cfg files to match the parameters set above:
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditBat(wd)
	years = 5
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'HUNTERS_RECORDBAG', value = 'true')
}
# ----
# Goose project scenarios
# ----
years = 10
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'HUNTERS_RECORDBAG', value = 'true')
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
}
# No barnacle geese:
wdpath = file.path(pathtodirs, 'WD20')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
EditConfig(file = tialmasspath, config = 'GOOSE_BN_STARTNOS', value = 0)
EditConfig(file = tialmasspath, config = 'GOOSE_BN_SPRING_MIG_NOS', value = 0)
df = data.table('foo' = 'Barnacle x 0')
write.table(df, file = file.path(wdpath, 'ParameterValues.txt'), sep = '\t', quote = FALSE,
			row.names = FALSE, col.names = FALSE)
# Double barnacle geese:
wdpath = file.path(pathtodirs, 'WD21')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
param = 'GOOSE_BN_STARTNOS'
tialmass = readLines(tialmasspath)
cfgval = GetParamValue(config = tialmass, param = param) 
EditConfig(file = tialmasspath, config = param , value = cfgval*2)
param = 'GOOSE_BN_SPRING_MIG_NOS'
cfgval = GetParamValue(config = tialmass, param = param)
EditConfig(file = tialmasspath, config = param, value = cfgval*2)
df = data.table('foo' = 'Barnacle x 2')
write.table(df, file = file.path(wdpath, 'ParameterValues.txt'), sep = '\t', quote = FALSE,
			row.names = FALSE, col.names = FALSE)
# Double greylag geese:
wdpath = file.path(pathtodirs, 'WD22')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
param = 'GOOSE_GL_STARTNOS'
tialmass = readLines(tialmasspath)
cfgval = GetParamValue(config = tialmass, param = param) 
EditConfig(file = tialmasspath, config = param , value = cfgval*2)
param = 'GOOSE_GL_SPRING_MIG_NOS'
cfgval = GetParamValue(config = tialmass, param = param)
EditConfig(file = tialmasspath, config = param, value = cfgval*2)
df = data.table('foo' = 'Greylag x 2')
write.table(df, file = file.path(wdpath, 'ParameterValues.txt'), sep = '\t', quote = FALSE,
			row.names = FALSE, col.names = FALSE)
# January hunting
wdpath = file.path(pathtodirs, 'WD23')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
EditConfig(file = tialmasspath, config = 'GOOSE_OPENSEASON_END', value = 31)
df = data.table('foo' = 'January hunting')
write.table(df, file = file.path(wdpath, 'ParameterValues.txt'), sep = '\t', quote = FALSE,
			row.names = FALSE, col.names = FALSE)
# Increase in efficiency
wdpath = file.path(pathtodirs, 'WD24')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
hhlpath = file.path(wdpath, 'Hunter_Hunting_Locations.txt')
EditHunterInput(hhlpath, column = 'Efficiency', change = 0.66)
# Only hunt once per week
wdpath = file.path(pathtodirs, 'WD25')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
EditConfig(file = tialmasspath, config = 'HUNTER_REFRACTIONPERIOD', value = 7)
hhlpath = file.path(wdpath, 'Hunter_Hunting_Locations.txt')
EditHunterInput(hhlpath, column = 'WeekdayHunterChance', change = 1.0, weekbehav = 2)  # This sets all hunters to be refraction period hunters
# Teaming up of hunters
# NOTE: Number of hunters needs to be halved.
wdpath = file.path(pathtodirs, 'WD26')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
EditConfig(file = tialmasspath, config = 'HUNTER_MAGAZINECAPACITY', value = 4)
# All hunters checkers:
wdpath = file.path(pathtodirs, 'WD27')
tialmasspath = file.path(wdpath, 'TIALMaSSConfig.cfg')
hhlpath = file.path(wdpath, 'Hunter_Hunting_Locations.txt')
EditHunterInput(hhlpath, column = 'GooseLookChance', change = 1.0)
# Baseline
wdpath = file.path(pathtodirs, 'WD28')
df = data.table('foo' = 'Baseline')
write.table(df, file = file.path(wdpath, 'ParameterValues.txt'), sep = '\t', quote = FALSE,
			row.names = FALSE, col.names = FALSE)



# ------ Multiparam Scenarios ----- #
# Following likelyhood and SD of roost leave times
# followingval = round(seq(6500, 8500, length.out = 15))
# followingval1 = round(seq(6500, 8500, length.out = 15))
# followingval2 = round(seq(6500, 8500, length.out = 15))
# following = GenerateParams('BGOOSE_FOLLOWINGLIKELYHOOD' = followingval,
# 			   'PFGOOSE_FOLLOWINGLIKELYHOOD' = followingval1,
# 			   'GLGOOSE_FOLLOWINGLIKELYHOOD' = followingval2,
# 			    write = FALSE, expand = FALSE, replicates = 1)
# following = as.character(following$Params)

# leavedistsdval = round(seq(0, 30, length.out = 15))
# leave = GenerateParams('GOOSE_ROOSTLEAVEDISTSD' = leavedistsdval, write = FALSE)
# leave = as.character(leave$Params)

# TheFinalList = vector('list', length(leave))
# TheList = vector('list', length(followingval))

# params = 3
# runs = length(followingval)
# from = seq(params-(params-1),(params*runs)-(params-1), by = params)
# to = seq(params,params*runs, by = params)

# for (i in seq_along(followingval)) {
# 	TheList[[i]] = following[from[i]:to[i]]
# }
# for (j in seq_along(leave)) {
# 	TheFinalList[[j]] = unlist(lapply(TheList, FUN = append, leave[j]))
# }
# df = data.frame('Params' = unlist(TheFinalList) )
# wdpath = paste0(pathtodirs, 'WD14')
# setwd(wdpath) 
# write.table(df, file = paste(wdpath,'ParameterValues.txt', sep = '/'), sep = '\t', quote = FALSE,
# 			row.names = FALSE, col.names = FALSE)
# EditBat(wdpath)
# # Feeding time, max appetite scaler and max energy reserve proportion
# feedingval = seq(0.7, 0.85, length.out = 8)
# appetiteval = seq(0, 5, length.out = 8)
# energyval = seq(0.15, 0.25, length.out = 8)
# wdpath = paste0(pathtodirs, 'WD15')
# setwd(wdpath) 
# GenerateParams('GOOSE_FEEDINGTIME' = feedingval, 'GOOSE_MAXENERGYRESERVEPROPORTION' = energyval,
# 'GOOSE_MAXAPPETITESCALER' = appetiteval, write = TRUE)
# EditBat(wdpath)

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



