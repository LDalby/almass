# Write reclassification file
# Date: 23 August 2016
# Author: Lars Dalby

library(data.table)
library(ralmass)

simbag = fread('e:/almass/WorkDirectories/Goose/WD51/HuntingBagRecord.txt')
simbag[, Species:=sapply(GameType, ConvertGameType)]
simbag[, NoShot:=.N, by = list(PolygonRef, Species, SeasonNumber)]
HS1Pinkfoot = unique(simbag[Species == 'Pinkfoot', .(SeasonNumber, PolygonRef, NoShot)])
# file = 'o:/ST_LandskabsGenerering/temp/ReclassTestData/'
file = 'C:/Users/lada/Git/shiny/vejlerne/Data'
setnames(HS1Pinkfoot, c('Year','PolyRefNum', 'Numbers'))
write.csv(HS1Pinkfoot, file = file.path(file, 'snouter.csv'), row.names = FALSE, quote = FALSE)

