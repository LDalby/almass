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
setwd(paste0(pathtodirs, dirs[1]))  
GenerateParams('GOOSE_MINFORAGEOPENNESS (float)' = val, write = TRUE)
# 1
setwd(paste0(pathtodirs, dirs[2]))  # The first two in fact ignore these
GenerateParams('GOOSE_MINFORAGEOPENNESS (float)' = val, write = TRUE)
# 2 
val = seq(100, 1000, length.out = 10)
setwd(paste0(pathtodirs, dirs[3])) 
GenerateParams('GOOSE_MINFORAGEOPENNESS (float)' = val, write = TRUE)
# 3
val = seq(0, 2.2, length.out = 10)
setwd(paste0(pathtodirs, dirs[4])) 
GenerateParams('HUNTERS_MAXDENSITY (float)' = val, write = TRUE)
# 4
val = seq(100, 1000, length.out = 10)
setwd(paste0(pathtodirs, dirs[5])) 
GenerateParams('GOOSE_MINFORAGEOPENNESS (float)' = val, write = TRUE)
# 5
val = seq(0, 2.2, length.out = 10)
setwd(paste0(pathtodirs, dirs[6])) 
GenerateParams('HUNTERS_MAXDENSITY (float)' = val, write = TRUE)
# 6
val = seq(100, 1000, length.out = 10)
val2 = seq(0.05, 0.1, length.out = 20)
setwd(paste0(pathtodirs, dirs[7])) 
GenerateParams('GOOSE_MINFORAGEOPENNESS (float)' = val,
				 'HUNTERS_MAXDENSITY (float)' = val2, write = TRUE)
# 7 same values as 6
setwd(paste0(pathtodirs, dirs[8])) 
GenerateParams('GOOSE_MINFORAGEOPENNESS (float)' = val,
				 'HUNTERS_MAXDENSITY (float)' = val2, write = TRUE)
# 8
setwd(paste0(pathtodirs, dirs[9])) 
val = seq(-0.001, -0.02, length.out = 100)
GenerateParams('CLOSESTFARMPROBPARAMONE (float)' = val, write = TRUE)

# 9
setwd(paste0(pathtodirs, dirs[10])) 
val = seq(-0.01, -0.2, length.out = ?)
val2 = seq(100, 1000, length.out = 10)
GenerateParams('CLOSESTFARMPROBPARAMONE (float)' = val,
 'GOOSE_MINFORAGEOPENNESS (float)' = val2,  write = TRUE)

# 10

