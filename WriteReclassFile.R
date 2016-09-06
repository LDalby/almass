# Write reclassification file
# Date: 23 August 2016
# Author: Lars Dalby

library(data.table)
library(ralmass)

simbag = fread('e:/almass/WorkDirectories/Goose/WD51/HuntingBagRecord.txt')
simbag[, Species:=sapply(GameType, ConvertGameType)]
simbag[, NoShot:=.N, by = list(PolygonRef, Species, SeasonNumber)]
HS1Pinkfoot = unique(simbag[Species == 'Pinkfoot' & SeasonNumber == 1, .(PolygonRef, NoShot)])
file = 'o:/ST_LandskabsGenerering/temp/ReclassTestData/'
setnames(HS1Pinkfoot, c('PolyRefNum', 'Numbers'))
write.csv(HS1Pinkfoot, file = file.path(file, 'HS1Pinkfoot2.csv'), row.names = FALSE, quote = FALSE)