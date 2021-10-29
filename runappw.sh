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

if [ "$#" -eq 2 ] && [ $1 == "-python" ]
  then
    ssh facet-srv02 "cd /usr/local/facet/tools/matlabTNG; screen -dmS "$APPNAME" source $PACKAGE_TOP/anaconda/envs/python3.7env/bin/activate; ./runapp.sh $APPNAME"
else
  ssh facet-srv02 "cd /usr/local/facet/tools/matlabTNG; screen -dmS "$APPNAME" ./runapp.sh $APPNAME"
fi

