pcks = c('raster', 'devtools', 'rgdal', 'rgeos', 'rasterVis', 'R.utils')
path = "C:\\Program Files\\R\\R-3.2.4\\library"
install.packages(pcks, lib = path, dependencies = TRUE)

library(devtools)
install_github('LDalby/ralmass', ref = 'master')
install_github('LDalby/ralmass', ref = 'grendel')

