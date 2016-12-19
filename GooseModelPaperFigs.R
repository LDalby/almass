# Script to create figures for the goose model paper
# Author: Lars Dalby
# Date: 6th dec 2016

# WIP

library(data.table)
library(ralmass)
library(readxl)
library(ggplot2)
library(viridis)
# Weight development figure:
api = read_excel('o:/ST_GooseProject/Field data/observations_PG_01Jan2010-18Jan2016_API.xlsx')
api = as.data.table(api)
api = api[SEXE == 'M']
field = CleanAPIData(api)
field[, Week:=week(Date)]
field[, MeanWeight:= mean(Weight), by = Week]
SE <- function(x) sqrt(var(x,na.rm=TRUE)/length(na.omit(x)))
field[, SElower:= MeanWeight-SE(Weight), by = Week]
field[, SEupper:= MeanWeight+SE(Weight), by = Week]
field = unique(field[,.(Week, MeanWeight, SElower, SEupper)])
field[, Type:='Field']

resultpath = 'c:/MSV/WorkDirectory/'
weights = fread(file.path(resultpath, 'GooseWeightStats.txt'))
weights = weights[Species == 'Pinkfoot',]
weights = weights[N != 0,]  
weights[,Day:=Day-365]
weights = weights[Season == 1,]
weights[, Date:=as.Date(Day, origin = as.Date('2009-01-01'))]
weights[, Week:=week(Date)]
weights[, SEupper:=MeanWeight+StdError] 
weights[, SElower:=MeanWeight-StdError] 
fits = CalcWeightFit(weights, field, measure = 'SSSE')
weights = weights[,.(Week, MeanWeight, SElower, SEupper)]
weights[, Type:='Sim']
full = rbind(field, weights)
full = full[Week <= 9 | Week >= 38,]
full[Week < 20, Week:=Week+53L]
png(filename = "o:/ST_Lada/Projekter/GBB/Figures/weights.png",
    width = 85, height = 55, units = "mm", pointsize = 12,
    bg = "white", res = 200, family = "", restoreConsole = TRUE,
     antialias = "cleartype")
ggplot(full, aes(Week, MeanWeight)) + geom_pointrange(aes(color = Type, ymin = SElower, ymax = SEupper), size = 0.2) +  
 ylab("Mean weight") + theme_bw() + scale_color_viridis(discrete = TRUE) + ylim(2400,NA)
dev.off()


ggplot(weights, aes(Date, MeanWeight)) + geom_point() + geom_errorbar(aes(ymin = SElower, ymax = SEupper), width = 0.5) + facet_wrap(~Species, scales = 'free_y')
ggplot(weights, aes(Date, N/7)) + geom_point() + facet_wrap(~Species, scales = 'free_y')
