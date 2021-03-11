#!/bin/bash
ssh facet-srv02 "cd ~/usr/local/facet/tools/matlabTNG; screen -dmS "$1" ./runapp.sh $1"

