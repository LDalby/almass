# Install ralmass on Grendel
if(!'/home/ldalby/R/packages' %in% .libPaths()) {
	.libPaths('/home/ldalby/R/packages')
}

library(devtools)

lib = "/home/ldalby/R/packages/"
# This is needed to make the install_github() method work:
options(download.file.method = "wget")
install_github('ldalby/ralmass', ref = 'grendel', lib = lib)  # The grendel branch without any need for rgdal
