# Script to visualize almass entities via shiny
library(rgdal)
library(maps)
library(data.table)
# Prepare the map of fields
vejlerne <- readOGR(dsn="e:/Gis/VejlerneMapping", layer="VejlerneFields")
vejlerne = spTransform(vejlerne, CRS("+init=epsg:4326"))

entity = fread('o:/ST_LandskabsGenerering/temp/ReclassTestData/HS1Pinkfoot.txt')
entity[,V2:=NULL]
setnames(entity, c('PolyRefNum', 'Numbers'))
setkey(entity, 'PolyRefNum')

DTvejlerne = as.data.table(vejlerne@data)[,.(majority)]
setnames(DTvejlerne, 'PolyRefNum')
setkey(DTvejlerne, 'PolyRefNum')
joined = merge(DTvejlerne, entity, all.x = TRUE)
vejlerne@data = joined

vejlmap = SpatialPolygons2map(vejlerne, namefield = 'PolyRefNum')



map(vejlmap, plot = FALSE)
spplot(vejlerne, 'Numbers')

#---- 
 data(unemp)
 data(county.fips)

  # define color buckets
  colors = c("#F1EEF6", "#D4B9DA", "#C994C7", "#DF65B0", "#DD1C77", "#980043")
  unemp$colorBuckets <- as.numeric(cut(unemp$unemp, c(0, 2, 4, 6, 8, 10, 100)))
  leg.txt <- c("<2%", "2-4%", "4-6%", "6-8%", "8-10%", ">10%")

  # align data with map definitions by (partial) matching state,county
  # names, which include multiple polygons for some counties
  cnty.fips <- county.fips$fips[match(map("county", plot=FALSE)$names,
    county.fips$polyname)]
  colorsmatched <- unemp$colorBuckets [match(cnty.fips, unemp$fips)]

  # draw map
  map("county", col = colors[colorsmatched], fill = TRUE, resolution = 0,
    lty = 0, projection = "polyconic")
  map("state", col = "white", fill = FALSE, add = TRUE, lty = 1, lwd = 0.2,
    projection="polyconic")
  title("unemployment by county, 2009")
  legend("topright", leg.txt, horiz = TRUE, fill = colors)