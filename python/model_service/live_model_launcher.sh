#/bin/bash
#This script launches a python PV server and a matlab engine. It populates the PV with data from Lucretia Live model. This is based on the lcls-live-model, and should make integraration with LCLS apps easier.

source $PACKAGE_TOP/anaconda/envs/python3.7env/bin/activate
python lucretia_live_model.py
