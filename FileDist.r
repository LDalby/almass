# Cooy file to x number of directories
# Just handy when e.g. a new exe needs to distributed
library(R.utils)

# List the directories:
pathtodirs = 'd:/almass/WorkDirectories/Hunter/HunterTestingAug2015/'
dirs = dir(pathtodirs)  # For this to work you can't have a bunch of crap sitting in
						# in pathtodirs. Only the subdirectories

filetodist = 'c:/MSVC/ALMaSS_CmdLine/x64/Release/ALMaSS_CmdLine.exe'  # The file that needs copying
# filetodist = 'C:/Users/lada/Git/almass/counter.txt'  # The file that needs copying
filetodist = 'C:/Users/lada/Git/almass/batchr.r'
filetodist = 'C:/Users/lada/Git/almass/ErrorFile.txt'

for (i in seq_along(dirs)) {
	file.copy(filetodist, to = paste0(pathtodirs, dirs[i]), overwrite = TRUE)
}
