#!/bin/sh

#$ -o /dev/null
#$ -e /dev/null
#$ -pe pe_1 1
#$ -V
#$ -cwd
#$ -l exclusive.c
#$ -l h_rt=12:00:00
#$ -l ram.c=120G

export HADOOP_HOME=/global/common/carver/tig/hadoop/hadoop-0.20.2-cdh3u2/
export JAVA_HOME=/global/common/carver/tig/java/jdk1.6.0_13/
export HADOOP_CONF_DIR="$HOME/.hadoop-mendel"
export HADOOP_LOG_DIR=$SCRATCH/logs/

# if the file 'local' exist then create 
# a copy of everything on /scratch
#
if [ -e "${HADOOP_CONF_DIR}/local" ] ; then
  if [ ! -e "/scratch" ] ; then
    echo "Local mode requires a local /scratch dir"
    exit -1
  fi
  echo "Copying key files to local"
  LOCAL=/scratch/${USER}
  mkdir -p $LOCAL
  rsync -avz $HADOOP_HOME/{bin,conf,*jar,ivy,lib,sbin,webapps} $LOCAL/hadoop
  rsync -avz $HADOOP_CONF_DIR/* $LOCAL/hadoop/conf/
  rsync -avz $JAVA_HOME/{bin,jre,lib} $LOCAL/java

  export HADOOP_HOME=$LOCAL/hadoop
  export HADOOP_CONF_DIR=$HADOOP_HOME/conf
  export HADOOP_LOG_DIR=$LOCAL/logs/
  export JAVA_HOME=$LOCAL/java
  [ -e $HADOOP_LOG_DIR ] || mkdir $HADOOP_LOG_DIR
fi

export PATH=$PATH:$HADOOP_HOME/bin/
export HADOOP_PID_DIR=$HADOOP_LOG_DIR/pids/

while [ true ]  ; do
  hadoop tasktracker
  sleep 60
done


#export HADOOP_HOME=/global/common/carver/tig/hadoop/hadoop-0.20.2-cdh3u2/
#export JAVA_HOME=/global/common/carver/tig/java/jdk1.6.0_13/
#export HADOOP_CONF_DIR="$HOME/.hadoop-mendel"
#export HADOOP_LOG_DIR=$SCRATCH/logs/
#export HADOOP_PID_DIR=$SCRATCH/logs/pids/
#export HADOOP_HEAPSIZE=2000
#export PATH=$PATH:$HADOOP_HOME/bin/
#
#hadoop-daemon.sh start tasktracker &
#TaskTrackerPID=$!
#
#sleep 600 
#
#cpu_thresh=10.0
#while ! check_if_alive.py $TaskTrackerPID $cpu_thresh
#do
#    sleep 300
#done
#
#echo "tasktracker looks idle. Kill it."
#kill -9 $TaskTrackerPID
#
## Don't exit
##sleep 100000000


