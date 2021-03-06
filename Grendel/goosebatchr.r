#!/usr/local/bin/r
# Title: goosebatchr
# Updated: December 2016 (to run on linux)
# Author: Lars Dalby

# Set the local R package library (if not done already)
if(!'/home/ldalby/R/packages' %in% .libPaths()) {
	.libPaths('/home/ldalby/R/packages')
}

# Load the packages we are going to need
library(methods)  # to avoid warning when calling lubridate
library(data.table)
library(ralmass)
library(tidyverse)
# Setup work directory (done automatically when distributing the files, therefore blank):

# To get the line number in the parameter list we make a vector of line numbers for the
# first of the parameters in each run:library(tidyverse
paramvals = fread('ParameterValues.txt')  # To figure out how many runs we have
if(nrow(paramvals) == 0) {
	numberofparams = 1
	runs = 1
	lineno = 1
	singlerun = TRUE 
}
if(nrow(paramvals) > 0) {
	numberofparams = length(unique(paramvals[, V1])) # The number of paramters being modified per run 
	runs = nrow(paramvals)/numberofparams
	lineno = seq(1, runs*numberofparams, numberofparams)
	singlerun = FALSE
}

# Path to the results:
resultpath = file.path(getwd(),'Results')  # intermediate results
finalreslocation =  '/home/ldalby/workspace/Goose/ParamFitting/Results'  # the final result file stored
errorfilelocation =  '/home/ldalby/workspace/Goose/ParamFitting/Errors'  # the error files
# Figure out how far we have come
counter = as.numeric(readLines('counter.txt'))

# If this is the first run, set up the results files make a copy of the parameter list
if(counter == 1)
{
	# Set up the results directory
	dir.create('Results')
	# Set up the headers in first run
	line = paste('Parameter', 'Value', 'FitType', 'Fit', sep = '\t')
	write(line, file = file.path(resultpath, 'ParameterFittingResults.txt'))
	# Copy the Goose params to the result folder for reference and checking
	file.copy('ParameterValues.txt', resultpath, copy.date = TRUE)
}

# If there the simulation was terminated before writing results (should not happen):
if(!file.exists("GooseFieldForageData.txt"))
{
	lines = readLines('ParameterValues.txt')
	for (i in 1:numberofparams) {
		param = GetParamString(config = lines[lineno[counter]+(i-1)])    # Get the parameter name
		value = GetParamValue(config = lines[lineno[counter]+(i-1)], param = param)  # Get the value
		line = paste(param, value, NA, NA, sep = '\t')
		write(line, file = file.path(resultpath, 'ParameterFittingResults.txt'), append = TRUE)
	}
}

# The fit measure to use (either SSSE or LS):
fitmeasure = 'LS'

# --------------------------------------------------------------------------------------------#
#                                    Flock sizes                                              #
# --------------------------------------------------------------------------------------------#

if(file.exists("GooseFieldForageData.txt"))
{
	forage = fread('GooseFieldForageData.txt', showProgress = FALSE)
	forage[, Date:=as.Date(Day, origin = as.Date('2009-01-01'))]
	forage = forage[data.table::month(Date) %in% c(9:12,1:3)]
	forage = as.data.table(ClassifyHabitatUse(forage, species = 'goose', timed = TRUE))
	# Field data:
	# Currently 2015 data from months: 9,10,11,12,1,2 & 3. See o:\ST_GooseProject\R\ConvertObsToALMaSS.r
	# for details on the data handling
	flocks = fread('FieldobsFlockSizes2016-05-03.txt')
	seasons = unique(forage[, Season])
	DegreeOverlapBT = NA
	DegreeOverlapPT = NA
	DegreeOverlapGT = NA
	simflocks = forage[Geese > 0,]
	for (i in seq_along(seasons)) {
	# Simulation results - timed counts:
		tmp = simflocks[Season == seasons[i], .(Day, BarnacleTimed, PinkfootTimed, GreylagTimed)]
		melted = data.table::melt(tmp, id.vars = 'Day', variable.name = 'Species', value.name = 'Numbers')
		melted = melted[Numbers != 0,]
		melted[ ,Day:=NULL]

		DegreeOverlapBT[i] = CalcFlockSizeFit(melted, flocks, 'Barnacle', measure = fitmeasure)
		DegreeOverlapPT[i] = CalcFlockSizeFit(melted, flocks, 'Pinkfoot', measure = fitmeasure)
		DegreeOverlapGT[i] = CalcFlockSizeFit(melted, flocks, 'Greylag', measure = fitmeasure)
	}

# --------------------------------------------------------------------------------------------#
#                                    Weights                                                  #
# --------------------------------------------------------------------------------------------#
		mass = fread('GooseWeightStats.txt', showProgress = FALSE, drop = c('StdError', 'N'))
		mass = mass[Species == 'Pinkfoot' & MeanWeight != -1,]
		api = fread('APIdata.txt')
		Weightfit = CalcWeightFit(Sim = mass, Field = api, measure = fitmeasure)

# --------------------------------------------------------------------------------------------#
#                                      Habitat use                                            #
# --------------------------------------------------------------------------------------------#
	FieldData = fread('HabitatUseAll2014.csv')
	FieldData[HabitatUse == 'Stubble undersown', HabitatUse:='Stubble']
	FieldData[HabitatUse == 'UnharvestedBarley', HabitatUse:='Stubble']
	FieldData = FieldData[HabitatUse != 'Plowed',]
	FieldData[, NMTotal:=sum(N), by=.(Month, Species)]
	FieldData[, Prop:=N/NMTotal]
	HabUsePF = NA
	HabUseGL = NA
	HabUseBN = NA
	forage[, Month:=month(as.Date(Day, origin = '2012-01-01'))]  # origin can be anything - we only care about the month.
	for (i in seq_along(seasons)) {
		HabitatUseFit = CalcHabitatUseFit(FieldData = FieldData, SimData = forage[Season == seasons[i],], measure = fitmeasure)
		if(length(HabitatUseFit[Species == 'Pinkfoot', Fit]) > 0 ){
			HabUsePF[i] = HabitatUseFit[Species == 'Pinkfoot', Fit]
		} else(HabUsePF[i] = 0)
		if(length(HabitatUseFit[Species == 'Greylag', Fit]) > 0 ){
			HabUseGL[i] = HabitatUseFit[Species == 'Greylag', Fit]
		} else(HabUseGL[i] = 0)
		if(length(HabitatUseFit[Species == 'Barnacle', Fit]) > 0 ){
			HabUseBN[i] = HabitatUseFit[Species == 'Barnacle', Fit]
		} else (HabUseBN[i] = 0)
	}

# --------------------------------------------------------------------------------------------#
#                                  Distance from roost                                        #
# --------------------------------------------------------------------------------------------#
	# Field observations were subset and selected here:
	# Currently 2015 data from months: 9,10,11,12,1,2 & 3
	fieldobs = fread('FieldobsDistancesFromRoost2016-04-25.txt')
	roost = fread('GooseRoosts.txt', skip = 1)
	selectCols = c('PolyRefNum', 'CentroidX', 'CentroidY')
	poly = fread('VejlerneOpenMay2016PolyRef.txt', skip = 1, verbose = FALSE, select = selectCols)
	sp = c('Pinkfoot', 'Barnacle', 'Greylag')
	
	DistToNearestRoostField = CalcDistToRoosts(roost = roost, fields = fieldobs, polyref = poly,
												 species = sp, fieldobs = TRUE)
	RoostDistFitGL = NA
	RoostDistFitPF = NA
	RoostDistFitBN = NA
	for (i in seq_along(seasons)) {
		DistToNearestRoostSim = CalcDistToRoosts(roost = roost,
		                                         fields = forage[Season == seasons[i],],
												                     polyref = poly,
												                     species = sp,
												                     fieldobs = FALSE)
		RoostDistFitGL[i] = CalcForageDistFit(Sim = DistToNearestRoostSim,
		                                      Obs = DistToNearestRoostField, 
		                                      species = 'Greylag',
		                                      measure = fitmeasure)
		RoostDistFitPF[i] = CalcForageDistFit(Sim = DistToNearestRoostSim,
		                                      Obs = DistToNearestRoostField,
		                                      species = 'Pinkfoot',
		                                      measure = fitmeasure)
		RoostDistFitBN[i] = CalcForageDistFit(Sim = DistToNearestRoostSim,
		                                      Obs = DistToNearestRoostField,
		                                      species = 'Barnacle',
		                                      measure = fitmeasure)
	}

# --------------------------------------------------------------------------------------------#
#                                  Numbers left at end                                        #
# --------------------------------------------------------------------------------------------#
	cfg = readLines('TIALMaSSConfig.cfg')
	popn = fread('GoosePopulationData.txt')
	popn[,Day:=Day-365]
	gllos = GetLengthOfStay(config = cfg, species = 'Greylag')
	bnlos = GetLengthOfStay(config = cfg, species = 'Barnacle')
	pflos = GetLengthOfStay(config = cfg, species = 'Pinkfoot')
	PropDayInSimGL = popn[,list(GLNonBreeders=sum(GLNonBreeders != 0)/gllos), by = Season][,GLNonBreeders]
	PropDayInSimBN = popn[,list(BNNonBreeders=sum(BNNonBreeders != 0)/bnlos), by = Season][,BNNonBreeders]
	PropDayInSimPF = popn[,list(PFNonBreeders=sum(PFNonBreeders != 0)/pflos), by = Season][,PFNonBreeders]


	# --------------------------------------------------------------------------------------------#
	#                                     Get AOR occupancy                                       #
	# --------------------------------------------------------------------------------------------#
		aor_pf <- read_tsv("AORPinkfeet.txt", col_types = "iiiiiiiiiii") %>% 
	  tidy_aor(species = "Pinkfoot") %>% 
	  filter(dim == 400) %>% 
		pull(prop_occupied)
	
	aor_bn <- read_tsv("AORBarnacles.txt", col_types = "iiiiiiiiiii") %>% 
	  tidy_aor(species = "Barnacle") %>% 
	  filter(dim == 400) %>% 
	  pull(prop_occupied)
	
	aor_gl <- read_tsv("AORGreylags.txt", col_types = "iiiiiiiiiii") %>% 
	  tidy_aor(species = "Greylag") %>% 
	  filter(dim == 400) %>% 
	  pull(prop_occupied)
	
		
# --------------------------------------------------------------------------------------------#
#                                   Collect and write out                                     #
# --------------------------------------------------------------------------------------------#
	# Calculate the overall model fit
	for (k in seq_along(seasons)) {
	# Goose-only runs:
		PinkfootFit = Weightfit[k]^2 + HabUsePF[k]^2 + DegreeOverlapPT[k]^2 + RoostDistFitPF[k]^2 + PropDayInSimPF[k]^2
		PinkfootFit = PinkfootFit/5
		PinkfootWFit =  DegreeOverlapPT[k] + (HabUsePF[k] * .8) + (RoostDistFitPF[k]*.6) + (Weightfit[k] * .5)
		GreylagFit = HabUseGL[k]^2 + DegreeOverlapGT[k]^2 + RoostDistFitGL[k]^2 + PropDayInSimGL[k]^2 
		GreylagFit = GreylagFit/4
		GreylagWFit =  DegreeOverlapGT[k] + (HabUseGL[k] * .8) + (RoostDistFitGL[k]*.6)
		BarnacleFit = HabUseBN[k]^2 + DegreeOverlapBT[k]^2 + RoostDistFitBN[k]^2 + PropDayInSimBN[k]^2
		BarnacleFit = BarnacleFit/4
		BarnacleWFit =  DegreeOverlapBT[k] + (HabUseBN[k] * .8) + (RoostDistFitBN[k]*.6)

	# Write out the results of the parameter fitting and prepare for next run:
		FitVect = c(Weightfit[k], DegreeOverlapPT[k], DegreeOverlapGT[k], DegreeOverlapBT[k],
			HabUsePF[k], HabUseGL[k], HabUseBN[k], RoostDistFitPF[k], RoostDistFitGL[k], 
			RoostDistFitBN[k], PinkfootFit, GreylagFit, BarnacleFit, PropDayInSimPF[k],
			PropDayInSimGL[k], PropDayInSimBN[k], aor_pf[k], aor_gl[k], aor_bn[k], PinkfootWFit, 
			GreylagWFit, BarnacleWFit)
		FitNames = c('Weightfit', 'FlockSizeFitPT', 'FlockSizeFitGT', 'FlockSizeFitBT',
			'HabUsePF', 'HabUseGL', 'HabUseBN', 'RoostDistFitPF', 'RoostDistFitGL', 
			'RoostDistFitBN', 'PinkfootFit', 'GreylagFit', 'BarnacleFit', 'PropDayInSimPF',
			'PropDayInSimGL', 'PropDayInSimBN', "PropOccupiedPF", "PropOccupiedGL", "PropOccupiedBN",
			"PinkfootWFit", "GreylagWFit", "BarnacleWFit")
		lines = readLines('ParameterValues.txt')
		for (i in 1:numberofparams) {
			param = GetParamString(config = lines[lineno[counter] + (i - 1)])    # Get the parameter name
			value = GetParamValue(config = lines[lineno[counter] + (i - 1)], param = param)  # Get the value
			for (j in seq_along(FitNames)) {
				line = paste(param, value, FitNames[j], FitVect[j], sep = '\t')
				write(line, file = file.path(resultpath, 'ParameterFittingResults.txt'), append = TRUE)
			}
		}
	}	
	# As the last thing we delete the goose output files
	# We do this in case almass exits due to an error. If that happens files from a previous
	# run might still be sitting in the run directory and we would simply analyze these 
	# as if they were a new run 

	if (file.exists("GooseEnergeticsData.txt") && !singlerun)
	{
		file.remove("GooseEnergeticsData.txt")
	}

	if (file.exists("GooseFieldForageData.txt") && !singlerun)
	{
		file.remove("GooseFieldForageData.txt")
	}
}
# Grab the result file and copy it to a safe place
if (counter == runs) {
  resfilename = paste(basename(getwd()), Sys.Date(), 'ParameterFittingResults.txt', sep = '_')
  file.copy(from = file.path(resultpath, 'ParameterFittingResults.txt'),
            to = file.path(finalreslocation, resfilename))
}
# Grab the error file 
  errorfilename = paste(basename(getwd()), counter, Sys.Date(), 'ErrorFile.txt', sep = '_')
  file.copy(from = 'ErrorFile.txt',
            to = file.path(errorfilelocation, errorfilename))

# Report progress to console:
workstation = Sys.info()['nodename']
report = paste(workstation, basename(getwd()), '- run number', counter, '\n', sep = ' ')
cat(report)

# Very last thing is to update the counter:
if (!singlerun) 
{
	counter = counter + 1  
	write(counter, file = 'counter.txt', append = FALSE)
}
F