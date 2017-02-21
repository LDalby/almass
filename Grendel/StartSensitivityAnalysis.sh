#!/bin/bash
cd /home/ldalby/workspace/Goose/SensitivityAnalysis
chmod +x FileDistSensitivityAnalysis.r
/home/com/R/3.1.2/bin/Rscript FileDistSensitivityAnalysis.r $SLURM_JOB_ID

for i in {1..22}; do
	cd /scratch/$SLURM_JOB_ID/WD"$i"
	chmod +x _01_BatchLoop.sh
	./_01_BatchLoop.sh > out &
	sleep 5
done

wait

cd /home/ldalby/workspace/Goose/SensitivityAnalysis
chmod +x CollectResultsSensitivityAnalysis.r
/home/com/R/3.1.2/bin/Rscript CollectResultsSensitivityAnalysis.r $SLURM_JOB_ID
