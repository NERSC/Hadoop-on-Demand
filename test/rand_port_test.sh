#!/bin/bash

port=$(( 100+( $(od -An -N2 -i /dev/random) )%(40000-1024+1) ))
while :
do
    (echo >/dev/tcp/localhost/$port) &>/dev/null &&  port=$(( 100+( $(od -An -N2 -i /dev/random) )%(40000-1000+1) )) || break
done

echo $port
