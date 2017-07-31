#!/bin/bash
cd /home/ldalby/workspace/Goose/StandardRun
chmod +x FileDistStandardRun.r
/home/com/R/3.1.2/bin/Rscript FileDistStandardRun.r $SLURM_JOB_ID

for i in {1..2}; do
	cd /scratch/$SLURM_JOB_ID/WD"$i"
	# Run ALMaSS
	./almass_cmdline > out
	sleep 5
done

wait

cd /home/ldalby/workspace/Goose/StandardRun
chmod +x CollectResultsStandardRun.r
/home/com/R/3.1.2/bin/Rscript CollectResultsStandardRun.r $SLURM_JOB_ID

wait
