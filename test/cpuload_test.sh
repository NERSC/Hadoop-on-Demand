#!/bin/sh
set -x

cpu_thresh=10.0

while ! python ../check_if_alive.py $1 $cpu_thresh
do
    echo "alive"
    sleep 5
done

echo "dead"
