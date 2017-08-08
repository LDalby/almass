# Short script to render rmd files 

if ("Linux" == sysinfo[match("sysname", names(sysinfo))]) {
  gitpath = '~/git/almass/'
  outpath <- "~/Desktop/"
}
if ("Windows" == sysinfo[match("sysname", names(sysinfo))]) {
  gitpath = 'c:/MSV/WorkDirectory/'
  outpath <- "o:/ST_Lada/Projekter/GBB/"
}



# Render rmd file
library(rmarkdown)
# Model testing
render(input = file.path(gitpath, "GooseModelTesting.Rmd"),
       output_dir = outpath,
       output_file = paste0("GooseModelTesting", Sys.Date(), ".html"))

# Parameter fitting
render(input = "c:/Users/lada/Git/almass/ParameterFittingGoose.Rmd",
       output_dir = "o:/ST_GooseProject/ALMaSS/GooseParameterFitting/",
       output_file = paste0("GooseParameterFitting", Sys.Date(), ".html"))

