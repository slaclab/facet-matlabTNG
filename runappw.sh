#!/bin/bash

if [ "$#" -eq 2 ] && [ $1 == "-python" ]
  then
    source $PACKAGE_TOP/anaconda/envs/python3.7env/bin/activate
    APPNAME=$2
else
  APPNAME=$1    
fi

if [ "`ssh facet-srv02 screen -list | grep -w "$APPNAME" | wc -l`" != "0" ]
  then
    echo "$APPNAME already running, restarting..."
    `/usr/local/facet/tools/matlabTNG/killappw.sh $APPNAME` 
fi
ssh facet-srv02 "cd /usr/local/facet/tools/matlabTNG; screen -dmS "$1" ./runapp.sh $APPNAME"

