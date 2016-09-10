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


# ----
# Get the untouced result files 
pth = 'e:/almass/WorkDirectories/Goose/'
dirs = dir(pth)
scenariodirs = dirs[grep('WD2', dirs)]  # For the full model scenarios
scenariodirs = c(scenariodirs, c('WD31', 'WD32', 'WD32', 'WD33', 'WD34', 'WD35', 'WD36', 'WD37', 'WD38'))
# scenariodirs = c('WD20', 'WD21', 'WD22')
foragelist = vector('list', length(scenariodirs))
huntingoplist = foragelist
huntingbaglist = foragelist


for (i in seq_along(scenariodirs)) {
  foragepth = file.path(pth, scenariodirs[i], 'GooseFieldForageData.txt')
  sel = c('SeasonNumber',
          'Day',
          'Polyref',
          'Barnacle',
          'Pinkfoot',
          'Greylag')
  forage = fread(foragepth, select = sel)
  forage[, Month := month(as.IDate(Day, origin = '2010-01-01'))]
  forage[, Day := NULL]
  forage = melt(
    forage,
    id.vars = c('SeasonNumber', 'Month', 'Polyref'),
    value.name = 'Numbers',
    variable.name = 'Species'
  )
  forage[, AvgNum := round(mean(Numbers)), by = c('SeasonNumber', 'Month', 'Polyref', 'Species')]
  forage[, Numbers := NULL]
  forage = forage[AvgNum > 0, ]
  forage = unique(forage)
  thescenario = readLines(file.path(pth, scenariodirs[i], 'ParameterValues.txt'))
  forage[, Scenario := thescenario]
  foragelist[[i]] = forage

# Hunting bag
simbagpth = file.path(pth, scenariodirs[i], 'HuntingBagRecord.txt')
simbag = fread(simbagpth, drop = c('Hour', 'Minute', 'x-coord', 'y-coord', 'Year'))
simbag[, Species:=sapply(GameType, ConvertGameType)]
simbag[, NoShot:=.N, by = list(PolygonRef, Species, SeasonNumber)]
simbag[, Scenario:=thescenario]
huntingbaglist[[i]] = simbag
}
theforagelist = rbindlist(foragelist)
write.table(theforagelist, 'o:/ST_GooseProject/ALMaSS/Scenarios/Scenario09092016/TheForageFiles.txt', row.names = FALSE, quote = FALSE)
huntingbaglist = rbindlist(huntingbaglist)
write.table(huntingbaglist, 'o:/ST_GooseProject/ALMaSS/Scenarios/Scenario09092016/TheHuntingbagFiles.txt', row.names = FALSE, quote = FALSE)









