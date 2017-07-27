# WIP. Plot temporal development of distance to roost
library(tidyverse)
library(ggthemes)
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

find_closest <- function(x, y, species) {
  if (species %in% c("Pinkfoot", "Barnacle")) {
    x1 <- c(9954, 21167)
    y1 <- c(16132, 12947)  
  }
  
  if (species == "Greylag") {
    x1 <- c(9954, 21167, 17861, 17472)
    y1 <- c(16132, 12947, 9394, 6117)
  }
  
  X <- c(x, x1)
  Y <- c(y, y1)
  m <- matrix(data = c(X, Y), ncol = 2, byrow = FALSE) %>%
    dist() %>%
    as.matrix()
  
  m[2:nrow(m), 1] %>%
    min() %>%
    return()
}

p <- tmp %>% 
  mutate(dist = pmap_dbl(list(CentroidX, CentroidY, Species), .f = find_closest)) %>% 
  group_by(Season, Day, Species) %>% 
  dplyr::summarise(mean_dist = mean(dist)) %>% 
  ggplot(aes(as.Date(Day - (365 * Season), origin = "2015-01-01"), mean_dist/1000)) + 
    geom_line(aes(color = factor(Season))) +
    facet_wrap(~Species, scales = "free_y") +
    ylab("Mean distance (km)") + 
    xlab("Date")
    

  p <- p + scale_x_date(date_breaks = "1 month", date_labels = "%b", limits = c(as.Date("2015-09-01", "%Y-%m-%d"), as.Date("2016-03-31", "%Y-%m-%d"))) 
  p <- p + scale_color_tableau(guide = guide_legend(title = "Season"))
  
