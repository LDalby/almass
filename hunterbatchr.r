# Title: batchr
# Date: Sep 25 2015
# Author: Lars Dalby

# This script will run two tests of the fit of simulation results to data from the hunter survey
# as well as copy the results from almass and the ParameterValues.txt to a specified location.
# The results from all the runs in the batch file will be collected in the file
# ParameterFittingResults.txt and stored together with the other files.
# Remember to reset the counter to 1 before starting a scenario. This is done by 
# opening the file counter.txt and changing the number to 1. Alternatively, if you set this
# all up by using the FileDist.r script, it should already be taken care of.
#
# Before running this script check that you have the following files in the run directory:
# 1: counter.txt
# 2: HunterSurveyResultsDensity.csv
# 3: HunterSurveyResultsDistanceJuly2015.txt
# 4: batch.r
# 5: PreRunSetup.r
# Again, if you used FileDist.r then this should be taken care of.
# --------------------------------------------------------------------------------------------# 

# Load the packages we're going to need:
library(data.table)
library(ralmass)
library(stringr)
library(reshape2)
#library(slackr)  # Only needed if you want Slack to give you updates on progress

# Setup work directory (done automatically when distributing the files, therefore blank):

# To get the line number in the parameter list in multi parameter scenarios we make a vector of line numbers for the
# first of the parameters in each run (this approach is also used for single parameter scenarios):
paramvals = fread('ParameterValues.txt')  # To figure out how many runs we have
numberofparams = nrow(unique(paramvals[, 1, with = FALSE])) # The number of paramters being modified per run 
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
	line = paste('Openness', 'Density', 'Probability', 'DistanceFit', 'DensityFit',
	 'NoHunterFit', 'LegalDensities', 'MaxHunters', sep = '\t')
	write(line, file = paste0(resultpath, 'ParameterFittingResults.txt'))
	# Copy the Hunter params to the result folder for reference and checking
	file.copy('ParameterValues.txt', resultpath, copy.date = TRUE)
}

# If there is no results from the sim because no hunters were distributed:
if(length(grep("Hunter_Hunting_Locations.txt", dir())) == 0)
{
	lines = readLines('ParameterValues.txt')
	for (i in 1:numberofparams) {
		param = word(lines[lineno[counter]+(i-1)], 1)  # Get the parameter name
		value = as.numeric(str_split(lines[lineno[counter]+(i-1)], '=')[[1]][2])  # Get the value
		openness = NA
		density = NA
		probability = NA
		if(param == 'GOOSE_MINFORAGEOPENNESS') openness = value
		if(param == 'HUNTERS_MAXDENSITY') density = value
		if(param == 'CLOSESTFARMPROBPARAMONE') probability = value
	}
	line = paste(openness, density, probability, NA, NA, NA, NA, NA,  sep = '\t')
	write(line, file = paste0(resultpath, 'ParameterFittingResults.txt'), append = TRUE)
}

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ Distances ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤#

if(length(grep("Hunter_Hunting_Locations.txt", dir())) != 0)
{
	# Simulation results:
	locations = fread('Hunter_Hunting_Locations.txt', skip = 1)  # Skip the counter
	filename = paste0(resultpath,'HuntingLocationsRun', counter, '.txt')
	write.table(locations, file = filename, row.names = FALSE, sep = '\t')

	farms = fread('Hunter_Hunting_Locations_Farms.txt')
	filename = paste0(resultpath, 'HuntingLocationsFarmRun', counter, '.txt')
	write.table(farms, file = filename, row.names = FALSE, quote = FALSE, sep = '\t')
	
	idvars = c('HunterID','HunterType','HomeX','HomeY','NoFarmrefs')
	dist = rep(NA, nrow(locations))
	for (j in seq_along(locations[,HunterID])) 
	{
		huntinglocs = melt(locations, id.vars = idvars)[HunterID == j-1 & !is.na(value)][,value]
		temp = rep(NA, length(huntinglocs))
		for (i in seq_along(huntinglocs))
		{
			thedist = dist(rbind(as.numeric(locations[HunterID == j-1,.(HomeX, HomeY)]),
				as.numeric(farms[FarmRef == huntinglocs[i],.(FarmCentroidX, FarmCentroidY)])))
			temp[i] = thedist
		}
		dist[j] = min(temp)
	}
	locations[, Dists:=dist/1000]

	locations[Dists < 1, Bin:=0]
	locations[Dists <= 10 & Dists >= 1, Bin:=10]
	locations[Dists <= 20 & Dists > 10, Bin:=20]
	locations[Dists <= 40 & Dists > 20, Bin:=40]
	locations[Dists <= 60 & Dists > 40, Bin:=60]
	locations[Dists <= 80 & Dists > 60, Bin:=80]
	locations[Dists <= 100 & Dists > 80, Bin:=100]
	locations[Dists <= 150 & Dists > 100, Bin:=150]
	locations[Dists <= 200 & Dists > 150, Bin:=200]
	locations[Dists > 200, Bin:=201]

	# The survey results:
	huntersurvey = fread('HunterSurveyResultsDistanceJuly2015.txt')
	# The simulation results needs to be binned manually and added to the survey data:
	TheBins = c(0,10,20,40,60,80,100,150,200,201)
	for (i in seq_along(TheBins)) {
		huntersurvey[Bin == TheBins[i], ModelRes:= length(locations[Bin == TheBins[i], Bin])]
	}
	huntersurvey[, propSim:=ModelRes/sum(ModelRes)]
	huntersurvey[, propSur:=RespondTH_JM/sum(RespondTH_JM)]

	distancefit = with(huntersurvey, 1-sum((propSim-propSur)^2))

    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ Density ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤#
	# Load the survey Results
	survey = fread('HunterSurveyResultsDensity.csv')

	farms[,Numbers:=NoHunters/(FarmSize/10000)]
	farms[,Type:= 'Simulated']
	simulated = farms[Numbers > 0, c('Numbers', 'Type'), with = FALSE]
	# Collect the survey and sim results:
	density = rbind(survey, simulated)
	# Asses the fit
	overlap = round(CalcOverlap(density, species = 'Hunter'), 3)  #see ?CalcOverlap for documentation
	# Find the maximum number of hunters on any farm:
	maxhunters = max(farms[,NoHunters])

    #------------ Number of hunters per farm ------------#
	# Load the survey results
	survey = fread('HunterSurveyResultsFarm.csv')
	
	# Least squares
	survey[, N:=.N, by = Numbers]
	survey = unique(survey)
	setnames(survey, old = 'Numbers', new = 'Bin')
	bins = data.table('N' = c(0,0), 'Type' = rep('Fieldobs',2), 'Bin' = c(8, 12))
	survey = rbind(survey, bins)
	setkey(survey, Bin)
	# The simulation results needs to be binned manually and added to the survey data:
	for (i in 1:11) {
	survey[Bin == i, ModelRes:= length(farms[NoHunters == i, NoHunters])]
	}
	survey[Bin == 12, ModelRes:= length(farms[NoHunters >= 12, NoHunters])]

	survey[, propSim:=ModelRes/sum(ModelRes)]
	survey[, propSur:=N/sum(N)]

	no.huntersFit = with(survey, 1-sum((propSim-propSur)^2))

	# Write out the results of the parameter fitting and prepare for next run:
	lines = readLines('ParameterValues.txt')
	for (i in 1:numberofparams) {
		param = word(lines[lineno[counter]+(i-1)], 1)  # Get the parameter name
		value = as.numeric(str_split(lines[lineno[counter]+(i-1)], '=')[[1]][2])  # Get the value
		openness = NA
		density = NA
		probability = NA
		if(param == 'GOOSE_MINFORAGEOPENNESS') openness = value
		if(param == 'HUNTERS_MAXDENSITY') density = value
		if(param == 'CLOSESTFARMPROBPARAMONE') probability = value
	}
	if(param == 'HUNTERS_MAXDENSITY') {
		AllLegal = CheckDensity(farms, value)
	}
	if(param != 'HUNTERS_MAXDENSITY') AllLegal = NA
	line = paste(openness, density, probability, distancefit, overlap, no.huntersFit, AllLegal, maxhunters, sep = '\t')
	write(line, file = paste0(resultpath, 'ParameterFittingResults.txt'), append = TRUE)

	# As the last thing we delete the Hunter_Hunting_Locations.txt Hunter_Hunting_Locations_Farms.txt
	# We do this because almass might exit without distributing hunters. If that happens files from a previous
	# run might still be sitting in the run directory and we would simply analyze these as if they were the new 
	# run and get results identical to the previous run

	if(length(grep("Hunter_Hunting_Locations.txt", dir())) > 0)
	{
		file.remove("Hunter_Hunting_Locations.txt")
	}

	if(length(grep("Hunter_Hunting_Locations_Farms.txt", dir())) > 0)
	{
		file.remove("Hunter_Hunting_Locations_Farms.txt")
	}
}

# If you want updates:
# slackrSetup(channel="@name", api_token = INSERT YOUR TOKEN)
# slackr(paste(counter))

# Report progress to console:
cat(paste0('Run number ', counter, '\n'))

# Very last thing is to update the counter:
counter = counter+1  
write(counter, file = 'counter.txt', append = FALSE)
