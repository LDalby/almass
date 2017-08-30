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
         ObsDato = ymd_hms(ObsDato)) # %>% 
  # filter(hour(ObsDato) > 11 & hour(ObsDato) < 13)

obs %>% 
  semi_join(y = vejlerne_polys, by = "PolyID") %>% 
  mutate(Date = ifelse(month(ObsDato) < 7, month(ObsDato) + 12, month(ObsDato)),
         Species = recode(ArtID,
                          `63` = "Pinkfoot",
                          `67` = "Barnacle",
                          `59` = "Greylag")) %>% 
  dplyr::select(Date, Species, Antal) %>% 
  filter(!is.na(Antal),
         Species %in% c("Pinkfoot", "Greylag", "Barnacle")) %>% 
  group_by(Date, Species) %>% 
  summarise(mean_flocksize = mean(Antal),
            max_flocksize = max(Antal),
            min_flocksize = min(Antal)) %>%  
  ggplot(aes(Date, max_flocksize, color = Species)) +
  geom_line() +
  geom_point() +
  scale_color_colorblind() +
  theme_fivethirtyeight() + 
  ggtitle("Max flock size per month", subtitle = "Field data up until June 2016")


# Simulated
resultpath <- '~/ALMaSS/WorkDirectory/'
coltypes = "iiiiiiiiiiiidddddcddicc"
forage <- read_tsv(file.path(resultpath, 'GooseFieldForageData.txt'), col_types = coltypes) %>% 
  mutate(Day = Day - 365, Date = as.Date(Day, origin = as.Date('2009-01-01'))) %>% 
  filter(month(Date) %in% c(8:12,1:3), Geese > 0) %>% 
  ClassifyHabitatUse(species = 'goose', timed = TRUE)

dists1 <- forage %>% 
  dplyr::select(Day, BarnacleTimed, PinkfootTimed, GreylagTimed) %>% 
  mutate(ObsDato = as.Date(Day, origin = '2014-01-01'),
         month = month(ObsDato)) %>% 
  filter(month %in% c(9:12,1:3)) %>% 
  dplyr::select(-Day) %>% 
  gather_(key_col = 'Species', value_col = 'Numbers', gather_cols = c("BarnacleTimed", "PinkfootTimed", "GreylagTimed")) %>% 
  filter(Numbers != 0) %>% 
  mutate(Species = recode(Species, 
                          "BarnacleTimed" = "Barnacle",
                          "PinkfootTimed" = "Pinkfoot",
                          "GreylagTimed" = "Greylag"),
         month = ifelse(month < 7, month + 12, month)) %>% 
  group_by(Species, month) %>% 
  summarise(mean_flocksize = mean(Numbers),
            max_flocksize = max(Numbers),
            min_flocksize = min(Numbers))
  dists1 %>% 
  ggplot(aes(month, mean_flocksize, color = Species)) +
  geom_line() +
  geom_point() +
  scale_color_colorblind() +
  theme_fivethirtyeight() + 
  ggtitle("Max flock size per month", subtitle = "Simulated data")

         







