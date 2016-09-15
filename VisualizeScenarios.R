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
scenariodirs = c(scenariodirs, c('WD31', 'WD32', 'WD32', 'WD33', 'WD34', 'WD35', 'WD36', 'WD37', 'WD38', 'WD39', 'WD40'))
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
              "Pinkfoot x 2", "January hunting", "1.5 x efficiency", "Hunt once a week", "Hunt twice a week", "Only weekend hunting",
              "No checkers", "Hunters teaming up", "Doubling of hunters", "Team up and check", "Hunt twice a week, but check",
              "All hunters checkers")
thelist[, Scenario:=factor(Scenario, levels = plotorder)]
# thelistfile = file.path('o:/ST_GooseProject/ALMaSS/Scenarios/', paste0("Scenarios ", Sys.Date(), ".txt"))
# write.table(thelist, file = thelistfile, row.names = FALSE)
p = ggplot(thelist, aes(Scenario, mean)) + 
	 geom_pointrange(aes(ymin = min, ymax = max, color = Species), position=position_dodge(width=0.2)) + 
	 scale_color_viridis(discrete=TRUE, guide = guide_legend(title = "Art")) + 
	 ylab('Totalt udbytte') + ylim(0, thelist[, max(TotalBag)]) +  theme_dark()
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
write.table(thelist, file = 'o:/ST_GooseProject/ALMaSS/Scenarios/ScenarioHuntingBags2.txt', row.names = FALSE)
