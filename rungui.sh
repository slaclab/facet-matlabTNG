#!/bin/bash
zenity --info --text="Launching Matlab GUI: $1..." &
/usr/local/lcls/package/matlab/2020a/bin/matlab -nodesktop -nosplash -r "rungui('$1','$!');"

