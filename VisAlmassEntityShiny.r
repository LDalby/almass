# Script to visualize almass entities via shiny
library(rgdal)

# Prepare the map of fields
vejlerne <- readOGR(dsn="C:/Users/lada/Dropbox/Shiny/Vejlerne", layer="VejlerneFields")
vejlerne@data<-vejlerne@data[, match(c('OBJECTID', 'PolyRefNum'), names(vejlerne))]
vejlerne = spTransform(vejlerne, CRS("+init=epsg:4326"))
# Script to visualize almass entities via shiny
