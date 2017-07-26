# WIP. Plot temporal development of distance to roost
library(tidyverse)

# Read the field forage file
col_types <- "iiiiiiiiiiicicc"
forage <- read_tsv("~/ALMaSS/WorkDirectory/GooseFieldForageData.txt",
                   col_types = col_types) %>% 
  gather()
