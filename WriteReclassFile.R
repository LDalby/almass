# Write reclassification file
# Date: 23 August 2016
# Author: Lars Dalby

library(data.table)
library(ralmass)

simbag = fread('e:/almass/WorkDirectories/Goose/WD11/HuntingBagRecord.txt')
simbag[, Species:=sapply(GameType, ConvertGameType)]
simbag[, NoShot:=.N, by = list(PolygonRef, Species, SeasonNumber)]
HS1Pinkfoot = unique(simbag[Species == 'Pinkfoot' & SeasonNumber == 1, .(PolygonRef, NoShot)])
file = 'o:/ST_LandskabsGenerering/temp/ReclassTestData/'
write.table(HS1Pinkfoot, file = file.path(file, 'HS1Pinkfoot.txt'),  col.names = FALSE, row.names = FALSE, quote = FALSE, sep = ' : ')