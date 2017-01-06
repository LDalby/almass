#!/bin/bash
cd /home/ldalby/workspace/Goose/ParamFitting
chmod +x FileDist.r
/home/com/R/3.1.2/bin/Rscript FileDist.r $SLURM_JOBID

cd /scratch/$SLURM_JOBID/GooseParamFit/WD1
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD2
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD3
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD4
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD5
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD6
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD7
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD8
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD9
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD10
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD11
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD12
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/GooseParamFit/WD13
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5
