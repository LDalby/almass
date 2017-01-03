#!/bin/bash
# Get the parameter
chmod +x PreRunSetup.r
./PreRunSetup.r
# Run ALMaSS
./almass_cmdline
# Call R to analyze results
chmod +x batchr.r
batchr.r
