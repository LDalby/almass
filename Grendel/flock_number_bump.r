library(tidyverse)
library(ggvis)
library(ggjoy)


resultpath <- '~/ALMaSS/WorkDirectory/'
o_drive <- "/run/user/1000/gvfs/smb-share:server=uni.au.dk,share=dfs/ST_GooseProject/"
git_dir <- "~/git/"


state <- read_tsv(file.path(resultpath, "GooseStateStats.txt"),
                  col_types = "iii") %>% 
  mutate(Day = Day - 365) 

state %>% 
  filter(Day < 285) %>%
  ggvis(~Day, ~N) %>% 
  layer_lines() %>% 
  layer_points(stroke := "black",
               fill := "grey") %>% 
  add_axis("y", title = "Number of calls to ChooseForageLocation",
           title_offset = 70, 
           properties = axis_props(labels = list(fontSize = 14),
                                   title = list(fontSize = 14))) %>% 
  add_axis("x", title = "Day",
           properties = axis_props(labels = list(fontSize = 14),
                                   title = list(fontSize = 14))) %>% 
  add_tooltip(function(df) paste0("Day: ", df$Day))


#  

coltypes = "iiiiiiiiiiiidddddcddicc"
forage <- read_tsv(file.path(resultpath, 'GooseFieldForageData.txt'),
                   col_types = coltypes) %>% 
  mutate(Day = Day - 365, 
         Date = as.Date(Day, origin = as.Date('2009-01-01'))) %>% 
  filter(month(Date) %in% c(8:12,1:3)) %>% 
  ClassifyHabitatUse(species = 'goose', timed = TRUE)

forage %>%
  dplyr::select(Day, GreylagTimed, BarnacleTimed, PinkfootTimed, Season) %>%
  gather_(value_col = 'Numbers', key_col = 'Species', gather_cols = c("GreylagTimed", "BarnacleTimed", "PinkfootTimed")) %>%
  filter(Numbers > 0) %>%
  group_by(Day, Species) %>%
  mutate(N = n()) %>% 
  dplyr::select(Day, N) %>% 
  distinct() -> foo

foo %>% 
  ungroup() %>% 
  # filter(Day < 285) %>%
  ggvis(~Day, ~N) %>% 
    layer_lines() %>% 
    layer_points(size := 75) %>% 
    add_tooltip(function(df) paste0("Day: ",df$Day))

# The number of birds (summed from timed counts)
forage %>% 
  dplyr::select(Day, PinkfootTimed) %>% 
  group_by(Day) %>%
  summarise(n = sum(PinkfootTimed)) %>% 
  ggvis(~Day, ~n) %>% 
    layer_lines() %>% 
    layer_points(size := 75) %>% 
    add_tooltip(function(df) paste0("Day: ",df$Day))

# Ridge plot of flock size distributions ----
forage %>% 
  filter(Day %in% 270:280,
         PinkfootTimed > 0) %>% 
  ggplot(aes(x = PinkfootTimed, y = as.character(Day))) + 
    geom_joy(rel_min_height = 0.01) + 
    scale_x_continuous(expand = c(0,0)) +
    scale_y_discrete(expand = c(0.01, 0)) + 
    xlab("Flock size") + 
    ylab("Day") +
    theme(axis.text = element_text(size = 12),
          axis.title = element_text(size = 14))
# Spring
forage %>% 
  filter(Day %in% 420:430,
         PinkfootTimed > 0) %>% 
  ggplot(aes(x = PinkfootTimed, y = as.character(Day))) + 
    geom_joy(rel_min_height = 0.01) + 
    scale_x_continuous(expand = c(0,0)) +
    scale_y_discrete(expand = c(0.01, 0)) + 
    xlab("Flock size") + 
    ylab("Day") +
    ggtitle("Spring") +
    theme(axis.text = element_text(size = 12),
          axis.title = element_text(size = 14))


