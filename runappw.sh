#!/bin/bash
if [ "`ssh facet-srv02 screen -list | grep -w "$1" | wc -l`" != "0" ]
  then
    echo "$1 already running, restarting..."
    `/usr/local/facet/tools/matlabTNG/killappw.sh $1` 
fi
ssh facet-srv02 "cd /usr/local/facet/tools/matlabTNG; screen -dmS "$1" ./runapp.sh $1"

