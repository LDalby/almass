# Script to visualize almass entities via shiny
library(rgdal)
library(maps)
library(data.table)
# Prepare the map of fields
vejlerne <- readOGR(dsn="e:/Gis/VejlerneMapping", layer="VejlerneFields")
vejlerne = spTransform(vejlerne, CRS("+init=epsg:4326"))
vejlerne = vejlerne[!duplicated(vejlerne@data$majority),]  # Some duplicated polygons needed removing

# Find the order of the polygons:
str(vejlerne, max.level = 2)
orignialorder = row.names(vejlerne)
head(orignialorder)
entity = fread('o:/ST_LandskabsGenerering/temp/ReclassTestData/HS1Pinkfoot2.csv')
# setkey(entity, 'PolyRefNum')

DTvejlerne = as.data.table(vejlerne@data)[,.(majority)]
setnames(DTvejlerne, 'PolyRefNum')
DTvejlerne[, roworder:=orignialorder,]  # needed to restore order after merge.
# setkey(DTvejlerne, 'PolyRefNum')
joined = merge(DTvejlerne, entity, all.x = TRUE, by = 'PolyRefNum')
vejlerne@data = joined[match(orignialorder, roworder),]
spplot(vejlerne, 'Numbers', col = 'lightgrey')

polyswithbirds = joined[!is.na(Numbers), roworder]
vejlmap = SpatialPolygons2map(vejlerne, namefield = 'roworder')

mapnames = map(vejlmap, namesonly = TRUE)  # the roworder and now contains "duplicates" as in xx:1 and xx:2
# this is from polygons with holes (e.g. a lake)
getfirst = function(x) {stringr::str_split(x, ":")[[1]][1]}
stripmapnames = sapply(mapnames, FUN = getfirst)
cols = rep('white', length(mapnames))
cols[match(polyswithbirds, mapnames)] = 'blue' 
cols[which(mapnames %in% polyswithbirds)] = 'red' 
cols[match(polyswithbirds, stripmapnames)] = 'green' 
x11()
map(vejlmap, fill= TRUE, col = cols)



