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
# scenariodirs = scenariodirs[c(1:6, 9)]
resultlist = vector('list', length(scenariodirs))
for (i in 1:length(resultlist)) {
	respath = file.path(pth, scenariodirs[i], 'Results', 'ParameterFittingResults.txt')
	resultlist[[i]] = fread(respath)
}
thelist = rbindlist(resultlist)
thelist = thelist[grep('TotalBag', FitType),]
thelist[,Value:=NULL]
thelist[FitType == 'TotalBagPF', FitType:='Pinkfoot']
thelist[FitType == 'TotalBagGL', FitType:='Greylag']
setnames(thelist, c('Scenario', 'TotalBag', 'Bag'))
thelist[, mean:=round(mean(Bag)), by = c('Scenario', 'TotalBag')]
thelist[, min:=min(Bag), by = c('Scenario', 'TotalBag')]
thelist[, max:=max(Bag), by = c('Scenario', 'TotalBag')]
plotorder = c("Baseline", "Barnacle x 0", "Barnacle x 2", "Greylag x 2", "January hunting", "Double efficiency",
 "Hunt once a week", "All hunters checkers", "Hunters teaming up", "Doubling of hunters")
thelist[, Scenario:=factor(Scenario, levels = plotorder)]
p = ggplot(thelist, aes(Scenario, mean)) + 
	 geom_pointrange(aes(ymin = min, ymax = max, color = TotalBag), position=position_dodge(width=0.2)) + 
	 scale_color_viridis(discrete=TRUE, guide = guide_legend(title = "Total bag")) + 
	 ylab('Mean total bag size') + ylim(0, thelist[, max(Bag)]) +  theme_dark()


token = readLines('C:/Users/au206907/Dropbox/slackrToken.txt')  # Your token and nothing else in a file. 
slackrSetup(channel="#goosemodel", api_token = token)
ggslackr(p)	
