#!/bin/bash
cd /home/ldalby/workspace/Goose/ParamFitting
chmod +x FileDist.r
/home/com/R/3.4.1/bin/Rscript FileDist.r $SLURM_JOB_ID

for i in {1..22}; do
	cd /scratch/$SLURM_JOB_ID/WD"$i"
	chmod +x _01_BatchLoop.sh
	./_01_BatchLoop.sh > out &
	sleep 5
done

wait

cd /home/ldalby/workspace/Goose/ParamFitting
chmod +x CollectResults.r
/home/com/R/3.4.1/bin/Rscript CollectResults.r $SLURM_JOB_ID
