#!/bin/bash

#source /usr/local/lcls/epics/setup/epicsenv-7.0.2-1.0.bash
#source /usr/local/lcls/tools/oracle/oracleSetup-R11.2.0.4.bash
#export MATLAB_VER=2019a
#source /usr/local/lcls/tools/matlab/setup/matlabSetup64.bash
run_matlab.bash -m 2020a -r "addpath('/home/fphysics/cemma/S20Laser/S20LaserMultiProfmonGUI'); run('/home/fphysics/cemma/S20Laser/S20LaserMultiProfmonGUI/s20LaserRoomMultiProfmon')"