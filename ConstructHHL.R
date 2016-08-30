# Construct new Hunter_Hunting_Locations.txt file
# Construct the vector of check frequencies
library(data.table)
library(ralmass)

everyday = round(746*.16)
afewtimes = round(746*.32)
everyweek = round(746*.19)
notsooften = round(746*.21)
never = round(746*.12)
checkfreq = c(rep(1, everyday), rep(round(3/7, 3), afewtimes), rep(round(1/7, 3), everyweek),
 rep(round(1/14, 3), notsooften), rep(0, never)) 
length(checkfreq)  # One too long, but we sample it later, so no problem.

HHL = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Hunter/746_vejhunter_behaviour_18-08-2016.txt'
hhl = fread(HHL, skip = 1)
hhl[, GooseLookChance:=sample(checkfreq, nrow(hhl), replace = FALSE)]
hhl[GooseLookChance == 0,list(.N)]  # 89 approx 12% as it should be.
newhhl = 'C:/MSV/ALMaSS_inputs/GooseManagement/Vejlerne/Hunter/746_VejlerneHuntersDiffGLC.txt'
WriteAlmassInput(table = hhl, pathtofile = newhhl, headers = TRUE) 