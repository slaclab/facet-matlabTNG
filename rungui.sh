#!/bin/bash

if [ "$#" -eq 2 ] && [ $1 == "-python" ]
  then
    source $PACKAGE_TOP/anaconda/envs/python3.7env/bin/activate
    APPNAME=$2
else
  APPNAME=$1    
fi
zenity --info --text="Launching Matlab GUI: $APPNAME..." &
/usr/local/lcls/package/matlab/2020a/bin/matlab -nodesktop -nosplash -r "rungui('$APPNAME','$!');"

