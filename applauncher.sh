#!/bin/bash

#ps -eF | grep "Matlab AppLauncher"
#/usr/local/lcls/package/matlab/2020a/bin/matlab -nodesktop -nosplash -r "tcpclinet=applauncher($PORTNUM);"
xterm -iconic -T "Matlab AppLauncher xterm" -e bash -ilc "matlab -nodesktop -nosplash -r applauncher" &