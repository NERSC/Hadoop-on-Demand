#!/bin/sh

#$ -o /dev/null
#$ -e /dev/null
#$ -pe pe_8 8

export HADOOP_HOME=/global/common/carver/tig/hadoop/hadoop-0.20.2-cdh3u2/
export JAVA_HOME=/global/common/carver/tig/java/jdk1.6.0_13/
export HADOOP_CONF_DIR="$HOME/.hadoop-genepool"
export HADOOP_LOG_DIR=$SCRATCH/logs/
export HADOOP_PID_DIR=$SCRATCH/logs/pids/

export PATH=$PATH:$HADOOP_HOME/bin/

sleep 600 # just for making a room

hadoop-daemon.sh start tasktracker &
TaskTrackerPID=$!

cpu_thresh=10.0
while ! python ./check_if_alive.py $TaskTrackerPID $cpu_thresh
do
    sleep 60
done

echo "tasktracker looks dead. Kill it."
kill -9 $TaskTrackerPID

# Don't exit
#sleep 100000000

