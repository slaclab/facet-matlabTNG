#!/bin/bash

# Assumes launched from Matlab GUI edm panel

# Get current workspace
WSNO="`wmctrl -d | grep "*"  | sed 's/\([0-9]*\).*/\1/'`"

# find Matlab GUI edm panel on this workspace & get geometry info
S1='$2=='
S2=' { print $2,$3,$4,$5,$6 }'
WSINFO=`wmctrl -lG | grep "FACET Matlab GUIs" | awk "$S1${WSNO}$S2" | awk 'NR==1 { print }'` # [wsno,xpos,ypos,wid,ht]

# Send app name and launch location to server
/usr/local/facet/tools/matlabTNG/applauncher_client $1 "$WSINFO"