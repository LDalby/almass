# Title: batchr
# Date: June 12 2015
# Author: Lars Dalby

# This script will run two tests of the fit of simulation results to data from the hunter survey
# as well as copy the results from almass and the Hunter_Params.txt to a specified location.
# The results from all the runs in the batch file will be collected in the file
# ParameterFittingResults.txt and stored together with the other files.
# In each scenario, be sure to change the result path - otherwise we will overwrite previous
# data.
# If running a scenario where more than one parameter is being changed you need to uncomment
# a couple of lines in two places. Do a text search on these three characteres @£$ and you will
# see what to do.
# Finally, remember to reset the counter to 1 before starting a scenario. This is done by 
# opening the file counter.txt and changing the number to 1.
#
# Before running this script check that you have the following files in the run directory:
# 1: counter.txt
# 2: HunterSurveyResultsDensity.csv
# 3: HunterSurveyResultsDistance.csv
# --------------------------------------------------------------------------------------------# 

# Load the packages we're going to need:
library(data.table)
library(ralmass)
library(stringr)
library(reshape2)
#library(slackr)  # Only needed if you want Slack to give you updates on progress

# Setup work- and results directory:
setwd('d:/almass/WorkDirectories/Hunter/HunterTestingAug2015/BaseWD/')  # The run directory
resultpath = 'd:/almass/Results/GooseManagement/Hunter/HunterTestingAug2015/Random/'  # Path where the results will be stored
# To get the line number in the parameter list in multi parameter scenarios we make a vector of line numbers for the
# first of the parameters in each run (this approach is also used for single parameter scenarios):
runs = 5  # The number of runs
params = 1  # The number of paramters being modified per run 
lineno = seq(1, runs*params, params)

# Figure out how far we have come
counter = as.numeric(readLines('counter.txt'))

# If this is the first run, set up the results files make a copy of the parameter list
if(counter == 1 )
{
	# Set up the headers in first run
	line = paste('Parameter', 'Value', 'DistanceFit', 'DensityFit', 'MaxHunters', 'OverallFit', sep = '\t')
	write(line, file = paste(resultpath, 'ParameterFittingResults.txt', sep = ''))
	# Copy the Hunter params to the result folder for reference and checking
	file.copy('ParameterValues.txt', resultpath, copy.date = TRUE)
}

# If there is no results from the sim because no hunters were distributed:
if(length(grep("Hunter_Hunting_Locations.txt", dir())) == 0)
{
	lines = readLines('ParameterValues.txt')
	param = word(lines[lineno[counter]], 1)  # Get the parameter name
	value = as.numeric(str_split(lines[lineno[counter]], '=')[[1]][2])  # Get the value
	line1 = paste(param, value, NA, NA, NA, NA, sep = '\t')
	write(line1, file = paste(resultpath, 'ParameterFittingResults.txt', sep = ''), append = TRUE)
	# @£$: Uncomment these when running the scenarios with two parameters:
# 	# param2 = word(lines[lineno[counter]+1], 1)  # Get the parameter name
# 	# value2 = as.numeric(str_split(lines[lineno[counter]+1], '=')[[1]][2])  # Get the value
# 	# line2 = paste(param2, value2, NA, NA, NA, NA,  sep = '\t')
# 	# write(line2, file = paste(resultpath, 'ParameterFittingResults.txt', sep = ''), append = TRUE)
 }

#¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ Distances ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤#

if(length(grep("Hunter_Hunting_Locations.txt", dir())) != 0)
{
	# Simulation results:
	locations = fread('Hunter_Hunting_Locations.txt')
	filename = paste(resultpath,'HuntingLocationsRun', counter, '.txt', sep ='')
	write.table(locations, file = filename, row.names = FALSE, sep = '\t')

	farms = fread('Hunter_Hunting_Locations_Farms.txt')
	filename = paste(resultpath, 'HuntingLocationsFarmRun', counter, '.txt', sep ='')
	write.table(farms, file = filename, row.names = FALSE, sep = '\t')
	
	idvars = c('HunterID','HunterType','HomeX','HomeY','NoFarmrefs')
	dist = rep(NA, nrow(locations))
	for (j in seq_along(locations[,HunterID])) 
	{
		huntinglocs = melt(locations, id.vars = idvars)[HunterID == j-1 & !is.na(value)][,value]
		temp = rep(NA, length(huntinglocs))
		for (i in seq_along(huntinglocs))
		{
			thedist = dist(rbind(as.numeric(locations[i,.(HomeX, HomeY)]),
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
	huntersurvey[Bin == 0, ModelRes:= length(locations[Bin == 0, Bin])]
	huntersurvey[Bin == 10, ModelRes:= length(locations[Bin == 10, Bin])]
	huntersurvey[Bin == 20, ModelRes:= length(locations[Bin == 20, Bin])]
	huntersurvey[Bin == 40, ModelRes:= length(locations[Bin == 40, Bin])]
	huntersurvey[Bin == 60, ModelRes:= length(locations[Bin == 60, Bin])]
	huntersurvey[Bin == 80, ModelRes:= length(locations[Bin == 80, Bin])]
	huntersurvey[Bin == 100, ModelRes:= length(locations[Bin == 100, Bin])]
	huntersurvey[Bin == 150, ModelRes:= length(locations[Bin == 150, Bin])]
	huntersurvey[Bin == 200, ModelRes:= length(locations[Bin == 200, Bin])]
	huntersurvey[Bin == 201, ModelRes:= length(locations[Bin == 201, Bin])]

	huntersurvey[, propSim:=ModelRes/sum(ModelRes)]
	huntersurvey[, propSur:=RespondTH_JM/sum(RespondTH_JM)]

	distancefit = with(huntersurvey, 1-sum((propSim-propSur)^2))

    #¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤ Density ¤¤¤¤¤¤¤¤¤¤¤¤¤¤¤#
	# Load the survey results
	survey = fread('HunterSurveyResultsDensity.csv')

	farms[,Numbers:=NoHunters/(FarmSize/10000)]
	farms[,Type:= 'Simulated']
	simulated = farms[Numbers > 0, c('Numbers', 'Type'), with = FALSE]
	# Collect the survey and sim results:
	density = rbind(survey, simulated)
	# Asses the fit
	overlab = round(CalcOverlab(density, species = 'Hunter'), 3)  #see ?CalcOverlab for documentation
	# Find the maximum number of hunters on any farm:
	maxhunters = max(farms[,NoHunters])
	
	# Calculate the overall model fit
	OverallFit = distancefit + overlab

	# Write out the results of the parameter fitting and prepare for next run:
	# Clean file for comments and empty lines:
	lines = readLines('ParameterValues.txt')

	param = word(lines[lineno[counter]], 1)  # Get the parameter name
	value = as.numeric(str_split(lines[lineno[counter]], '=')[[1]][2])  # Get the value
	line1 = paste(param, value, distancefit, overlab, maxhunters, OverallFit, sep = '\t')
	write(line1, file = paste(resultpath, 'ParameterFittingResults.txt', sep = ''), append = TRUE)

	# @£$: Uncomment these when running the scenarios with two parameters:
	# param2 = word(lines[lineno[counter]+1], 1)  # Get the parameter name
	# value2 = as.numeric(str_split(lines[lineno[counter]+1], '=')[[1]][2])  # Get the value
	# line2 = paste(param2, value2, distancefit, overlab, maxhunters, OverallFit, sep = '\t')
	# write(line2, file = paste(resultpath, 'ParameterFittingResults.txt', sep = ''), append = TRUE)


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

# Very last thing is to update the counter:
counter = counter+1  
write(counter, file = 'counter.txt', append = FALSE)
