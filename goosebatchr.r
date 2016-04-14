# Title: goosebatchr
# Updated: March 8th 2016
# Author: Lars Dalby

# This script will run tests of the fit of simulation results to field data on geese
# as well as copy the results from almass and the ParameterValues.txt to a specified location.
# The results from all the runs in the batch file will be collected in the file
# ParameterFittingResults.txt and stored together with the other files.
# Remember to reset the counter to 1 before starting a scenario. This is done by 
# opening the file counter.txt and changing the number to 1. Alternatively, if you set this
# all up by using the FileDist.r script, it should already be taken care of.
#
# Before running this script check that you have the following files in the run directory:
# 1: counter.txt
# 2: fugledata_20150320_obs_clean.csv
# 3: observations_PG_01Jan2010-18Jan2016_API.xlsx
# 4: HabitatUseAll2014.csv
# 5: goosebatch.r
# 6: PreRunSetup.r
# Again, if you used FileDist.r then this should be taken care of.
# --------------------------------------------------------------------------------------------# 

# Load the packages we're going to need:
library(data.table)
library(ralmass)
library(stringr)
library(readxl)

library(slackr)  # Only needed if you want Slack to give you updates on progress

# Setup work directory (done automatically when distributing the files, therefore blank):

# To get the line number in the parameter list we make a vector of line numbers for the
# first of the parameters in each run:
paramvals = fread('ParameterValues.txt')  # To figure out how many runs we have
numberofparams = length(unique(paramvals[, V1])) # The number of paramters being modified per run 
runs = nrow(paramvals)/numberofparams
lineno = seq(1, runs*numberofparams, numberofparams)

# Path to the results:
resultpath = './Results/'

# Figure out how far we have come
counter = as.numeric(readLines('counter.txt'))

# If this is the first run, set up the results files make a copy of the parameter list
if(counter == 1)
{
	# Set up the results directory
	dir.create('Results')
	# Set up the headers in first run
	line = paste('Parameter', 'Value', 'FitType', 'Fit', sep = '\t')
	write(line, file = paste0(resultpath, 'ParameterFittingResults.txt'))
	# Copy the Goose params to the result folder for reference and checking
	file.copy('ParameterValues.txt', resultpath, copy.date = TRUE)
}

# If there the simulation was terminated before writing results (should not happen):
if(length(grep("GooseFieldForageData.txt", dir())) == 0)
{
	lines = readLines('ParameterValues.txt')
	for (i in 1:numberofparams) {
		param = word(lines[lineno[counter]+(i-1)], 1)  # Get the parameter name
		value = as.numeric(str_split(lines[lineno[counter]+(i-1)], '=')[[1]][2])  # Get the value
		line = paste(param, value, NA, NA, sep = '\t')
		write(line, file = paste0(resultpath, 'ParameterFittingResults.txt'), append = TRUE)
	}
}
# --------------------------------------------------------------------------------------------#
#                                    Flock sizes                                              #
# --------------------------------------------------------------------------------------------#

if(length(grep("GooseFieldForageData.txt", dir())) != 0)
{
	dropcols = c("Polyref", "Openness", "Grain", "Maize", "Digestability")
	forage = fread('GooseFieldForageData.txt', showProgress = FALSE, drop = dropcols)
	forage = ClassifyHabitatUse(forage, species = 'goose', timed = TRUE)
	# Field data:
	fieldobs = fread('o:/ST_GooseProject/Field data/Fugledata/fugledata_20150320_obs_clean.csv')
	flocks = fieldobs[Month %in% c(12,1) & Hour >= 11 & Hour <= 13,]  # todo: Why do we only use december and jan?
	flocks[, c('Month', 'Hour'):=NULL]
	setcolorder(flocks, c('Species', 'Numbers', 'Type'))

	# Simulation results - max number on a day:
	simflocks = forage[Geese > 0, .(Day, Barnacle, Pinkfoot, Greylag)]
	melted = data.table::melt(simflocks, id.vars = 'Day', variable.name = 'Species', value.name = 'Numbers')
	melted = melted[Numbers != 0,]
	melted[, Day:=NULL]
	melted[, Type:='Simulated']
	dists = rbind(melted, flocks)

	DegreeOverlapB = round(CalcOverlap(dists, species = 'Barnacle'), digits = 2)
	DegreeOverlapP = round(CalcOverlap(dists, species = 'Pinkfoot'), digits = 2)
	DegreeOverlapG = round(CalcOverlap(dists, species = 'Greylag'), digits = 2)

	# Simulation results - timed counts:
	simflocks = forage[Geese > 0, .(Day, BarnacleTimed, PinkfootTimed, GreylagTimed)]
	melted = data.table::melt(simflocks, id.vars = 'Day', variable.name = 'Species', value.name = 'Numbers')
	melted = melted[Numbers != 0,]
	melted[ ,Day:=NULL]
	melted[, Type:='Simulated']
	distsTimed = rbind(melted, flocks)
	
	DegreeOverlapBT = round(CalcOverlap(distsTimed, species = 'Barnacle'), digits = 2)
	DegreeOverlapPT = round(CalcOverlap(distsTimed, species = 'Pinkfoot'), digits = 2)
	DegreeOverlapGT = round(CalcOverlap(distsTimed, species = 'Greylag'), digits = 2)
# --------------------------------------------------------------------------------------------#
#                                    Weights                                                  #
# --------------------------------------------------------------------------------------------#
	massdropcols = c("Energy", "MinForageRate", 'FullTime')
	mass = fread('GooseEnergeticsData.txt', showProgress = FALSE, drop = massdropcols)
	mass[,Day:=Day-365]
	api = read_excel('observations_PG_01Jan2010-18Jan2016_API.xlsx')
	api = as.data.table(api)
	api = api[SEXE == 'M']
	field = CleanAPIData(api)
	Weightfit = CalcWeightFit(mass, field)

# --------------------------------------------------------------------------------------------#
#                                      Habitat use                                            #
# --------------------------------------------------------------------------------------------#
	FieldData = fread('HabitatUseAll2014.csv')
	FieldData[HabitatUse == 'Stubble undersown', HabitatUse:='Stubble']
	FieldData[HabitatUse == 'UnharvestedBarley', HabitatUse:='Stubble']
	FieldData[, NMTotal:=sum(N), by=.(Month, Species)]
	FieldData[, Prop:=N/NMTotal]
	FieldData[rep(seq(.N),N), .(Month, HabitatUse, N, Species, NMTotal, Prop), by = Species]
	
	forage[, Month:=month(as.Date(Day, origin = '2012-01-01'))]  # origin can be anything - we only care about the month.
	HabitatUseFit = CalcHabitatUseFit(FieldData = FieldData, SimData = forage)
	HabMonths = nrow(unique(HabitatUseFit[, .(Month)]))
	HabitatUseFit[, SeasonFit:=sum(Fit, na.rm = TRUE)/length(!is.na(Month)), by = Species]
	HabitatUseFit = unique(HabitatUseFit[, .(Species, SeasonFit)])
	HabUsePF = HabitatUseFit[Species == 'Pinkfoot', SeasonFit]
	HabUseGL = HabitatUseFit[Species == 'Greylag', SeasonFit]
	HabUseBN = HabitatUseFit[Species == 'Barnacle', SeasonFit]

# --------------------------------------------------------------------------------------------#
#                                   Collect and write out                                     #
# --------------------------------------------------------------------------------------------#
	# Calculate the overall model fit
	PinkFootFit = Weightfit^2 + HabUsePF^2 + DegreeOverlapPT^2
	GreylagFit = HabUseGL^2 + DegreeOverlapGT^2
	BarnacleFit = HabUseBN^2 + DegreeOverlapBT^2

	# Write out the results of the parameter fitting and prepare for next run:
	FitVect = c(Weightfit, DegreeOverlapPT, DegreeOverlapGT, DegreeOverlapBT,
		 HabUsePF, HabUseGL, HabUseBN, PinkFootFit, GreylagFit, BarnacleFit)
	FitNames = c('Weightfit', 'FlockSizeFitPT', 'FlockSizeFitGT', 'FlockSizeFitBT',
		 'HabUsePF', 'HabUseGL', 'HabUseBN', 'PinkFootFit', 'GreylagFit', 'BarnacleFit')
	lines = readLines('ParameterValues.txt')
	for (i in 1:numberofparams) {
		param = word(lines[lineno[counter]+(i-1)], 1)  # Get the parameter name
		value = as.numeric(str_split(lines[lineno[counter]+(i-1)], '=')[[1]][2])  # Get the value
		for (j in seq_along(FitNames)) {
			line = paste(param, value, FitNames[j], FitVect[j], sep = '\t')
			write(line, file = paste0(resultpath, 'ParameterFittingResults.txt'), append = TRUE)
		}
	}
	# As the last thing we delete the goose output files
	# We do this in case almass exits due to an error. If that happens files from a previous
	# run might still be sitting in the run directory and we would simply analyze these as if they were the new 
	# run and get results identical to the previous run

	if(length(grep("GooseEnergeticsData.txt", dir())) > 0)
	{
		file.remove("GooseEnergeticsData.txt")
	}

	if(length(grep("GooseFieldForageData.txt", dir())) > 0)
	{
		file.remove("GooseFieldForageData.txt")
	}
}

# Report progress to console:
cat(paste0('Run number ', counter, '\n'))

# If you want updates:
token = readLines('c:/Users/lada/Dropbox/slackrToken.txt')  # Your token and nothing else in a file. 
slackrSetup(channel="@slackbot", api_token = token)
# slackr(paste('Run', counter, Sys.time(), sep = ' '))

# Very last thing is to update the counter:
counter = counter+1  
write(counter, file = 'counter.txt', append = FALSE)

# If you plots for each run:
if(counter > 1 & counter < runs) 
{
	token = readLines('c:/Users/lada/Dropbox/slackrToken.txt')
	slackrSetup(channel="@slackbot", api_token = token)
	library(ggplot2)
	res = fread(paste0(resultpath, 'ParameterFittingResults.txt'))
	p = ggplot(res, aes(Value, Fit)) + geom_line(aes(color = FitType), size = 1) +
		scale_color_brewer(palette = "Set3")
	ggslackr(p)
}
