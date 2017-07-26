# WIP. Plot temporal development of distance to roost
library(tidyverse)

# Read the field forage file
col_types <- "iiiiiiiiiiicicc"
forage <- read_tsv("~/ALMaSS/WorkDirectory/GooseFieldForageData.txt",
                   col_types = col_types) %>% 
  select(Season, Day, Polyref, Barnacle, Pinkfoot, Greylag) %>% 
  gather_(value_col = "Numbers", key_col = "Species", gather_cols = c("Barnacle", "Pinkfoot", "Greylag")) %>% 
  filter(Numbers > 0)

# Get the field centroids from the polyref file
poly <- read_tsv("~/ALMaSS/WorkDirectory/VejlerneOpenMay2016PolyRef.txt",
                 skip = 1,
                 col_types = "iiiiiiiii") %>% 
  select(PolyRefNum, CentroidX, CentroidY)

tmp <- left_join(forage, poly, by = c("Polyref" = "PolyRefNum"))

find_closest <- function(x, y, sp) {
  x1 <- c(9954, 21167)
  y1 <- c(16132, 12947)
  if (sp == "Greylag") {
    x1 <- c(x1, 17861, 17472)
    y1 <- c(y1, 9394, 6117)
  }
  
  X <- c(x, x1)
  Y <- c(y, y1)
  m <- matrix(data = c(X, Y), ncol = 2) %>%
    dist() %>%
    as.matrix()
  
  m[2:nrow(m), 1] %>%
    min() %>%
    return()
}

tmp %>% 
  mutate(dist = pmap_dbl(list(CentroidX, CentroidY, Species), .f = find_closest)) %>% 
  group_by(Day, Species) %>% 
  dplyr::summarise(mean_dist = mean(dist)) %>% 
  ggplot(aes(Day, mean_dist)) + geom_line() + facet_wrap(~Species, scales = "free_y")

