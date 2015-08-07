# Cooy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
library(R.utils)

# List the directories:
pathtodirs = 'd:/almass/WorkDirectories/Hunter/HunterTestingAug2015/'
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

# We overwrite, so be sure you actually want to do this!
for (i in seq_along(dirs)) {
	for (j in seq_along(filestodist)) {
		file.copy(filestodist[j], to = paste0(pathtodirs, dirs[i]), overwrite = TRUE)
	}
}
