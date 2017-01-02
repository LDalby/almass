# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
# Grendel version
library(data.table)
library(ralmass)

# List the parent directory of all the work directories
pathtodirs = 'e:/almass/WorkDirectories/Goose/'  # Both machines
dirs = dir(pathtodirs)  # For this to work you can't have a bunch of crap sitting in
						# in pathtodirs. Only the subdirectories
# dirs = dirs[grep('WD2', dirs)]  # For the full model scenarios
# dirs = c(dirs, c('WD31', 'WD32', 'WD32', 'WD33', 'WD34', 'WD35', 'WD36', 'WD37', 'WD38'))
dirs = 'WD01'
# A common use for this would be to copy a fresh exe along with
# resetting the counter, clearing the error file and copying
# the batchr and prerunsetup file.
if(Sys.info()['nodename'] == 'BIOS-REGN01') {
  gitalmass = 'c:/Users/au206907/Documents/GitHub/almass/' 
  exepath = 'o:/ST_GooseProject/ALMaSS/Executables/Lars/' 
}
if(Sys.info()['nodename'] == 'DMU-WS-8297') {
  gitalmass = 'C:/Users/lada/Git/almass/'  
  exepath = 'c:/MSV/ALMaSS_CmdLine/x64/Release/'  
}
almassinputs = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/'  # Both machines
file1 = file.path(exepath, 'ALMaSS_CmdLine.exe')
file2 = file.path(gitalmass, 'counter.txt' )
file3 = file.path(gitalmass, 'goosebatchr.r')
file4 = file.path(gitalmass, 'ErrorFile.txt')
file5 = file.path(gitalmass, 'PreRunSetup.r')
# Species specific things:
fielddata = 'o:/ST_GooseProject/Field data/'
file6 = file.path(fielddata, 'FieldobsDistancesFromRoost2016-04-25.txt')
file7 = file.path(fielddata, 'Fugledata/HabitatUseAll2014.csv')
file8 = file.path(almassinputs, 'APIdata.txt')
file9 = file.path(almassinputs, 'Goose/GooseRoosts.txt')
file10 = file.path(almassinputs, 'Goose/PfYoungDist.txt')
file11 = file.path(almassinputs, 'TIALMaSSConfig.cfg')
file12 = file.path(fielddata, 'FieldobsFlockSizes2016-05-03.txt')
# Landscape:
# file13 = 'C:/MSV/WorkDirectory/VejlerneOpenMay2016PolyRef.txt'
# file14 = 'C:/MSV/WorkDirectory/VejlerneOpenMay2016.lsb'
# file15 = 'C:/MSV/WorkDirectory/VejlerneOpenMay2016FarmRef.txt'

filestodist = c(file1, file2, file3, file4, file5, file6, file7, file8, file9, file10,
				        file11, file12)
# HHL = file.path(almassinputs, 'Hunter/746_VejlerneHuntersDiffGLC.txt')
weather = 'Vejlerne2013-2014.pre'
pre = file.path('c:/MSV/ALMaSS_inputs/Weather/', weather)
# rot = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Farms'
# rots = file.path(rot, dir(rot))
# filestodist = c(filestodist, rots)
# We overwrite, so be sure you actually want to do this!
for (i in seq_along(dirs)) {
	wd = file.path(pathtodirs, dirs[i])
	file.copy(filestodist, to = wd, overwrite = TRUE)
	# file.copy(HHL, to = file.path(wd, 'Hunter_Hunting_Locations.txt'), overwrite = TRUE)
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

# ----
# Goose parameter fitting
# ----

# Distribute the paramter values to run:
# Openness
openval = round(seq(0, 100, length.out = 3))
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
	years = 2
	EditIni(WorkDir = wd, Model = 'goose', NYear = years+1)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+years*365)
	EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'HUNTERS_RECORDBAG', value = 'true')
}
