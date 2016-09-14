# Write reclassification file
# Date: 23 August 2016
# Author: Lars Dalby

library(data.table)
library(ralmass)
library(rgdal)

#---- Prepare the map of fields
vejlerne = readOGR(dsn="e:/Gis/VejlerneMapping", layer="VejlerneFields")
vejlerne = spTransform(vejlerne, CRS("+init=epsg:4326"))
vejlerne = vejlerne[, "majority"]
names(vejlerne) =  "Polyref"
# vejlerne = vejlerne[!vejlerne$Polyref %in% c(134266, 136277,156216,163713,139680,141133),]
bb = bbox(vejlerne)
# writeOGR(vejlerne[, "majority"], dsn = "e:/Gis/VejlerneMapping", layer = "Fields", driver = "ESRI Shapefile", overwrite_layer = TRUE)

# ---- Prepare the roost file for shiny.
roosts = fread('c:/MSV/WorkDirectory/GooseRoosts.txt', skip = 1)
setnames(roosts, c('Species', 'Long', 'Lat'))
roosts = UtmToALMaSS(data = roosts, long = 'Long', lat = 'Lat',
 map = 'VejlerneBigMap', subset = TRUE, toalmass = FALSE)
roosts[, c('Long', 'Lat'):=NULL]
setnames(roosts, c('Species', 'Long', 'Lat'))
roosts = roosts[5:8,]
roosts[, Species:=c('Alle', 'Alle', 'Grågås', 'Grågås')]
coordinates(roosts) = ~Long+Lat
utm32 = CRS('+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs')
proj4string(roosts) = utm32
rm(utm32)
roosts = spTransform(roosts, CRS("+init=epsg:4326"))
# writeOGR(roosts, dsn = 'C:/Users/lada/Git/shiny/test3/Data', layer = "Roosts", driver = "ESRI Shapefile", overwrite_layer = TRUE)
save(list = ls(), file = file.path('C:/Users/lada/Git/shiny/test3/Data', 'maps.RData'))

#---- Visualise hunting bag
hb = fread('o:/ST_GooseProject/ALMaSS/Scenarios/Scenario09092016/TheHuntingbagFiles.txt',
			 drop = c('Day', 'HunterRef', 'GameType'))
# nseason = length(hb[,unique(SeasonNumber)])
# hb[,SeasonNumber:=NULL]
# hb[, AvgNoShot:=ceiling(mean(NoShot)/nseason), by = list(Scenario, PolygonRef, Species)]
# hb[,NoShot:=NULL]
hb = unique(hb)
# setnames(hb, new = c('Polyref', 'Udbytte'), old = c('PolygonRef', 'AvgNoShot'))
setnames(hb, new = c('Polyref', 'Udbytte'), old = c('PolygonRef', 'NoShot'))
# setkeyv(hb, c('Polyref', 'Scenario', 'Species'))
setkeyv(hb, c('Polyref', 'Scenario', 'Species', 'SeasonNumber'))
file = 'C:/Users/lada/Git/shiny/test3/Data'
# write.table(hb, file.path(file, 'snouter4.txt'),  row.names = FALSE, sep = '\t')

# ---- Visualise number of birds
nb = fread('o:/ST_GooseProject/ALMaSS/Scenarios/Scenario09092016/TheForageFiles.txt')
# nseason = length(nb[,unique(SeasonNumber)])
# nb[,SeasonNumber:=NULL]
# AvgNum is mean of the season.
# nb[, SeasonAvg:=ceiling(sum(AvgNum)/nseason), by = list(Scenario, Polyref, Species)]
# nb[,AvgNum:=NULL]
nb = unique(nb)
# setnames(nb, old = 'SeasonAvg', new = c('Antal'))
setnames(nb, old = 'AvgNum', new = c('Antal'))
# setkeyv(nb, c('Polyref', 'Scenario', 'Species'))
setkeyv(nb, c('Polyref', 'Scenario', 'Species', 'SeasonNumber'))

# Merge the two data sets?
bag = merge(nb, hb, all = TRUE)
bag[Polyref == 1,]
bag = melt(bag, id.vars = c('Polyref', 'Scenario', 'Species'), value.name = 'Numbers', variable.name = 'Entity')
bag = bag[complete.cases(bag),]
# write.table(bag, file.path(file, 'snouter4.txt'),  row.names = FALSE, sep = '\t')
bag[, Entity:=as.character(Entity)]

totalbag = fread('o:/ST_GooseProject/ALMaSS/Scenarios/Scenarios 2016-09-12.txt')
save(list = c("bag", "totalbag"), file = file.path(file, 'bag.RData'))


library(viridis)
getvir = function(x) {
	vir = viridis(255)
	if(x == 0) {return(vir[1])}
	if(x != 0) {return(vir[ceiling(length(vir)*x)])}
}
colorNumeric(getvir, 1:10)