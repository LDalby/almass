#' Calculate pseudo centroid for polygons
#'
#' Calculate the mean x and mean y coordinate for a number of polygons
#' Be aware that this is only an approximation. With funny shaped polygons 
#' you might get strange results. Particularly if the vertices are not
#' are not evenly spaced. 
#' @param data data.frame The raw file from the bird database
#' @param project logical Should the input coordinates be projected to UTM?
#' @return data.frame A data.frame with the polygon id and the pseudo centroid
#' @export
library(rgdal)
CalcPseudoCentroid = function(data, project = TRUE)
{
  data$PolygonData = stringr::str_replace_all(data$PolygonData, "\\(", "")
  data$PolygonData = stringr::str_replace_all(data$PolygonData, "\\)", "")
  polygons = stringr::str_split(data$PolygonData, ',')
  polygons = lapply(polygons, FUN = stringr::str_trim)
  polygons = lapply(polygons, FUN = as.numeric)
  
  GetMean = function(x){
    return(c(mean(x[which(1:length(x) %% 2 == 0)]), mean(x[which(1:length(x) %% 2 != 0)])))
  }
  
  polygons = lapply(polygons, FUN = GetMean)
  polygons = unlist(polygons)
  polygons = data.frame('PolyID' = data$PolyID, 
                        'long' = polygons[which(1:length(polygons) %% 2 != 0)],
                        'lat' = polygons[which(1:length(polygons) %% 2 == 0)])
  
  if (project)
  {
    sp.polygons = polygons
    sp::coordinates(sp.polygons) = ~long+lat
    sp::proj4string(sp.polygons) = sp::CRS('+proj=longlat +datum=WGS84')
    sp.polygons = sp::spTransform(sp.polygons, sp::CRS('+proj=utm +zone=32 +ellps=WGS84 +datum=WGS84 +units=m +no_defs'))
    polygons$UtmX = sp.polygons@coords[,1]
    polygons$UtmY = sp.polygons@coords[,2]
  }
  # return(data.table::as.data.table(polygons))
  return(as.tibble(polygons))
}

