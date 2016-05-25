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
# -------------------------------------------------------------------------------------------- # 

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
	dropcols = c("Openness", "Grain", "Maize", "Digestability")
	forage = fread('GooseFieldForageData.txt', showProgress = FALSE, drop = dropcols)
	forage = ClassifyHabitatUse(forage, species = 'goose', timed = TRUE)
	# Field data:
	# Currently 2015 data from months: 9,10,11,12,1,2 & 3. See o:\ST_GooseProject\R\ConvertObsToALMaSS.r
	# for details on the data handling
	flocks = fread('o:/ST_GooseProject/Field data/FieldobsFlockSizes2016-05-03.txt')
	
	# Simulation results - max number on a day:
	simflocks = forage[Geese > 0, .(Day, Barnacle, Pinkfoot, Greylag)]
	melted = data.table::melt(simflocks, id.vars = 'Day', variable.name = 'Species', value.name = 'Numbers')
	melted = melted[Numbers != 0,]
	melted[, Day:=NULL]
	melted[, Type:='Simulated']
	dists = rbind(melted, flocks)

	DegreeOverlapB = round(CalcOverlap(dists, species = 'Barnacle', metric = 'Numbers'), digits = 4)
	DegreeOverlapP = round(CalcOverlap(dists, species = 'Pinkfoot', metric = 'Numbers'), digits = 4)
	DegreeOverlapG = round(CalcOverlap(dists, species = 'Greylag', metric = 'Numbers'), digits = 4)

	# Simulation results - timed counts:
	simflocks = forage[Geese > 0, .(Day, BarnacleTimed, PinkfootTimed, GreylagTimed)]
	melted = data.table::melt(simflocks, id.vars = 'Day', variable.name = 'Species', value.name = 'Numbers')
	melted = melted[Numbers != 0,]
	melted[ ,Day:=NULL]
	melted[, Type:='Simulated']
	distsTimed = rbind(melted, flocks)
	
	DegreeOverlapBT = round(CalcOverlap(distsTimed, species = 'Barnacle', metric = 'Numbers'), digits = 4)
	DegreeOverlapPT = round(CalcOverlap(distsTimed, species = 'Pinkfoot', metric = 'Numbers'), digits = 4)
	DegreeOverlapGT = round(CalcOverlap(distsTimed, species = 'Greylag', metric = 'Numbers'), digits = 4)
# --------------------------------------------------------------------------------------------#
#                                    Weights                                                  #
# --------------------------------------------------------------------------------------------#
	massdropcols = c("Energy", "MinForageRate", 'FullTime')
	mass = fread('GooseEnergeticsData.txt', showProgress = FALSE, drop = massdropcols)
	mass = mass[GooseType %in% c('PF', 'PFNB'),]
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
	FieldData = FieldData[HabitatUse != 'Plowed',]
	FieldData[, NMTotal:=sum(N), by=.(Month, Species)]
	FieldData[, Prop:=N/NMTotal]
	
	forage[, Month:=month(as.Date(Day, origin = '2012-01-01'))]  # origin can be anything - we only care about the month.
	HabitatUseFit = CalcHabitatUseFit(FieldData = FieldData, SimData = forage)
	HabUsePF = HabitatUseFit[Species == 'Pinkfoot', Fit]
	HabUseGL = HabitatUseFit[Species == 'Greylag', Fit]
	HabUseBN = HabitatUseFit[Species == 'Barnacle', Fit]

# --------------------------------------------------------------------------------------------#
#                                  Distance from roost                                        #
# --------------------------------------------------------------------------------------------#
	# Field observations were subset and selected here:
	# Currently 2015 data from months: 9,10,11,12,1,2 & 3
	fieldobs = fread('o:/ST_GooseProject/Field data/FieldobsDistancesFromRoost2016-04-25.txt')
	roost = fread('GooseRoosts.txt', skip = 1)
	poly = fread('Vejlerne2015_polyrefs_RenumFBHBOp.txt', skip = 1, verbose = FALSE)
	sp = c('Pinkfoot', 'Barnacle', 'Greylag')
	DistToNearestRoostSim = CalcDistToRoosts(roost = roost, fields = forage, polyref = poly, species = sp, fieldobs = FALSE)
	DistToNearestRoostSim[, Type:='Simulated']
	DistToNearestRoostField = CalcDistToRoosts(roost = roost, fields = fieldobs, polyref = poly, species = sp, fieldobs = TRUE)
	DistToNearestRoostField[, Type:='Fieldobs']
	Distances = rbind(DistToNearestRoostSim[,.(Shortest, Species, Type)], DistToNearestRoostField[,.(Shortest, Species, Type)])

	RoostDistFitGL = CalcOverlap(Distances, species = 'Greylag', metric = 'Shortest')
	RoostDistFitPF = CalcOverlap(Distances, species = 'Pinkfoot', metric = 'Shortest')
	RoostDistFitBN = CalcOverlap(Distances, species = 'Barnacle', metric = 'Shortest')

# --------------------------------------------------------------------------------------------#
#                                  Numbers left at end                                        #
# --------------------------------------------------------------------------------------------#
	cfg = readLines('TIALMaSSConfig.cfg')
	spnb = c('GOOSE_BNNONBREEDERS_STARTNOS', 'GOOSE_GLNONBREEDERS_STARTNOS', 'GOOSE_PFNONBREEDERS_STARTNOS')
	numbers = data.table(Species = c('Barnacle', 'Greylag', 'Pinkfoot'), StartNumbers = rep(-999, 3))
	for (i in seq_along(spnb)) {
		nonbreeders = GetParamValue(config = cfg, param = spnb[i])
		numbers[i, StartNumbers:=nonbreeders]
	}
	popn = fread('GoosePopulationData.txt')
	popn[,Day:=Day-365]

	leavedate = GetParamValue(config = cfg, param = 'GOOSE_GL_LEAVINGDATESTART')
	if(popn[,list(Day=max(Day))] > (365+leavedate)) {
		numbers[Species == 'Greylag', EndNumbers:=popn[Day == 365+leavedate-1,GLNonBreeders]]
	}
	if(popn[,list(Day=max(Day))] <= (365+leavedate)) {
		numbers[Species == 'Greylag', EndNumbers:=popn[nrow(popn), GLNonBreeders]]
	}
	numbers[Species == 'Pinkfoot', EndNumbers:=popn[nrow(popn), PFNonBreeders]]
	numbers[Species == 'Barnacle', EndNumbers:=popn[nrow(popn), BNNonBreeders]]
	numbers[, PropAtEnd:=EndNumbers/StartNumbers]
	PropAtEndGL = numbers[Species == 'Greylag', PropAtEnd]
	PropAtEndPF = numbers[Species == 'Pinkfoot', PropAtEnd]
	PropAtEndBN = numbers[Species == 'Barnacle', PropAtEnd]

	gllos = GetLengthOfStay(config = cfg, species = 'Greylag')
	PropDayInSimGL = popn[,list(GLNonBreeders=sum(GLNonBreeders != 0))]/gllos
	bnlos = GetLengthOfStay(config = cfg, species = 'Barnacle')
	PropDayInSimBN = popn[,list(BNNonBreeders=sum(BNNonBreeders != 0))]/bnlos
	pflos = GetLengthOfStay(config = cfg, species = 'Pinkfoot')
	PropDayInSimPF = popn[,list(PFNonBreeders=sum(PFNonBreeders != 0))]/pflos

# --------------------------------------------------------------------------------------------#
#                                   Collect and write out                                     #
# --------------------------------------------------------------------------------------------#
	# Calculate the overall model fit
	PinkFootFit = Weightfit^2 + HabUsePF^2 + DegreeOverlapPT^2 + RoostDistFitPF^2 + PropDayInSimPF^2
	GreylagFit = HabUseGL^2 + DegreeOverlapGT^2 + RoostDistFitGL^2 + PropDayInSimGL^2
	BarnacleFit = HabUseBN^2 + DegreeOverlapBT^2 + RoostDistFitBN^2 + PropDayInSimBN^2

	# Write out the results of the parameter fitting and prepare for next run:
	FitVect = c(Weightfit, DegreeOverlapPT, DegreeOverlapGT, DegreeOverlapBT,
		 HabUsePF, HabUseGL, HabUseBN, RoostDistFitPF, RoostDistFitGL, 
		 RoostDistFitBN, PinkFootFit, GreylagFit, BarnacleFit, PropAtEndPF, PropAtEndGL,
		 PropAtEndBN, PropDayInSimPF, PropDayInSimGL, PropDayInSimBN)
	FitNames = c('Weightfit', 'FlockSizeFitPT', 'FlockSizeFitGT', 'FlockSizeFitBT',
		 'HabUsePF', 'HabUseGL', 'HabUseBN', 'RoostDistFitPF', 'RoostDistFitGL', 
		 'RoostDistFitBN', 'PinkFootFit', 'GreylagFit', 'BarnacleFit', 'PropAtEndPF',
		 'PropAtEndGL', 'PropAtEndBN', 'PropDayInSimPF', 'PropDayInSimGL', 'PropDayInSimBN')
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
slackr(paste('Run', counter, Sys.time(), sep = ' '))

# If you plots for each run:
# if(counter > 1 & counter < runs) 
# {
	# token = readLines('c:/Users/lada/Dropbox/slackrToken.txt')
	# slackrSetup(channel="@slackbot", api_token = token)
	# library(ggplot2)
	# res = fread(paste0(resultpath, 'ParameterFittingResults.txt'))
	# res[, Type:='Individual']
	# res[FitType %in% c('PinkFootFit', 'BarnacleFit', 'GreylagFit') , Type:='Overall']
	# p = ggplot(res, aes(Value ,Fit)) + geom_line(aes(color = FitType), size = 1) +
	# 	scale_color_brewer(palette = "Set3") + facet_wrap(~Type, scales = 'free_y')
	# ggslackr(p)
# }

# Very last thing is to update the counter:
counter = counter+1  
write(counter, file = 'counter.txt', append = FALSE)

