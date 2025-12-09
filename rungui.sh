#!/bin/bash
source /usr/local/facet/epics/setup/epicsenv-7.0.3.1-1.0.bash

if [ "$#" -eq 2 ] && [ $1 == "-python" ]
  then
    source $PACKAGE_TOP/anaconda/envs/python3.7env/bin/activate
    APPNAME=$2
else
  APPNAME=$1    
fi
zenity --info --text="Launching Matlab GUI: $APPNAME..." &
unset QT_XCB_GL_INTEGRATION

RH_VER=`cat /etc/redhat-release | awk -F 'release '  '{print $2}' | awk -F '.' '{print $1}'`

if [ $RH_VER == '7' ]
   then
      /usr/local/lcls/package/matlab/2020a/bin/matlab -nodesktop -nosplash -r "rungui('$APPNAME','$!');"
elif [ $RH_VER == '9' ]
   then
      /usr/local/lcls/package/matlab/2023a/bin/matlab -nodesktop -nosplash -r "rungui('$APPNAME','$!');"
fi
