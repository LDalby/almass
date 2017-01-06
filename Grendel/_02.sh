#!/bin/bash
# Get the parameter
chmod +x PreRunSetup.r
/home/com/R/3.1.2/bin/Rscript PreRunSetup.r
# Run ALMaSS
./almass_cmdline
# Call R to analyze results
chmod +x batchr.r
/home/com/R/3.1.2/bin/Rscript batchr.r
