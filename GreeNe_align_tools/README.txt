README.TXT
##################################################
This folder contains all relevant files from 
Sam English & Spencer Gessner's exploration 
of automating the GreeNe laser alignment process.
##################################################

beamAlign.py      ==   Main interface, launch using PyDM to display GUI and interact with calibration buttons.

createMatrix.py   ==   Save slope matrix given channel data. This channel data is produced by the 'calibrate FV/DSOTR' in 'beamAlign.py'.
		       This is sensitive to the order in which it is saved. It also expects the channel data to be stored in a folder called 'calibrationData/'.

expert_motor.ui   ==   Simple motor control panel which is accessible through the main GUI

inline_motor.ui   ==   The motor controls one sees when first launching the GUI.

main.ui           ==   Constructs the GUI design which 'beamAlign.py' sources.

marker.py         ==   (Matt Gibbs! Thank you!) Code taken to display markers where the beam marks are located.

slopeMatrix.picke ==   Matrix full of motor/beam-center relations. Must be .pickle object. Must be saved in specific order of channels against camera coordinates.
		       see 'createMatrix.py' for an example. Or talk to Spencer G. Or Sam E.