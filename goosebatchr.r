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

library(slackr)  # Only needed if you want Slack to give you updates on progress

# Setup work directory (done automatically when distributing the files, therefore blank):

# To get the line number in the parameter list we make a vector of line numbers for the
# first of the parameters in each run:
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
		value = GetParamValue(lines[lineno[counter]+(i-1)], param)  # Get the value
		line = paste(param, value, NA, NA, sep = '\t')
		write(line, file = file.path(resultpath, 'ParameterFittingResults.txt'), append = TRUE)
	}
}
# --------------------------------------------------------------------------------------------#
#                                    Flock sizes                                              #
# --------------------------------------------------------------------------------------------#

if(file.exists("GooseFieldForageData.txt"))
{
	forage = fread('GooseFieldForageData.txt', showProgress = FALSE)
	forage[, Date:=as.Date(Day, origin = as.Date('2009-01-01'))]
	forage = forage[data.table::month(Date) %in% c(9:12,1:3)]
	forage = ClassifyHabitatUse(forage, species = 'goose', timed = TRUE)
	# Field data:
	# Currently 2015 data from months: 9,10,11,12,1,2 & 3. See o:\ST_GooseProject\R\ConvertObsToALMaSS.r
	# for details on the data handling
	flocks = fread('o:/ST_GooseProject/Field data/FieldobsFlockSizes2016-05-03.txt')
	seasons = unique(forage[, SeasonNumber])
	DegreeOverlapBT = NA
	DegreeOverlapPT = NA
	DegreeOverlapGT = NA
	for (i in seq_along(seasons)) {
	# Simulation results - timed counts:
		simflocks = forage[Geese > 0 & SeasonNumber == seasons[i], .(Day, BarnacleTimed, PinkfootTimed, GreylagTimed)]
		melted = data.table::melt(simflocks, id.vars = 'Day', variable.name = 'Species', value.name = 'Numbers')
		melted = melted[Numbers != 0,]
		melted[ ,Day:=NULL]
		melted[, Type:='Simulated']
		distsTimed = rbind(melted, flocks)

		DegreeOverlapBT[i] = round(CalcOverlap(distsTimed, species = 'Barnacle', metric = 'Numbers'), digits = 4)
		DegreeOverlapPT[i] = round(CalcOverlap(distsTimed, species = 'Pinkfoot', metric = 'Numbers'), digits = 4)
		DegreeOverlapGT[i] = round(CalcOverlap(distsTimed, species = 'Greylag', metric = 'Numbers'), digits = 4)
	}

# --------------------------------------------------------------------------------------------#
#                                    Weights                                                  #
# --------------------------------------------------------------------------------------------#
	mass = fread('GooseEnergeticsData.txt', showProgress = FALSE)
	mass = mass[GooseType %in% c('PF', 'PFNB'),]
	mass[,Day:=Day-365]
	mass = mass[, Date:=as.Date(Day, origin = as.Date('2009-01-01'))]
	mass = mass[data.table::month(Date) %in% c(9:12,1:3)]
	api = fread('APIdata.txt')
	Weightfit = NA
	for (i in seq_along(seasons)) {
		Weightfit[i] = CalcWeightFit(mass[SeasonNumber == seasons[i],], api)
	}

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
		HabitatUseFit = CalcHabitatUseFit(FieldData = FieldData, SimData = forage[SeasonNumber == seasons[i],])
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
	fieldobs = fread('o:/ST_GooseProject/Field data/FieldobsDistancesFromRoost2016-04-25.txt')
	roost = fread('GooseRoosts.txt', skip = 1)
	poly = fread('VejlerneOpenMay2016PolyRef.txt', skip = 1, verbose = FALSE)
	sp = c('Pinkfoot', 'Barnacle', 'Greylag')
	
	DistToNearestRoostField = CalcDistToRoosts(roost = roost, fields = fieldobs, polyref = poly, species = sp, fieldobs = TRUE)
	DistToNearestRoostField[, Type:='Fieldobs']
	RoostDistFitGL = NA
	RoostDistFitPF = NA
	RoostDistFitBN = NA
	for (i in seq_along(seasons)) {
		DistToNearestRoostSim = CalcDistToRoosts(roost = roost, fields = forage[SeasonNumber == seasons[i],], polyref = poly, species = sp, fieldobs = FALSE)
		DistToNearestRoostSim[, Type:='Simulated']
		Distances = rbind(DistToNearestRoostSim[,.(Shortest, Species, Type)], DistToNearestRoostField[,.(Shortest, Species, Type)])

		RoostDistFitGL[i] = CalcOverlap(Distances, species = 'Greylag', metric = 'Shortest')
		RoostDistFitPF[i] = CalcOverlap(Distances, species = 'Pinkfoot', metric = 'Shortest')
		RoostDistFitBN[i] = CalcOverlap(Distances, species = 'Barnacle', metric = 'Shortest')
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
	PropDayInSimGL = popn[,list(GLNonBreeders=sum(GLNonBreeders != 0)/gllos), by = SeasonNumber][,GLNonBreeders]
	PropDayInSimBN = popn[,list(BNNonBreeders=sum(BNNonBreeders != 0)/bnlos), by = SeasonNumber][,BNNonBreeders]
	PropDayInSimPF = popn[,list(PFNonBreeders=sum(PFNonBreeders != 0)/pflos), by = SeasonNumber][,PFNonBreeders]

# --------------------------------------------------------------------------------------------#
#                                 Openness distribution                                       #
# --------------------------------------------------------------------------------------------#
	# observedopen = fread('C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/ObservedOpenness.txt')
	# sim = forage[, .(Day, Polyref, Openness, BarnacleTimed, PinkfootTimed, GreylagTimed)]
	# setnames(sim, old = c('BarnacleTimed', 'PinkfootTimed', 'GreylagTimed'),
	# 			 new = c('Barnacle', 'Pinkfoot', 'Greylag'))
	# melted = melt(sim, id.vars = c('Day', 'Polyref', 'Openness'),
	# 	variable.name = 'Species', value.name = 'Numbers')
	# melted = melted[Numbers != 0,]
	# melted[,Type:='Simulated']
	# full = rbind(observedopen, melted[,.(Openness, Species, Type)])
	
	# OpenOverlapGL = CalcOverlap(full[Species == 'Greylag',], species = 'greylag', metric = 'Openness')	
	# OpenOverlapPF = CalcOverlap(full[Species == 'Pinkfoot',], species = 'Pinkfoot', metric = 'Openness')	
	# OpenOverlapBN = CalcOverlap(full[Species == 'Barnacle',], species = 'Barnacle', metric = 'Openness')	

# --------------------------------------------------------------------------------------------#
#                          Huntingbag - ONLY USED IN FULL MODEL                               #
# --------------------------------------------------------------------------------------------#
	# Remember to handle these fits when writing out and summarizing 
	bag = fread('o:/ST_GooseProject/ALMaSS/HunterModelTesting/SurveyResults/THS_JAM_Goosehunters_2013.csv')
	bag = bag[!is.na(ABMhunter),.(ABMhunter, Greylag, Pinkfeet)]
	setnames(bag, old = 'Pinkfeet', new = 'Pinkfoot')
	bag = melt(bag, id.vars = 'ABMhunter', measure.vars = c('Greylag', 'Pinkfoot'), variable.name = 'Species', value.name = 'NoShot')
	bag[, Type:='Fieldobs']
	
	GLBagOverlap = rep(NA, length(seasons))
	PFBagOverlap = rep(NA, length(seasons))
	totalbagpf = rep(NA, length(seasons))
	totalbaggl = rep(NA, length(seasons))
	avgbaggl = rep(NA, length(seasons))
	avgbagpf = rep(NA, length(seasons))
	simbag = fread('HuntingBagRecord.txt')
	if(nrow(simbag) != 0){
		simbag[, Species:=sapply(GameType, ConvertGameType)]
		simbag[, NoShot:=.N, by = list(Species, HunterRef, SeasonNumber)]
		sim = unique(simbag[, .(HunterRef, Species, NoShot, SeasonNumber)])
		sim[, Type:='Simulated']
		
		for (m in seq_along(seasons)) {
			tmp = sim[SeasonNumber == m,]
			full = rbind(bag[NoShot != 0, .(Species, NoShot, Type)], tmp[, .(Species, NoShot, Type)])
			full[, TotalBag:=sum(NoShot), by = c('Species', 'Type')]
			full[, AvgBag:=mean(NoShot), by = c('Species', 'Type')]
			GLBagOverlap[m] = CalcOverlap(data = full, species = 'Greylag', metric = 'NoShot')
			PFBagOverlap[m] = CalcOverlap(data = full, species = 'Pinkfoot', metric = 'NoShot')
			totalbagpf[m] = full[Species == 'Pinkfoot' & Type == 'Simulated', unique(TotalBag)]
			totalbaggl[m] = full[Species == 'Greylag' & Type == 'Simulated', unique(TotalBag)]
			avgbagpf[m] = full[Species == 'Pinkfoot' & Type == 'Simulated', unique(AvgBag)]
			avgbaggl[m] = full[Species == 'Greylag' & Type == 'Simulated', unique(AvgBag)]
		}
	}

	ho = fread('HuntingOpportunities.txt') 
	if(nrow(ho) != 0){
		ho[TotalBag != 0, N:=.N, by = Year]
		ho[, PropWithBag:=N/.N, by = Year]
		propwithbag = unique(ho[!is.na(PropWithBag),.(PropWithBag, Year)])
	}


# --------------------------------------------------------------------------------------------#
#                                   Collect and write out                                     #
# --------------------------------------------------------------------------------------------#
	# Calculate the overall model fit
	for (k in seq_along(seasons)) {
		# Full model runs:
		PinkfootFit = Weightfit[k]^2 + HabUsePF[k]^2 + DegreeOverlapPT[k]^2 + RoostDistFitPF[k]^2 + PropDayInSimPF[k]^2 + PFBagOverlap[k]^2
		PinkfootFit = PinkfootFit/6
		GreylagFit = HabUseGL[k]^2 + DegreeOverlapGT[k]^2 + RoostDistFitGL[k]^2 + PropDayInSimGL[k]^2 + GLBagOverlap[k]^2
		GreylagFit = GreylagFit/5
		BarnacleFit = HabUseBN[k]^2 + DegreeOverlapBT[k]^2 + RoostDistFitBN[k]^2 + PropDayInSimBN[k]^2
		BarnacleFit = BarnacleFit/4

	# Write out the results of the parameter fitting and prepare for next run:
		FitVect = c(Weightfit[k], DegreeOverlapPT[k], DegreeOverlapGT[k], DegreeOverlapBT[k],
			HabUsePF[k], HabUseGL[k], HabUseBN[k], RoostDistFitPF[k], RoostDistFitGL[k], 
			RoostDistFitBN[k], PinkfootFit, GreylagFit, BarnacleFit, PropDayInSimPF[k],
			PropDayInSimGL[k], PropDayInSimBN[k], PFBagOverlap[k], GLBagOverlap[k], totalbagpf[k],
			totalbaggl[k], avgbagpf[k], avgbaggl[k], propwithbag[k])
		FitNames = c('Weightfit', 'FlockSizeFitPT', 'FlockSizeFitGT', 'FlockSizeFitBT',
			'HabUsePF', 'HabUseGL', 'HabUseBN', 'RoostDistFitPF', 'RoostDistFitGL', 
			'RoostDistFitBN', 'PinkfootFit', 'GreylagFit', 'BarnacleFit', 'PropDayInSimPF',
			'PropDayInSimGL', 'PropDayInSimBN', 'BagOverlapPF', 'BagOverlapGL', 'TotalBagPF',
			'TotalBagGL', 'AvgBagPF', 'AvgBagGL', 'PropWithBag')
	# Goose-only runs:
	# 	PinkfootFit = Weightfit[k]^2 + HabUsePF[k]^2 + DegreeOverlapPT[k]^2 + RoostDistFitPF[k]^2 + PropDayInSimPF[k]^2
	# 	PinkfootFit = PinkfootFit/5
	# 	GreylagFit = HabUseGL[k]^2 + DegreeOverlapGT[k]^2 + RoostDistFitGL[k]^2 + PropDayInSimGL[k]^2 
	# 	GreylagFit = GreylagFit/4
	# 	BarnacleFit = HabUseBN[k]^2 + DegreeOverlapBT[k]^2 + RoostDistFitBN[k]^2 + PropDayInSimBN[k]^2
	# 	BarnacleFit = BarnacleFit/4

	# # Write out the results of the parameter fitting and prepare for next run:
	# 	FitVect = c(Weightfit[k], DegreeOverlapPT[k], DegreeOverlapGT[k], DegreeOverlapBT[k],
	# 		HabUsePF[k], HabUseGL[k], HabUseBN[k], RoostDistFitPF[k], RoostDistFitGL[k], 
	# 		RoostDistFitBN[k], PinkfootFit, GreylagFit, BarnacleFit, PropDayInSimPF[k],
	# 		PropDayInSimGL[k], PropDayInSimBN[k])
	# 	FitNames = c('Weightfit', 'FlockSizeFitPT', 'FlockSizeFitGT', 'FlockSizeFitBT',
	# 		'HabUsePF', 'HabUseGL', 'HabUseBN', 'RoostDistFitPF', 'RoostDistFitGL', 
	# 		'RoostDistFitBN', 'PinkfootFit', 'GreylagFit', 'BarnacleFit', 'PropDayInSimPF',
	# 		'PropDayInSimGL', 'PropDayInSimBN')
		lines = readLines('ParameterValues.txt')
		for (i in 1:numberofparams) {
			param = GetParamString(config = lines[lineno[counter]+(i-1)])    # Get the parameter name
			value = GetParamValue(lines[lineno[counter]+(i-1)], param)  # Get the value
			for (j in seq_along(FitNames)) {
				line = paste(param, value, FitNames[j], FitVect[j], sep = '\t')
				write(line, file = file.path(resultpath, 'ParameterFittingResults.txt'), append = TRUE)
			}
		}
	}	
	# As the last thing we delete the goose output files
	# We do this in case almass exits due to an error. If that happens files from a previous
	# run might still be sitting in the run directory and we would simply analyze these as if they were the new 
	# run and get results identical to the previous run

	if(file.exists("GooseEnergeticsData.txt") && !singlerun)
	{
		file.remove("GooseEnergeticsData.txt")
	}

	if(file.exists("GooseFieldForageData.txt") && !singlerun)
	{
		file.remove("GooseFieldForageData.txt")
	}
}

# Report progress to console:
report = paste0(basename(getwd()), ' - run number ', counter, '\n')
cat(report)

# If you want updates:
token = readLines('c:/Users/lada/Dropbox/slackrToken.txt')  # Your token and nothing else in a file. 
slackrSetup(channel="@lars", api_token = token)
slackr(paste(Sys.time(), report, sep = ' '))

# Very last thing is to update the counter:
if(!singlerun) 
{
	counter = counter+1  
	write(counter, file = 'counter.txt', append = FALSE)
}
