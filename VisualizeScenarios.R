# Collect and visualize results from full model scenarios
# Date: 12082016
# Author: Lars Dalby

library(data.table)
library(ralmass)
library(ggplot2)
library(viridis)

pth = 'e:/almass/WorkDirectories/Goose/'
dirs = dir(pth)
scenariodirs = dirs[grep('WD2', dirs)]  # For the full model scenarios
scenariodirs = c(scenariodirs, c('WD31', 'WD32', 'WD32', 'WD33', 'WD34', 'WD35', 'WD36', 'WD37', 'WD38', 'WD39', 'WD40', 'WD41', 'WD42',
                                 'WD43'))
# scenariodirs = scenariodirs[c(1:6, 9)]
resultlist = vector('list', length(scenariodirs))
# ---- Visualize scenarios
for (i in 1:length(resultlist)) {
  respath = file.path(pth, scenariodirs[i], 'HuntingBagRecord.txt')
  thescenario = readLines(file.path(pth, scenariodirs[i], 'ParameterValues.txt'))
  sim = fread(respath)
  sim[, Species:=sapply(GameType, ConvertGameType)]
  sim[, NoShot:=.N, by = list(Species, HunterRef, SeasonNumber)]
  sim = unique(sim[, .(HunterRef, Species, NoShot, SeasonNumber)])
  sim[, TotalBag:=sum(NoShot), by = list(Species, SeasonNumber)]
  sim = unique(sim[,.(TotalBag, Species, SeasonNumber)])
  sim[, Scenario:=thescenario]
  resultlist[[i]] = sim
}
thelist = rbindlist(resultlist)
thelist[, mean:=round(mean(TotalBag)), by = c('Scenario', 'Species')]
thelist[, min:=min(TotalBag), by = c('Scenario', 'Species')]
thelist[, max:=max(TotalBag), by = c('Scenario', 'Species')]
plotorder = c("Baseline", "Barnacle x 0", "Barnacle x 2", "Barnacle x 4", "Barnacle x 10", "Barnacle early arrival", "Greylag x 2", "Greylag x 0.5",
              "Pinkfoot x 2", "January hunting", "1.5 x efficiency", "Hunt once a week", "Hunt twice a week","Pinkfoot baglimit 5", "Pinkfoot baglimit 10","Pinkfoot baglimit 15", "Only weekend hunting",
              "No checkers", "Hunters teaming up", "Doubling of hunters", "Team up and check", "Hunt twice a week, but check",
              "All hunters checkers")
thelist[, Scenario:=factor(Scenario, levels = plotorder)]
# thelistfile = file.path('o:/ST_GooseProject/ALMaSS/Scenarios/', paste0("Scenarios ", Sys.Date(), ".txt"))
# write.table(thelist, file = thelistfile, row.names = FALSE)
# Read the list:
if ("Linux" == sysinfo[match("sysname", names(sysinfo))]) {
  o_drive <- "/run/user/1000/gvfs/smb-share:server=uni.au.dk,share=dfs/ST_GooseProject/"
 }
if ("Windows" == sysinfo[match("sysname", names(sysinfo))]) {
   o_drive <- "o:/ST_GooseProject/"
}

thelist <- read_delim(file.path(o_drive, "/ALMaSS/Scenarios/Scenarios 2016-09-15.txt"),
                      delim = " ",
                      col_types = "iciciii") %>% 
  mutate(Species = as.factor(Species))
max_totalbag <- thelist %>% 
  summarise(max_totalbag = max(TotalBag)) %>% 
  pull(max_totalbag)
# Plot it all
p = ggplot(thelist, aes(Scenario, mean)) + 
	 geom_pointrange(aes(ymin = min, ymax = max, color = Species), position=position_dodge(width=0.2)) + 
	 scale_color_viridis(discrete=TRUE, guide = guide_legend(title = "Species")) + 
	 ylab('Total bag') + ylim(0, max_totalbag) +  theme_dark()
p = p + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust =1))
p

#---- Chunk to collect huntingbagrecords  
for (i in 1:length(resultlist)) {
  respath = file.path(pth, scenariodirs[i], 'HuntingBagRecord.txt')
  tmp = fread(respath)
  paramvalpath = file.path(pth, scenariodirs[i], 'ParameterValues.txt')
  scenario = readLines(paramvalpath)
  tmp[,scenario:=scenario]
  resultlist[[i]] = tmp
}
thelist = rbindlist(resultlist)
thelist
# write.table(thelist, file = 'o:/ST_GooseProject/ALMaSS/Scenarios/ScenarioHuntingBags2.txt', row.names = FALSE)

# ---- Do presentation plots:
library(ggplot2)
presentationplot = function(plotdata, scenarios) {
  d <- plotdata %>% 
    filter(Scenario %in% scenarios) %>% 
    mutate(Scenario = fct_relevel(Scenario, "Baseline"))
  
  max_totalbag <- d %>% 
    summarise(max_totalbag = max(TotalBag)) %>% 
    pull(max_totalbag)
  
  p <- d %>% 
   ggplot(aes(Scenario, mean)) + 
   geom_pointrange(aes(ymin = min, ymax = max, color = Species), position = position_dodge(width = 0.2)) + 
   scale_color_colorblind(guide = guide_legend(title = "")) + 
   ylab('Annual hunting bag') + 
   xlab('') +
   scale_y_continuous(limits = c(0, max_totalbag)) + 
   theme_bw() + 
   theme(
    # axis.text.x = element_text(angle = 90, hjust = 1, vjust = 1, size = 15),
  axis.text.x = element_text(size = 15),
              axis.text.y = element_text(size = 12), axis.title.y = element_text(size = 15),
              legend.text = element_text(size = 12),
              legend.position = "top")
return(p)
}

# thelist = fread('o:/ST_GooseProject/ALMaSS/Scenarios/Scenarios 2016-09-15.txt')

# thelist[, Species:=as.factor(Species)]
# levels(thelist$Species) = c('Gr?g?s', 'Kortn?bbet g?s')
# G?seplots.
subset = c('Baseline', 'Greylag x 0.5', 'Greylag x 2', 'Pinkfoot x 2')
p <- thelist %>% 
    presentationplot(scenarios = subset)
p + scale_y_continuous(limits = c(0, 3000),
                     breaks = seq(0, 2500, 500))
# png(filename = 'o:/ST_GooseProject/Presentations/Graa.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()

# Bramg?s
subset = c('Baseline', 'Barnacle x 0', 'Barnacle x 4')
p <- thelist %>% 
  presentationplot(scenarios = subset)
# png(filename = 'o:/ST_GooseProject/Presentations/Bram.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()

# Checkers
subset = c('Baseline', 'No checkers', 'All hunters checkers')
p <- thelist %>% 
  presentationplot(scenarios = subset)
# png(filename = 'o:/ST_GooseProject/Presentations/Tjekker.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Januar jagt
subset = c('Baseline', 'January hunting')
p <- thelist %>% 
  presentationplot(scenarios = subset)
# png(filename = 'o:/ST_GooseProject/Presentations/Janjagt.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Jagtadf?rd
subset = c('Baseline', '1.5 x efficiency', 'Hunters teaming up', 'Doubling of hunters')
p <- thelist %>% 
  presentationplot(scenarios = subset)
# png(filename = 'o:/ST_GooseProject/Presentations/JagtAdf?rd.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Jagtadf?rd II
subset = c('Baseline', 'Hunt once a week', 'Hunt twice a week', 'Pinkfoot baglimit 10', 'Pinkfoot baglimit 15')
p <- thelist %>% 
  presentationplot(scenarios = subset)
p
# png(filename = 'o:/ST_GooseProject/Presentations/JagtAdf?rd2.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()


