#!/bin/bash
cd /home/ldalby/workspace/Goose/ParamFitting
chmod +x FileDist.r
/home/com/R/3.1.2/bin/Rscript FileDist.r $SLURM_JOBID

cd /scratch/$SLURM_JOBID/WD1
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD2
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD3
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD4
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD5
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD6
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD7
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD8
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD9
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD10
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD11
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD12
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOBID/WD13
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5
