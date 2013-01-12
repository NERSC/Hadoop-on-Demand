#!/usr/bin/env bash

#$ -N HadoopTT

export HADOOP_HOME=/global/homes/g/gbp/hadoop
export JAVA_HOME=/global/homes/g/gbp/java
export HADOOP_CONF_DIR="$HOME/.hadoop-phoebe"
export HADOOP_LOG_DIR=$SCRATCH/logsM/

#echo HH: $HADOOP_HOME
#echo JH: $JAVA_HOME
#echo HC: $HADOOP_CONF_DIR
#echo HL: $HADOOP_LOG_DIR
#echo 
#
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
  mkdir -p $LOCAL/tmp
  rsync -avz $HADOOP_HOME/{bin,conf,*jar,ivy,lib,sbin,webapps} $LOCAL/hadoop
  rsync -avz $HADOOP_CONF_DIR/* $LOCAL/hadoop/conf/
  rsync -avz $JAVA_HOME/{bin,jre,lib} $LOCAL/java

  export HADOOP_HOME=$LOCAL/hadoop
  export HADOOP_CONF_DIR=$HADOOP_HOME/conf
  export HADOOP_LOG_DIR=$LOCAL/logs/
  export JAVA_HOME=$LOCAL/java
  [ -e $HADOOP_LOG_DIR ] || mkdir $HADOOP_LOG_DIR

#  echo "In local if, after rsync and new export commands"
#  echo HH: $HADOOP_HOME
#  echo JH: $JAVA_HOME
#  echo HC: $HADOOP_CONF_DIR
#  echo HL: $HADOOP_LOG_DIR
#  echo 

fi

export PATH=$PATH:$HADOOP_HOME/bin/
export HADOOP_PID_DIR=$HADOOP_LOG_DIR/pids/

#echo "After local if"
#echo HH: $HADOOP_HOME
#echo JH: $JAVA_HOME
#echo HC: $HADOOP_CONF_DIR
#echo HL: $HADOOP_LOG_DIR
#echo PP: $PATH
#echo HP: $HADOOP_PID_DIR
#echo 
#
while [ true ]  ; do
  if [ ! -d $HADOOP_HOME ]; then
    rsync -avz $HADOOP_HOME/{bin,conf,*jar,ivy,lib,sbin,webapps} $LOCAL/hadoop
	rsync -avz $HADOOP_CONF_DIR/* $LOCAL/hadoop/conf/
  fi
  if [ ! -d $JAVA_HOME/bin ]; then
    rsync -avz $JAVA_HOME/{bin,jre,lib} $LOCAL/java
  fi
  [ -e $HADOOP_LOG_DIR ] || mkdir $HADOOP_LOG_DIR

#  echo "In while"
#  echo HH: $HADOOP_HOME
#  echo JH: $JAVA_HOME
#  echo HC: $HADOOP_CONF_DIR
#  echo HL: $HADOOP_LOG_DIR
#  echo PP: $PATH
#  echo HP: $HADOOP_PID_DIR
#  echo 
#  
#  echo Which hadoop: `which hadoop`
#  echo Calling hadoop now via \'hadoop --config \$HADOOP_CONF_DIR tasktracker\'
#  echo 

#  hadoop --config $HADOOP_CONF_DIR tasktracker
  hadoop tasktracker

  sleep 60
done

