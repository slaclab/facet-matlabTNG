#!/bin/bash

#ps -eF | grep "Matlab AppLauncher"
MATCMD="/usr/local/lcls/package/matlab/2020a/bin/matlab"
MATDIR="/usr/local/facet/tools/matlabTNG"
xterm -iconic -T "Matlab AppLauncher xterm" -e "cd $MATDIR; $MATCMD -nodesktop -nosplash -r applauncher" &