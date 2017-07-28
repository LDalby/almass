# WIP. Plot temporal development of distance to roost
library(tidyverse)
library(ggthemes)
library(devtools)

install_github("ldalby/ralmass", ref = "devel")

library(ralmass)

# Read the field forage file
col_types <- "iiiiiiiiiiicicc"
col_types <- "iiiiiiiiiiiidddddcddicc"
forage <- read_tsv("~/ALMaSS/WorkDirectory/GooseFieldForageData.txt",
                   col_types = col_types) %>% 
  select(Season, Day, Polyref, Barnacle, Pinkfoot, Greylag) %>% 
  gather_(value_col = "Numbers", key_col = "Species", gather_cols = c("Barnacle", "Pinkfoot", "Greylag")) %>% 
  filter(Numbers > 0) %>% 
  mutate(week = week(as.Date(Day, origin = "2015-01-01"))) %>% 
  mutate(week = if_else(week < 25, week + 55, week))
  

# Get the field centroids from the polyref file
poly <- read_tsv("~/ALMaSS/WorkDirectory/VejlerneOpenMay2016PolyRef.txt",
                 skip = 1,
                 col_types = "iiiiiiiii") %>% 
  select(PolyRefNum, CentroidX, CentroidY)

tmp <- left_join(forage, poly, by = c("Polyref" = "PolyRefNum"))

p <- tmp %>% 
  mutate(dist = pmap_dbl(list(CentroidX, CentroidY, Species), .f = find_closest)) %>% 
  group_by(Season, week, Species) %>% 
  dplyr::summarise(mean_dist = mean(dist)) %>% 
  # ggplot(aes(as.Date(Day - (365 * Season), origin = "2015-01-01"), mean_dist/1000)) + 
  ggplot(aes(week, mean_dist/1000)) + 
    geom_line(aes(color = factor(Season))) +
    facet_wrap(~Species, scales = "free_y") +
    ylab("Mean distance (km)") + 
    xlab("Julian week") +
    scale_color_tableau(guide = guide_legend(title = "Season"))
    

  p <- p + scale_x_date(date_breaks = "1 month", date_labels = "%b", limits = c(as.Date("2015-09-01", "%Y-%m-%d"), as.Date("2016-03-31", "%Y-%m-%d"))) 
  p <- p + scale_color_tableau(guide = guide_legend(title = "Season"))
  

  col_types <- "iiiiiiiiiiiidddddcddicc"
  full_forage <- read_tsv("~/ALMaSS/WorkDirectory/GooseFieldForageData.txt", col_types = col_types) %>% 
    select(Season, Day, VegHeight, starts_with("Grass"), Grain, Maize) %>% 
    mutate(Day = Day - 365)

  food <- full_forage %>% 
    # filter(Season == 1) %>%
    mutate(week = week(as.Date(Day, origin = "2015-01-01"))) %>% 
    mutate(week = if_else(week < 25, week + 55, week)) %>% 
    group_by(Season, week) %>% 
      summarise(mean_vegheight = mean(VegHeight, na.rm = TRUE),
                mean_grain = mean(Grain, na.rm = TRUE),
                mean_maize = mean(Maize, na.rm = TRUE))
  
  vh <- food %>% 
      ggplot(aes(week, mean_vegheight)) +
      geom_line(aes(color = factor(Season))) + 
      theme_bw() +
      ylab("Average vegetation height (cm)") + 
      xlab("Julian week") + 
      scale_y_continuous(limits = c(0,NA)) +
    scale_color_tableau() + 
    theme(legend.position = "none")
      

  g <- food %>%
    ggplot(aes(week, mean_grain)) +
    geom_line(aes(color = factor(Season))) + 
    theme_bw() +
    ylab("Average grain across fields (kJ/m2)") + 
    xlab("Julian week") + 
    scale_y_continuous(limits = c(0,NA)) +
    scale_color_tableau() + 
    theme(legend.position = "none")
    
    
  m <- food %>%
    ggplot(aes(week, mean_maize)) +
    geom_line(aes(color = factor(Season))) + 
    theme_bw() +
    ylab("Average maize across fields (kJ/m2)") + 
    xlab("Julian week") + 
    scale_y_continuous(limits = c(0,NA)) + 
    scale_color_tableau() +
    theme(legend.position = "none")
  

  gridExtra::grid.arrange(p, vh, g, m, layout_matrix = rbind(c(1,1,1),c(2,3,4)))  
  
  
  forage %>%
    group_by(Season, week, Species) %>% 
    summarise(n_polyref = n_distinct(Polyref)) %>% 
    ggplot(aes(week, n_polyref)) +
    geom_line(aes(color = factor(Season))) +
    facet_wrap(~Species) +
    scale_color_tableau(guide = guide_legend(title = "Season")) + 
    ylab("Number of distinct fields")
  