#!/bin/sh
# script for execution of deployed FACET-II applications
# run_F2app.sh <appname>
# Sets up the MATLAB Runtime environment and executes chosen app
#
MCRROOT="/home/fphysics/whitegr/mcr/v98"
APPDIR="/home/fphysics/whitegr/facet-sw/matlab"
APPNAME="$1"
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:.:${MCRROOT}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/opengl/lib/glnxa64;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lcls/epics/extensions/labca/R3.7.2/lib/rhel6-x86_64/
export LD_LIBRARY_PATH;
cd ${APPDIR}/${APPNAME}
eval "./${APPNAME}"
