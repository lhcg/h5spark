#!/bin/bash


#SBATCH -p regular
#SBATCH -N 100
#SBATCH -t 00:04:00
#SBATCH -e mysparkjob_%j.err
#SBATCH -o mysparkjob_%j.out
#SBATCH --ccm
##SBATCH --reservation=INC0082872
#SBATCH --qos=premium
##SBATCH --volume="/global/cscratch1/sd/jialin/spark_tmp_dir/climate:/tmp:perNodeCache=size=200G"
module unload spark/hist-server
module load spark
module load collectl
start-collectl.sh 
start-all.sh

# to create a fat jar
# sbt assembly
# test the multiple hdf5 file reader:
export SPARK_LOCAL_DIRS="/tmp"
export LD_LIBRARY_PATH=$LD_LBRARY_PATH:$PWD/lib

###load single large hdf5 file####
repartition="3000"
#inputfile="/global/cscratch1/sd/jialin/climate/oceanTemps.hdf5"
inputfile="/global/cscratch1/sd/jialin/dayabay/ost1/oceanTemps.hdf5"
#inputfile="/global/cscratch1/sd/jialin/dayabay/2016/data/2.h5"
#inputfile = "/global/cscratch1/sd/gittens/large-climate-dataset/data/production/T.h5"
#inputfile="/global/cscratch1/sd/jialin/dayabay/dayabay-final.h5"
dataset="temperatures"
#dataset="charge"
#dataset="rows"
#dataset="autoencoded"



spark-submit --verbose\
  --master $SPARKURL\
  --driver-memory 100G\
  --executor-cores 32 \
  --driver-cores 32  \
  --num-executors=99 \
  --executor-memory 105G\
  --class org.nersc.io.readtest\
  --conf spark.eventLog.enabled=true\
  --conf spark.eventLog.dir=$SCRATCH/spark/spark_event_logs\
  target/scala-2.10/h5spark-assembly-1.0.jar \
  $repartition $inputfile $dataset 


#  $argsjava
#$csvlist $partition $repartition $inputfile $dataset $rows
# check history server information####
# module load spark/hist-server
# ./run_history_server.sh $EVENT_LOGS_DIR 
rm /global/cscratch1/sd/jialin/spark_tmp_dir/*
stop-all.sh
stop-collectl.sh
