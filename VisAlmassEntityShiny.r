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

vejlmap = SpatialPolygons2map(vejlerne, namefield = 'PolyRefNum')

polyrefs = map(vejlmap, plot = FALSE)$names
cols = rep('white', length(polyrefs))
cols[!is.na(joined[,Numbers])] = 'blue'
map(vejlmap, fill= TRUE, col = cols)
x11()
spplot(vejlerne, 'Numbers', col = 'lightgrey')




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