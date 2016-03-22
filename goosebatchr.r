# Title: goosebatchr
# Updated: March 8th 2016
# Author: Lars Dalby

# This script will run tests of the fit of simulation results to field data on geese
# as well as copy the results from almass and the Goose_Params.txt to a specified location.
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
library(lubridate)
library(readxl)

# library(slackr)  # Only needed if you want Slack to give you updates on progress

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
resultpath = 'c:/MSV/WorkDirectory/'
forage = fread(paste(resultpath, 'GooseFieldForageData.txt', sep = ''))
forage = fread('GooseFieldForageData.txt', showProgress = FALSE)
forage = ClassifyHabitatUse(forage, species = 'goose')

if(length(grep("GooseFieldForageData.txt", dir())) != 0)
{
	# Field data:
	fieldobs = fread('fugledata_20150320_obs_clean.csv')
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

	DegreeOverlapB = round(CalcOverlab(dists, species = 'Barnacle'), digits = 2)
	DegreeOverlapP = round(CalcOverlab(dists, species = 'Pinkfoot'), digits = 2)
	DegreeOverlapG = round(CalcOverlab(dists, species = 'Greylag'), digits = 2)

	# Simulation results - timed counts:
	simflocks = forage[Geese > 0, .(Day, BarnacleTimed, PinkfootTimed, GreylagTimed)]
	melted = data.table::melt(simflocks, id.vars = 'Day', variable.name = 'Species', value.name = 'Numbers')
	melted = melted[Numbers != 0,]
	melted[ ,Day:=NULL]
	melted[, Type:='Simulated']
	distsTimed = rbind(melted, flocks)
	
	DegreeOverlapBT = round(CalcOverlab(distsTimed, species = 'Barnacle'), digits = 2)
	DegreeOverlapPT = round(CalcOverlab(distsTimed, species = 'Pinkfoot'), digits = 2)
	DegreeOverlapGT = round(CalcOverlab(distsTimed, species = 'Greylag'), digits = 2)
# --------------------------------------------------------------------------------------------#
#                                    Weights                                                  #
# --------------------------------------------------------------------------------------------#
	mass = fread('GooseEnergeticsData.txt', showProgress = FALSE)
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
	FieldData[HabitatUse == 'Stubble undersown', HabitatUse:='Grass']
	FieldData[HabitatUse == 'UnharvestedBarley', HabitatUse:='Stubble']
	FieldData[, NMTotal:=sum(N), by=.(Month, Species)]
	FieldData[, Prop:=N/NMTotal]
	FieldData[rep(seq(.N),N), .(Month, HabitatUse, N, Species, NMTotal, Prop), by = Species]
	
	forage[, Month:=month(as.Date(Day, origin = '2012-01-01'))]
	# Pinkfoot:
	hbpf = forage[Month > 8 | Month == 1, .(Pinkfoot, HabitatUsePF, Month)]
	hbpf[, Species:='Pinkfoot']
	hbpf = hbpf[complete.cases(hbpf),]
	setnames(hbpf, old = c('HabitatUsePF', 'Pinkfoot'), new = c('HabitatUse', 'N'))
	# Greylag:
	hbgl = forage[Month > 8 | Month == 1, .(Greylag, HabitatUseGL, Month)]
	hbgl[, Species:='Greylag']
	hbgl = hbgl[complete.cases(hbgl),]
	setnames(hbgl, old = c('HabitatUseGL', 'Greylag'), new = c('HabitatUse', 'N'))
	# Barnacle:
	hbbn = forage[Month > 8 | Month == 1, .(Barnacle, HabitatUseBN, Month)]
	hbbn[, Species:='Barnacle']
	hbbn = hbbn[complete.cases(hbbn),]
	setnames(hbbn, old = c('HabitatUseBN', 'Barnacle'), new = c('HabitatUse', 'N'))
	# Full data:
	hb = rbind(hbpf, hbbn, hbgl)
	setkeyv(hb, c('Species', 'Month'))
	
	hb[, NMTotal:=sum(N), by = .(Month, Species)]
	hb[, Prop:=N/NMTotal]
	hb[, Month:=as.factor(Month)]
	setkeyv(hb, c('Species', 'Month'))
	
	HabitatUseFit = CalcHabitatUseFit(FieldData = FieldData, SimData = forage)
	HabMonths = nrow(unique(HabitatUseFit[, .(Month)]))
	HabitatUseFit[, SeasonFit:=sum(Fit, na.rm = TRUE)/HabMonths, by = Species]
	HabitatUseFit = unique(HabitatUseFit[, .(Species, SeasonFit)])
	HabUsePF = HabitatUseFit[Species == 'Pinkfoot', SeasonFit]
	HabUseGL = HabitatUseFit[Species == 'Greylag', SeasonFit]
	HabUseBN = HabitatUseFit[Species == 'Barnacle', SeasonFit]
	# Calculate the overall model fit
	PinkFootFit = Weightfit + HabUsePF + DegreeOverlapPT
	GreylagFit = HabUseGL + DegreeOverlapGT
	BarnacleFit = HabUseBN + DegreeOverlapBT

	# Write out the results of the parameter fitting and prepare for next run:
	FitVect = c(Weightfit, DegreeOverlapPT, DegreeOverlapGT, DegreeOverlapPT,
		 HabUsePF, HabUseGL, HabUseBN)
	FitNames = c('Weightfit', 'DegreeOverlapPT', 'DegreeOverlapGT', 'DegreeOverlapPT',
		 'HabUsePF', 'HabUseGL', 'HabUseBN')
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
# If you want updates:
# slackrSetup(channel="@name", api_token = INSERT YOUR TOKEN)
# slackr(paste(counter))

# Report progress to console:
cat(paste0('Run number ', counter, '\n'))

# Very last thing is to update the counter:
counter = counter+1  
write(counter, file = 'counter.txt', append = FALSE)