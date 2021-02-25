#!/bin/bash
ssh facet-srv02 "cd ~/whitegr/facet-sw/matlab; screen -dmS "$1" ./runapp.sh $1"

