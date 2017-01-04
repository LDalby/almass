#!/bin/bash

chmod +x FileDist.r
./FileDist.r

cd /home/lars/ALMaSS/tempdirectory/WD1
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /home/lars/ALMaSS/tempdirectory/WD2
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5
