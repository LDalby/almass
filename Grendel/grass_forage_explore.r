# Veg heights ----

coltypes = "iiiiiiiiiiiidddddcddicc"
forage <- read_tsv(file.path(resultpath, 'GooseFieldForageData.txt'), col_types = coltypes) %>% 
  mutate(Day = Day - 365, Date = as.Date(Day, origin = as.Date('2009-01-01'))) %>% 
  filter(month(Date) %in% c(8:12,1:3)) %>% 
  ClassifyHabitatUse(species = 'goose', timed = TRUE)







begin <- forage %>%
  filter(Grain > 1,
         Day == 212) %>% 
  dplyr::select(Day, Grain, Polyref)

forage %>%
  filter(Day == 287) %>% 
  dplyr::select(Day, Grain, Polyref) %>% 
  right_join(y = begin, by = "Polyref") %>% 
  View()


forage %>% 
  filter(Geese > 0,
         VegTypeChr == "PermanentGrassTussocky")

forage %>% 
  summarise(Vegtypes = unique(VegTypeChr))
unique(forage$VegTypeChr)

forage %>% 
  filter(Polyref == 147100) %>% 
  ggplot(aes(Day, VegHeight)) + 
  geom_line() + 
  geom_vline(xintercept = 304, color = "blue") + 
  geom_vline(xintercept = 305, color = "blue") + 
  geom_vline(xintercept = 317, color = "blue") + 
  geom_vline(xintercept = 319, color = "blue") + 
  ggtitle("Natural grass", subtitle = "Blue lines indicate days with geese")

forage %>% 
  filter(Polyref == 134266) %>% 
  ggplot(aes(Day, VegHeight)) + 
  geom_line() + 
  ggtitle("PermanentGrassTussocky")

forage %>% 
  filter(Polyref == 147100) %>%
  dplyr::select(Day, VegHeight, Geese) %>% 
  View()


forage %>% 
  filter(VegTypeChr == "NaturalGrass") %>% 
  group_by(Day, Polyref) %>% 
  summarise(mean_height = mean(VegHeight)) %>% 
  ggplot(aes(Day, mean_height)) + 


grassy <- c("NaturalGrass", "PermanentGrassGrazed", "PermanentGrassTussocky", "PermanentSetaside")


forage %>% 
  filter(VegTypeChr %in% grassy) %>% 
  group_by(Day, VegTypeChr) %>%
  summarise(mean_height = mean(VegHeight),
            min_height = min(VegHeight),
            max_height = max(VegHeight),
            median_height = median(VegHeight)) %>%
  ggplot(aes(Day, median_height)) + 
  geom_ribbon(aes(ymin = min_height, ymax = max_height), fill = "grey70") +
  geom_line(aes(y = mean_height)) + 
  facet_wrap(~VegTypeChr) + 
  theme_bw() + 
  ylab("Vegetation height") + 
  ggtitle("Vegetation height",
          subtitle = "Showing range of data and median as black curve. Dashed lines are the optimum heights for the three species \nVariation configs: Max = .5 & min = 0.01") + 
  annotate("segment", x = 212, xend = 454, y = 6.67, yend =  6.67, colour = "blue", linetype = 2) + 
  annotate("segment", x = 212, xend = 454, y = 12.2, yend =  12.2, colour = "green", linetype = 2) + 
  annotate("segment", x = 212, xend = 454, y = 8.32, yend =  8.32, colour = "pink", linetype = 2)

# Winter cereal ---- 


cereal1 <- c("SpringBarley", "SpringBarleySpr", "WinterBarley", "SpringWheat", "WinterWheat", "WinterRye", "Oats")
cereal2 <- c("Triticale", "SpringBarleySeed", "SpringBarleyStrigling", "SpringBarleyStriglingSingle", "SpringBarleyStriglingCulm", "WinterWheatStrigling", "WinterWheatStriglingSingle", "WinterWheatStriglingCulm", "OWinterBarley", "OWinterBarleyExt", "OWinterRye", "SpringBarleyGrass", "SpringBarleyCloverGrass", "OBarleyPeaCloverGrass", "SpringBarleyPeaCloverGrassStrigling", "OSpringBarley", "OSpringBarleyPigs", "OWinterWheatUndersown", "OWinterWheat", "OOats", "OTriticale", "WWheatPControl", "WWheatPToxicControl", "WWheatPTreatment", "AgroChemIndustryCereal", "SpringBarleyPTreatment", "SpringBarleySKManagement", "OSpringBarleyExt", "OSpringBarleyGrass", "OSBarleySilage", "OSpringBarleyClover")
xstart <- 250
forage %>% 
  filter(LastSownVeg %in% c(cereal1, cereal2), 
         Day > 250) %>% 
  group_by(Day, LastSownVeg) %>%
  summarise(mean_height = mean(VegHeight),
            min_height = min(VegHeight),
            max_height = max(VegHeight),
            median_height = median(VegHeight)) %>%
  ggplot(aes(Day, median_height)) + 
  geom_ribbon(aes(ymin = min_height, ymax = max_height), fill = "grey70") +
  geom_line(aes(y = mean_height)) +
  facet_wrap(~LastSownVeg) + 
  theme_bw() +
  ylab("Vegetation height") + 
  ggtitle("Vegetation height for cereal crops",
          subtitle = "Showing range of data and median as black curve. Dashed lines are the optimum heights for the three species \nVariation configs: Max = .5 & min = 0.01") + 
  annotate("segment", x = xstart, xend = 454, y = 6.67, yend =  6.67, colour = "blue", linetype = 2) + 
  annotate("segment", x = xstart, xend = 454, y = 12.2, yend =  12.2, colour = "green", linetype = 2) + 
  annotate("segment", x = xstart, xend = 454, y = 8.32, yend =  8.32, colour = "pink", linetype = 2)






# Grain ----

grainy <- c("SpringBarley", "SpringBarleySpr", "WinterBarley", "SpringWheat", "WinterWheat", "WinterRye", "Oats", "Triticale", "SpringBarleySeed", "SpringBarleyStrigling", "SpringBarleyStriglingSingle", "SpringBarleyStriglingCulm", "WinterWheatStrigling", "WinterWheatStriglingSingle", "WinterWheatStriglingCulm", "OWinterBarley", "OWinterBarleyExt", "OWinterRye", "SpringBarleyGrass", "SpringBarleyCloverGrass", "SpringBarleyPeaCloverGrassStrigling", "OSpringBarley", "OSpringBarleyPigs", "OWinterWheatUndersown", "OWinterWheat", "OOats", "OTriticale", "WWheatPControl", "WWheatPToxicControl", "WWheatPTreatment", "AgroChemIndustryCereal", "SpringBarleyPTreatment", "SpringBarleySKManagement", "OSpringBarleyExt", "OSpringBarleyGrass", "OSpringBarleyClover")

forage %>% 
  # filter(VegTypeChr %in% grainy) %>%
  # filter(str_detect(VegTypeChr, "Clover")) %>%
  filter(Grain > 0) %>%
  dplyr::select(Day, Grain, Polyref, LastSownVeg) %>% 
  group_by(Day, LastSownVeg) %>% 
  summarise(mean_grain = mean(Grain),
            median_grain = median(Grain)) %>% 
  ggplot(aes(Day, mean_grain)) +
  geom_line(aes(color = LastSownVeg)) + 
  ylab("Mean number of grain") + 
  ggtitle("Mean grain per crop type") +
  # scale_color_brewer(palette = "Set3", guide_legend(title = "Crop type")) + 
  scale_color_discrete(guide = guide_legend(title = "Crop type")) +
  theme_bw()
# Plot all the polyrefs
forage %>% 
  # filter(VegTypeChr %in% grainy) %>% 
  filter(Grain > 0, Day > 297 & Day < 301) %>%
  dplyr::select(Day, Grain, Polyref, LastSownVeg) %>% 
  group_by(Day, LastSownVeg) %>% 
  ggplot(aes(Day, Grain)) +
  geom_line(aes(color = factor(Polyref)), alpha = 0.5) + 
  scale_color_discrete(guide = FALSE) +
  ylab("Mean number of grain") + 
  ggtitle("Grain per crop type") +
  facet_wrap(~LastSownVeg, ncol = 3) +
  theme_bw()

refs <- forage %>%
  dplyr::select(Day, BarnacleTimed, Polyref) %>% 
  filter(Day == 298,
         BarnacleTimed > 0) %>%
  pull(Polyref)
  

forage %>% 
  filter(Polyref %in% refs,
         # filter(Polyref %in% c(200470, 106281),
         Geese > 0,
         Day %in% 298) %>% 
  dplyr::select(Day, Grain, LastSownVeg, VegHeight, GrassPinkfoot, PinkfootTimed, BarnacleTimed, GreylagTimed, Polyref) %>% 
  View()

nn <- forage %>% 
  filter(Geese > 0,
         Day %in% 299) %>% 
  pull(LastSownVeg) %>% 
unique()

n8 <- forage %>% 
  filter(Geese > 0,
         Day %in% 298) %>% 
  pull(LastSownVeg) %>% 
  unique()

nn[which(!nn %in% n8)]

forage %>%
  dplyr::select(Day, BarnacleTimed, Polyref) %>% 
  group_by(Day) %>% 
  filter(Day %in% 275:299,
         BarnacleTimed > 0) %>%
  summarise(n = n()) %>% 
  View()





# ggvis test
library(ggvis)
getlabel <- function(df) {
  paste("Polyref:", df$poly)
}
forage %>%
  filter(VegTypeChr == "PotatoesIndustry") %>% 
  mutate(poly = as.factor(Polyref)) %>% 
  ggvis(x = ~Day, y = ~Grain, stroke = ~poly) %>% 
  layer_lines() %>% 
  # layer_points() %>% 
  add_tooltip(getlabel)

getlabel <- function(df) {
  paste("Croptype:", df$VegTypeChr)
}
forage %>% 
  # filter(VegTypeChr %in% grainy) %>%
  # filter(str_detect(VegTypeChr, "Clover")) %>%
  filter(Grain > 0) %>%
  dplyr::select(Day, Grain, Polyref, VegTypeChr) %>% 
  group_by(Day, VegTypeChr) %>% 
  summarise(mean_grain = mean(Grain),
            median_grain = median(Grain)) %>% 
  mutate(VegTypeChr = as.factor(VegTypeChr)) %>% 
  ggvis(~Day, ~mean_grain, stroke = ~VegTypeChr) %>% 
  layer_lines() %>% 
  add_tooltip(getlabel) %>% 
  add_axis("x", title = "Day") %>% 
  add_axis("y", title = "Mean number of grain")
  
forage %>%
  filter(Polyref == 139223) %>% 
  ggvis(x = ~Day, y = ~Grain) %>% 
  layer_lines()
  
forage %>%
  filter(Polyref == 84448) %>% 
  View()




# Calculate the decay rate
# Find the mean early in the season
# Find the mean 75 days later (or in mid Nov)
# Calculate the proportion left
the_max <- forage %>% 
  filter(Grain > 0,
         Day == 257) %>%
  dplyr::select(Day, Grain) %>% 
  group_by(Day) %>% 
  summarise(mean_grain = mean(Grain)) %>% 
  # slice(which.max(mean_grain)) %>% 
  # dplyr::select(Day, mean_grain)
  pull(mean_grain)


the_decayed <- forage %>% 
  filter(Grain > 0,
         Day == 318) %>% 
  dplyr::select(Day, Grain) %>% 
  group_by(Day) %>% 
  summarise(mean_grain = mean(Grain)) %>% 
  # dplyr::select(Day, mean_grain)
  pull(mean_grain)

the_decayed/the_max

ConvertSimDay(334)

# Find the fields with grain on them on Day 318
with_grain <- forage %>% 
  filter(Grain > 0,
         Day == 318) %>% 
  dplyr::select(Polyref) %>% 
  distinct() %>% 
  pull(Polyref)
# Subset the same fields on day 257

the_with_grain_sep <- forage %>% 
  filter(Polyref %in% with_grain,
         Grain > 0,
         Day == 257) %>%
  dplyr::select(Polyref) %>% 
  distinct() %>% 
  pull(Polyref)
  
all_equal(with_grain, the_with_grain_sep)  


the_max <- forage %>% 
  filter(Polyref %in% the_with_grain_sep,
         Grain > 0,
         Day == 257) %>%
  dplyr::select(Day, Grain) %>% 
  group_by(Day) %>% 
  summarise(mean_grain = mean(Grain)) %>% 
  # slice(which.max(mean_grain)) %>% 
  # dplyr::select(Day, mean_grain)
  pull(mean_grain)

the_decayed <- forage %>% 
  filter(Polyref %in% the_with_grain_sep,
         Grain > 0,
         Day == 318) %>% 
  dplyr::select(Day, Grain) %>% 
  group_by(Day) %>% 
  summarise(mean_grain = mean(Grain)) %>% 
  # dplyr::select(Day, mean_grain)
  pull(mean_grain)

the_decayed/the_max


# Min forage rate through the season ----
energy <- fread(file.path(resultpath, 'GooseEnergeticsData.txt'), showProgress = FALSE, drop = "BodyCondition") %>% 
  as.tibble() %>% 
  mutate(Day = Day - 365,
         Date = as.Date(Day, origin = as.Date('2009-01-01'))) %>% 
  dplyr::select(Day, GooseType, MinForageRate) %>% 
  distinct()

energy %>% 
  filter(str_detect(GooseType, "NB")) %>% 
  mutate(GooseType = recode(GooseType,
                            "BGNB" = "Barnacle",
                            "GLNB" = "Greylag",
                            "PFNB" = "Pinkfoot")) %>% 
  ggplot(aes(Day, MinForageRate)) + 
  geom_line() + 
  facet_wrap(~GooseType) + 
  ggtitle("Minimum forage rate through the season", 
          subtitle = "Main trend driven by daylength. Variation is temperature dependent.") +
  ylab("Minimum forage rate (kJ/min")
  
bgf <- energy %>% filter(GooseType == "BGF") %>% pull(MinForageRate)
bgnb <- energy %>% filter(GooseType == "BGNB") %>% pull(MinForageRate)  
all.equal(bgf, bgnb)
