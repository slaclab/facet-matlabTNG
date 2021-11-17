#!/bin/bash
#source /usr/local/lcls/epics/setup/epicsenv-7.0.2-1.0.bash
#source /usr/local/lcls/oracle/oracleSetup-R11.2.0.4.bash
#export MATLAB_VER=2019_a
#source /usr/local/lcls/tools/matlab/setup/matlabSetup64.bash
cd /usr/local/facet/tools/matlabTNG/F2_LaserMultiProfmon
run_matlab.bash -m 2020a  -r "runF2LaserMultiProfmon('$1');"

