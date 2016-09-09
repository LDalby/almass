library(data.table)
library(ralmass)
library(ggplot2)
library(viridis)

pth = 'e:/almass/WorkDirectories/Goose/'
dirs = dir(pth)
scenariodirs = dirs[grep('WD2', dirs)]  # For the full model scenarios
scenariodirs = c(scenariodirs, c('WD31', 'WD32', 'WD32', 'WD33', 'WD34', 'WD35', 'WD36', 'WD37', 'WD38'))
respath = file.path(pth, scenariodirs[i], 'Results', 'ParameterFittingResults.txt')
tmp = fread(respath, select = 'Parameter') 
tmp = unique(tmp[,Parameter])

OutDirectory = 'o:/ST_GooseProject/ALMaSS/Scenarios/ResultBackup/'
for (i in seq_along(scenariodirs)) {
  respath = file.path(pth, scenariodirs[i], 'Results')
  fileloc = file.path(respath, 'ParameterFittingResults.txt')
  if(file.exists(fileloc)) {
    parts = stringr::str_split(basename(fileloc), '\\.')
    tmp = fread(fileloc, select = 'Parameter') 
    tmp = unique(tmp[,Parameter])
    datestamp = paste(Sys.Date(), parts[[1]][2], sep = '.')
    filename = paste(parts[[1]][1], datestamp, sep = '_')
    fullname = paste(tmp, scenariodirs[i], filename, sep = '_')
    newfileloc = file.path(OutDirectory, fullname)
    file.copy(from = fileloc, to = newfileloc)
    thewd = file.path(pth, scenariodirs[i])
    file.copy(file.path(thewd, 'HuntingOpportunities.txt'), file.path(OutDirectory, paste(tmp, Sys.Date(), 'HuntingOpportunities.txt')))
    file.copy(file.path(thewd, 'HuntingBagRecord.txt'), file.path(OutDirectory, paste(tmp, Sys.Date(), 'HuntingBagRecord.txt')))
  }
}
  