# VERSION_STAMP=190412
VERSION_STAMP=191115

for DATA_PREFIX in mikkelsen2019 chen2017 romanov2017 moffitt2018 chen2017 tabula_muris mousebrain campbell2017_lvl1 campbell2017_lvl2
do 
	# echo $DATA_PREFIX $VERSION_STAMP &> es_calculation.log.$DATA_PREFIX.txt & 
	time Rscript es_calculation.R $DATA_PREFIX $VERSION_STAMP &> log.es_calculation.$DATA_PREFIX.txt &
done

wait;
echo "Done bash script"
