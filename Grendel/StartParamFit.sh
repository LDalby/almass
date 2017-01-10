#!/bin/bash
cd /home/ldalby/workspace/Goose/ParamFitting
chmod +x FileDist.r
/home/com/R/3.1.2/bin/Rscript FileDist.r $SLURM_JOB_ID

cd /scratch/$SLURM_JOB_ID/WD1
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD2
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD3
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD4
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD5
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD6
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD7
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD8
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD9
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD10
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD11
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD12
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

cd /scratch/$SLURM_JOB_ID/WD13
chmod +x _01_BatchLoop.sh
./_01_BatchLoop.sh > out &
sleep 5

wait