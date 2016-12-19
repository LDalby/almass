LAND=$1
CFG=$2
INI=$3
#
suffix=_10rep.txt
outfile=$CFG$suffix
cfgfile=$CFG"_TIALMaSSConfig.cfg"
inifile=$INI"_BatchALMaSS.ini"
echo "outfile is " $outfile
echo "cfgfile is " $cfgfile
echo "inifile is " $inifile
errfile="ErrorFile.txt"
slash="/"
mainscenariodirectory=/home/ldalby/workspace/Goose
tempdirectory=/scratch/$SLURM_JOBID/$CFG
resultsdirectory=/home/ldalby/workspace/Goose/Results
RunD=/home/ldalby/workspace/Goose/RunDirectory
echo tempdirectory is $tempdirectory
echo results directory is $resultsdirectory
echo main directory is $maindirectory
# Get the correct config file to the RunDirectory1
# Create the new directory and copy the main RunDirectory to it
mkdir -v $tempdirectory
echo "Done temp directory"
echo cp -r -v $RunD $tempdirectory/RunDirectory1
cp -r -v $RunD $tempdirectory/RunDirectory1
cp -v $mainscenariodirectory/ConfigFiles/$cfgfile $tempdirectory"/RunDirectory1/TIALMaSSConfig.cfg"
cp -v $mainscenariodirectory/ConfigFiles/$inifile $tempdirectory"/RunDirectory1/BatchALMaSS.ini"

if [ "Ve" == "$LAND" ] ; then
    landscape="Vejlerne"
    weather="Vejlerne2013-2014.pre"
else
  if [ "Ri" == "$LAND" ] ; then
    landscape="Ringkoebing"
else
  if [ "Nt" == "$LAND" ] ; then
    landscape="Norway"
else
 # We have an error
   echo "Landscape code not known "$LAND
   exit
fi
fi
fi
echo $landscape

# Copy the relevent landscape files to our work directory
echo cp $mainscenariodirectory"/Landscapes/"$landscape"/"$landscape"_2016.lsb" $tempdirectory"/RunDirectory1/landscape.lsb"
echo cp $mainscenariodirectory"/Landscapes/"$landscape"/"$landscape"_polyrefs_2016.txt" $tempdirectory"/RunDirectory1/polyrefs.txt"
echo cp $mainscenariodirectory"/Landscapes/"$landscape"/"$landscape"_farmrefs_2016.txt" $tempdirectory"/RunDirectory1/farmrefs.txt"
echo cp $mainscenariodirectory"/Landscapes/"$landscape"/"$weather $tempdirectory"/RunDirectory1/weather.txt"

cp $mainscenariodirectory"/Landscapes/"$landscape"/"$landscape"_2016.lsb" $tempdirectory"/RunDirectory1/landscape.lsb"
cp $mainscenariodirectory"/Landscapes/"$landscape"/"$landscape"_polyrefs_2016.txt" $tempdirectory"/RunDirectory1/polyrefs.txt"
cp $mainscenariodirectory"/Landscapes/"$landscape"/"$landscape"_farmrefs_2016.txt" $tempdirectory"/RunDirectory1/farmrefs.txt"
cp $mainscenariodirectory"/Landscapes/"$landscape"/"$weather $tempdirectory"/RunDirectory1/weather.txt"

copydirbase=$tempdirectory"/RunDirectory"
copydir=$tempdirectory"/RunDirectory1"
f=$copydirbase
slash="/"
# Copy the rundirectory X number of times:
for i in {2..10} 
do
f=$copydirbase"$i"$slash
echo $f
echo cp -r $copydir $f
cp -r -v $copydir $f
sleep 5
done

# change directory to the local /home/ldalby/mainscenariodirectory/Goose/RunDirectory1-directory, and run:

cd $tempdirectory/RunDirectory1
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory2
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory3
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory4
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory5
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory6
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory7
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory8
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory9
./almass_cmdline > out &
sleep 5

cd $tempdirectory/RunDirectory10
./almass_cmdline > out &
sleep 5

wait

# Call the batch.r script to analyze the results
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory1/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory2/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory3/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory4/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory5/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory6/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory7/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory8/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory9/batch.r
/com/R/3.1.2/lib64/R/bin/Rscript $tempdirectory/RunDirectory10/batch.r

wait

outf=$resultsdirectory$slash$outfile

copydirbase=$tempdirectory"/RunDirectory"
f=$copydirbase
file="ParameterFittingResults.txt"
slash="/"

echo cp $copydirbase"1"$slash$file $outf
cp -v $copydirbase"1"$slash$file $outf

for i in {2..10} 
do
 f=$copydirbase"$i"$slash$file
 echo $f
 cat $f >> $outf
done


rm -r $tempdirectory

