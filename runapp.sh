#!/bin/bash
source /usr/local/facet/epics/setup/epicsenv-7.0.3.1-1.0.bash
if [ "$#" -eq 2 ] && [ $1 == "-python" ]
  then
    source $PACKAGE_TOP/anaconda/envs/python3.7env/bin/activate
    APPNAME=$2
else
  APPNAME=$1    
fi
/usr/local/lcls/package/matlab/2020a/bin/matlab -nodesktop -nosplash -r "runapp('$APPNAME');"
