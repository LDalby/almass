# Copy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
library(R.utils)
library(ralmass)

# List the parent directory of all the work directories
pathtodirs = 'e:/almass/WorkDirectories/Hunter/HunterTestingAug2015/'
dirs = dir(pathtodirs)  # For this to work you can't have a bunch of crap sitting in
						# in pathtodirs. Only the subdirectories

# A common use for this would be to copy a fresh exe along with
# resetting the counter, clearing the error file and copying
# the batchr and prerunsetup file.
file1 = 'c:/MSVC/ALMaSS_CmdLine/x64/Release/ALMaSS_CmdLine.exe' 
file2 = 'C:/Users/lada/Git/almass/counter.txt' 
file3 = 'C:/Users/lada/Git/almass/batchr.r'	
file4 = 'C:/Users/lada/Git/almass/ErrorFile.txt'
file5 = 'C:/Users/lada/Git/almass/PreRunSetup.r'

filestodist = c(file1, file2, file3, file4, file5)
# filestodist = c(file1, file2, file3, file4)

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
# Careful here - check the index - first in dirs is 0
# 0
val = seq(100, 500, length.out = 5)
setwd(paste0(pathtodirs, 'WD0'))  
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
# 1
setwd(paste0(pathtodirs, 'WD1'))  # The first two in fact ignore these
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
# 2 
val = seq(100, 1000, length.out = 10)
setwd(paste0(pathtodirs, 'WD2')) 
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
# 3
val = seq(0, 2.2, length.out = 10)
setwd(paste0(pathtodirs, 'WD3')) 
GenerateParams('HUNTERS_MAXDENSITY' = val, write = TRUE)
# 4
val = seq(100, 1000, length.out = 10)
setwd(paste0(pathtodirs, 'WD4')) 
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val, write = TRUE)
# 5
val = seq(0, 2.2, length.out = 10)
setwd(paste0(pathtodirs, 'WD5')) 
GenerateParams('HUNTERS_MAXDENSITY' = val, write = TRUE)
# 6
val = seq(100, 2000, length.out = 20)
val2 = seq(0.1, 2.5, length.out = 25)
setwd(paste0(pathtodirs, 'WD6')) 
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val,
				 'HUNTERS_MAXDENSITY' = val2, write = TRUE)
EditBat(paste0(pathtodirs, 'WD6'))
# 7 same values as 6
setwd(paste0(pathtodirs, 'WD7')) 
GenerateParams('GOOSE_MINFORAGEOPENNESS' = val,
				 'HUNTERS_MAXDENSITY' = val2, write = TRUE)
EditBat(paste0(pathtodirs, 'WD7'))
# 8
setwd(paste0(pathtodirs, 'WD8')) 
val = seq(-0.001, -0.01, length.out = 100)
GenerateParams('CLOSESTFARMPROBPARAMONE' = val, write = TRUE)
EditBat(paste0(pathtodirs, 'WD8'))
# 9
setwd(paste0(pathtodirs, 'WD9')) 
val = seq(-0.0001, -0.01, length.out = 20)
val2 = seq(100, 2000, length.out = 20)
GenerateParams('CLOSESTFARMPROBPARAMONE' = val,
 'GOOSE_MINFORAGEOPENNESS' = val2,  write = TRUE)
EditBat(paste0(pathtodirs, 'WD9'))
# 10
setwd(paste0(pathtodirs, 'WD10')) 
val = seq(-0.0001, -0.01, length.out = 20)
val2 = seq(500, 1400, length.out = 10)
val3 = seq(0.1, 1.5, length.out = 10)
GenerateParams('CLOSESTFARMPROBPARAMONE' = val,
 				'GOOSE_MINFORAGEOPENNESS' = val2, 
 				'HUNTERS_MAXDENSITY' = val3, write = TRUE)
EditBat(paste0(pathtodirs, 'WD10'))

