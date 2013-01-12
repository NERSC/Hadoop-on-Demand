Hadoop-on-Demand
================

Scripts for running Hadoop on demand on NERSC systems.



Test on Genepool

sulsj@genepool04 ~$ qlogin -l ram.c=8G
sulsj@sgi01a08 ~$ module load hadoop
sulsj@sgi01a08 ~$ startup_genepool
starting jobtracker, logging to /global/scratch/sd/sulsj/logs//hadoop-sulsj-jobtracker-genepool04.out
sulsj@sgi01a08 ~$ qsub -t 1-2 /global/common/carver/tig/hadoop/hadoop-0.20.2-cdh3u2/bin/genepool.q
Your job-array 3413650.1-2:1 ("genepool.q") has been submitted
 
sulsj@sgi01a08 /project/projectdirs/genomes/sulsj/test/2012.08.06-hadoop-on-demand/test-on-genepool$ hadoop jar /global/common/carver/tig/hadoop/hadoop-0.20.2-cdh3u2/hadoop-examples-0.20.2-cdh3u2.jar wordcount wordcount-in wordcount-out