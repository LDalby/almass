devtools::install_github("tidyverse/ggplot2")
library(ggplot2)
library(sf)
library(tidyverse)
library(readxl)
library(lubridate)

o_drive <- "/run/user/1000/gvfs/smb-share:server=uni.au.dk,share=dfs/ST_GooseProject/"
fdata <- st_read(file.path(o_drive, "/Field data/Fugledata/PolyAndObsJune2016/fugledata_polygon.shp"))
vejlerne <- st_read(file.path(o_drive, "/ALMaSS/GooseModelTesting/vejlerne_outline.shp")) %>% 
  st_transform(crs = "+proj=longlat +datum=WGS84 +no_defs")


vejlerne_polys <- st_intersection(fdata, vejlerne)
vejlerne_polys %>%
  ggplot() + geom_sf()  # Okay fine. 

# Filter the observations with the poly ids
obs <- read_excel(file.path(o_drive, "/Field data/Fugledata/PolyAndObsJune2016/Observationer_fugledata_20160616.xlsx"),
                  sheet = "Observationer") %>% 
  mutate(PolyID = as.numeric(PolygonID),
         ObsDato = ymd_hms(ObsDato)) %>% 
  filter(hour(ObsDato) > 11 & hour(ObsDato) < 13)

obs %>% 
  semi_join(y = vejlerne_polys, by = "PolyID") %>% 
  mutate(Date = if_else(month(ObsDato) < 7, month(ObsDato) + 12, month(ObsDato))) %>% 
  select(Date, ArtID, Antal) %>% 
  filter(!is.na(Antal),
         ArtID %in% c(63, 59, 67)) %>% 
  group_by(Date, ArtID) %>% 
  summarise(mean_flocksize = mean(Antal)) %>% 
  ggplot(aes(Date, mean_flocksize)) +
  geom_point(aes(color = ArtID))



