#!/bin/sh
# script for execution of FACET-II apps in FACET-II simulation environment
# run_F2sim.sh <appname>
# e.g. run_F2sim.sh F2sim to run FACET-II simulation tool
# Sets up the MATLAB Runtime environment and executes chosen simulation environment
# Requires EPICS IOC(s) to be already running in case of F2sim app
#
MCRROOT="/usr/local/MATLAB/MCR/v98"
APPNAME="$1"
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:.:${MCRROOT}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/epics/extensions/labca_3_7_2/lib/linux-x86_64
export LD_LIBRARY_PATH;
eval "${APPNAME}/${APPNAME}"
