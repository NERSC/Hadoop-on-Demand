#!/bin/sh

#$ -o /dev/null
#$ -e /dev/null
#$ -pe pe_8 8

export HADOOP_HOME=/global/common/carver/tig/hadoop/hadoop-0.20.2-cdh3u2/
export JAVA_HOME=/global/common/carver/tig/java/jdk1.6.0_13/
export HADOOP_CONF_DIR="$HOME/.hadoop-genepool"
export HADOOP_LOG_DIR=$SCRATCH/logs/
export HADOOP_PID_DIR=$SCRATCH/logs/pids/
#export HADOOP_HEAPSIZE=2000
export PATH=$PATH:$HADOOP_HOME/bin/

hadoop-daemon.sh start tasktracker
# Don't exit
#sleep 100000000

# poll the usage of the node and exit when nothing happens.
/global/projectb/projectdirs/microbial/omics/kmavromm/SourceCode/Utilities/monitorCPU.pl $HADOOP_LOG_DIR/monitorCPU.log

