library(devtools)
library(roxygen2)
# ralmass
setwd('C:/Users/lada/Git/ralmass')
document()

install_github('LDalby/ralmass')
# install_github('LDalby/ralmass', ref = 'devel1')

use_rstudio()
use_rcpp()






# loggr
setwd('C:/Users/lada/Git/loggr')
document()

install_github('LDalby/loggr')




# Render rmd file
library(rmarkdown)
# Model testing
render(input = "c:/Users/lada/Git/almass/GooseModelTesting.Rmd",
       output_dir = "o:/ST_Lada/Projekter/GBB/",
       output_file = paste0("GooseModelTesting", Sys.Date(), ".html"))

# Parameter fitting
render(input = "c:/Users/lada/Git/almass/ParameterFittingGoose.Rmd",
       output_dir = "o:/ST_GooseProject/ALMaSS/GooseParameterFitting/",
       output_file = paste0("GooseParameterFitting", Sys.Date(), ".html"))

