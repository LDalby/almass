# Functions to manage almass runs
library(ralmass)
wd = 'c:/MSV/WorkDirectory/'
seasons = 1
EditIni(WorkDir = wd, Model = 'goose', NYear = seasons+1)
EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'GOOSE_MODELEXITDAY', value = 365+134+seasons*365)
EditConfig(file = file.path(wd, 'TIALMaSSConfig.cfg'), config = 'HUNTERS_RECORDBAG', value = 'true')


HHLpath = 'c:/MSV/WorkDirectory/Hunter_Hunting_Locations.txt'
EditHunterInput(file = HHL, hhlpath = HHL, parameter = 'GooseLookChance', change = 0.55, huntersubset = 'all')
