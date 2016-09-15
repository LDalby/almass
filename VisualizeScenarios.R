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

# ---- Do presentation plots:
library(ggplot2)
presentationplot = function(plotdata) {
p = ggplot(plotdata, aes(Scenario, mean)) + 
   geom_pointrange(aes(ymin = min, ymax = max, color = Species), position=position_dodge(width=0.2)) + 
   scale_color_viridis(discrete=TRUE, guide = guide_legend(title = "")) + 
   ylab('Årligt udbytte') + 
   ylim(0, plotdata[, max(TotalBag)]) +
   theme_dark()
p = p + theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust =1, size = 15),
              axis.text.y = element_text(size = 12), axis.title.y = element_text(size = 15),
              legend.text = element_text(size = 12),
              legend.position="top") + xlab('') 
return(p)
}

thelist = fread('o:/ST_GooseProject/ALMaSS/Scenarios/Scenarios 2016-09-12.txt')
thelist[, Species:=as.factor(Species)]
levels(thelist$Species) = c('Grågås', 'Kortnæbbet gås')
# Gåseplots.
subset = c('Baseline', 'Greylag x 0.5', 'Greylag x 2', 'Pinkfoot x 2')
plotdata = thelist[Scenario %in% subset,]
plotdata[, Scenario:=factor(Scenario, levels = subset)]
levels(plotdata$Scenario) = c("Baseline", "Grågås x 0.5", "Grågås x 2", "Kortnæbbet gås x 2")
p = presentationplot(plotdata)
p
png(filename = 'o:/ST_GooseProject/Presentations/Graa.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Bramgås
subset = c('Baseline', 'Barnacle x 0', 'Barnacle x 4', 'Barnacle early arrival')
plotdata = thelist[Scenario %in% subset,]
plotdata[, Scenario:=factor(Scenario, levels = subset)]
levels(plotdata$Scenario) = c("Baseline", "Bramgås x 0", "Bramgås x 4", "Tidlig ankomst")
p = presentationplot(plotdata)
png(filename = 'o:/ST_GooseProject/Presentations/Bram.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Checkers
subset = c('Baseline', 'No checkers', 'All hunters checkers')
plotdata = thelist[Scenario %in% subset,]
plotdata[, Scenario:=factor(Scenario, levels = subset)]
levels(plotdata$Scenario) = c("Baseline", "Ingen tjekker", "Alle tjekker")
p = presentationplot(plotdata)
png(filename = 'o:/ST_GooseProject/Presentations/Tjekker.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Januar jagt
subset = c('Baseline', 'January hunting')
plotdata = thelist[Scenario %in% subset,]
plotdata[, Scenario:=factor(Scenario, levels = subset)]
levels(plotdata$Scenario) = c("Baseline", "Januar jagt")
p = presentationplot(plotdata)
png(filename = 'o:/ST_GooseProject/Presentations/Janjagt.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Jagtadfærd
subset = c('Baseline', 'Hunters teaming up', 'Doubling of hunters', '1.5 x efficiency')
plotdata = thelist[Scenario %in% subset,]
plotdata[, Scenario:=factor(Scenario, levels = subset)]
levels(plotdata$Scenario) = c("Baseline", "Jæger gruppering", "Fordobling af jægere", "Øget effektivitet")
p = presentationplot(plotdata)
p
png(filename = 'o:/ST_GooseProject/Presentations/JagtAdfærd.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()
# Jagtadfærd II
subset = c('Baseline', 'Hunt once a week', 'Hunt twice a week')
plotdata = thelist[Scenario %in% subset,]
plotdata[, Scenario:=factor(Scenario, levels = subset)]
levels(plotdata$Scenario) = c("Baseline", "1 ugentlig jagtdag", "2 ugentlige jagtdage")
p = presentationplot(plotdata)
p
png(filename = 'o:/ST_GooseProject/Presentations/JagtAdfærd2.png', width = 14, height = 15, unit = 'cm', res = 300 )
print(p)
dev.off()


