#!/bin/bash
# Get the parameter
chmod +x PreRunSetup.r
/home/com/R/3.4.1/bin/Rscript PreRunSetup.r
# Run ALMaSS
./almass_cmdline > out
# Call R to analyze results
chmod +x batchr.r
/home/com/R/3.4.1/bin/Rscript batchr.r
