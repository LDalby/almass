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

# ---- Summarize the scenario hunting bags:
scenbags = fread('o:/ST_GooseProject/ALMaSS/Scenarios/ScenarioHuntingBags.txt')
scenbags = fread('o:/ST_GooseProject/ALMaSS/Scenarios/ScenarioHuntingBags2.txt')
scenbags[, Species:=sapply(GameType, ConvertGameType)]
scenbags[, NoShot:=.N, by = list(PolygonRef, Species, scenario)]
scenbags[, AvgNoShot:=round(NoShot/10), by = list(PolygonRef, Species, scenario)]
scenbags = unique(scenbags[,.(Species, PolygonRef, AvgNoShot, scenario)])
file = 'C:/Users/lada/Git/shiny/test3/Data'
setnames(scenbags, c('Species', 'PolyRefNum', 'Numbers', 'scenario'))
# write.table(scenbags, file.path(file, 'snouter3.txt'),  row.names = FALSE, sep = '\t')
nfields = unique(scenbags[Species == 'Greylag' & scenario == 'Barnacle x 0',list(Species, PolyRefNum, scenario)])
nfields =  unique(nfields[, N:=.N, by = list(Species, scenario)][, .(Species, scenario, N)])
setkeyv(nfields, c('Species', 'scenario'))

# ---- Prepare the roost file for shiny.
roosts = fread('c:/MSV/WorkDirectory/GooseRoosts.txt', skip = 1)
setnames(roosts, c('Species', 'Long', 'Lat'))
roosts = UtmToALMaSS(data = roosts, long = 'Long', lat = 'Lat',
 map = 'VejlerneBigMap', subset = TRUE, toalmass = FALSE)
roosts[, c('Long', 'Lat'):=NULL]
setnames(roosts, c('Species', 'Long', 'Lat'))
roosts[, Species:=sapply(Species, ConvertGooseSpeciesType)]
coordinates(roosts) = ~Long+Lat
utm32 = CRS('+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs')
proj4string(roosts) = utm32
roosts = spTransform(roosts, CRS("+init=epsg:4326"))
writeOGR(roosts, dsn = 'C:/Users/lada/Git/shiny/test3/Data', layer = "Roosts", driver = "ESRI Shapefile", overwrite_layer = TRUE)


# ---- Summarize numbers per polygon and Species
sel = c('SeasonNumber', 'Day', 'Polyref', 'Barnacle', 'Pinkfoot', 'Greylag')
forage = fread('c:/MSV/WorkDirectory/GooseFieldForageData.txt', select = sel)
forage[, Month:=month(as.IDate(Day, origin = '2010-01-01'))]
forage[, Day:=NULL]
forage = melt(forage, id.vars = c('SeasonNumber', 'Month', 'Polyref'), value.name = 'Numbers', variable.name = 'Species')
forage[, AvgNum:=round(mean(Numbers)), by = c('SeasonNumber', 'Month', 'Polyref', 'Species')]
forage[, Numbers:=NULL]
forage = forage[AvgNum > 0,]
forage = unique(forage)

#----










ConvertGooseSpeciesType = function(ConvertGooseSpeciesType) {
	# Since the numeric version of switch starts at 1, I convert to character.
	x = as.character(ConvertGooseSpeciesType)
	switch(x,
		'0' = 'Pinkfoot',
		'1' = 'Barnacle',
		'2' = 'Greylag',
		'foobar'
		)
}
