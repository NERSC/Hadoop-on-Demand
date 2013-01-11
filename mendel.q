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
export HADOOP_PID_DIR=$SCRATCH/logs/pids/
export HADOOP_HEAPSIZE=2000
export PATH=$PATH:$HADOOP_HOME/bin/

hadoop-daemon.sh start tasktracker &
TaskTrackerPID=$!

sleep 600 

cpu_thresh=10.0
while ! python /project/projectdirs/genomes/sulsj/test/2012.08.06-hadoop-on-demand/git-cloned/Hadoop-on-Demand/check_if_alive.py $TaskTrackerPID $cpu_thresh
do
    sleep 300
done

echo "tasktracker looks idle. Kill it."
kill -9 $TaskTrackerPID

# Don't exit
#sleep 100000000

