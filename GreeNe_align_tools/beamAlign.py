#####################################

# SULI Summer Internship Project: GreeNe Alignment

# Samuel English w/ Spencer Gessner (mentor).

# 8 / 19 / 2022

#####################################

# LIBRARY IMPORTS

import math

import time

import epics

import pickle

import threading

import functools

import numpy as np



import matplotlib.pyplot as plt



from os import path

from pydm import Display

from scipy import optimize

from marker import ImageMarker

from pyqtgraph import mkPen, PlotItem

######################################

# EXTERNAL FUNCTION DEFINITIONS



# read '.pickle' files.

def load_object(filename):

    try:

        with open(filename, "rb") as f:

            return pickle.load(f)

    except Exception as ex:

        print("Error during unpickling object (Possibly unsupported):", ex)



# save '.pickle' objects.

def save_object(obj,filename):

    try:

        with open(filename, "wb") as f:

            pickle.dump(obj, f, protocol=pickle.HIGHEST_PROTOCOL)

    except Exception as ex:

        print("Error during pickling object (Possibly unsupported):", ex)



# define gaussian function for scipy fit tool.

def gaussian(x, amplitude, mean, stddev):

    return amplitude * np.exp(-((x - mean) / np.sqrt(2) / stddev)**2)



######################################

# MAIN DISPLAY CLASS



# define ImageViewer class for GUI.

class ImageViewer(Display):

    def __init__(self, parent=None, args=None):

        super(ImageViewer, self).__init__(parent=parent, args=args)



        # BUTTONS

        self.ui.ladderIn_DSOTR.clicked.connect(self.ladderIN)

        self.ui.ladderOut_DSOTR.clicked.connect(self.ladderOUT)



        self.ui.calibrateFrontView.clicked.connect(self.calibrateCam1)

        self.ui.calibrateDSOTR.clicked.connect(self.calibrateCam2)



        self.ui.bm_FrontView.clicked.connect(self.showBM_FV)

        self.ui.bm_DSOTR.clicked.connect(self.showBM_DSOTR)



        self.ui.pos_FV.clicked.connect(self.posFV)

        self.ui.pos_DSOTR.clicked.connect(self.posDSOTR)

        self.ui.posChange.clicked.connect(self.posAdjust)



        self.ui.align.clicked.connect(self.initAlignment)

        self.ui.alignStop.clicked.connect(self.stopAlignment)





        # DEFINITIONS

        self.motorList  = ['MOTR:LI20:MC09:S7:CH1:MOTOR','MOTR:LI20:MC09:S7:CH2:MOTOR','MOTR:LI20:MC09:S7:CH3:MOTOR','MOTR:LI20:MC09:S7:CH4:MOTOR']

        self.imageList  = ['CAMR:LI20:208','CAMR:LI20:105']

        self.imageName  = ['FrontView','DSOTR']

        self.motorScale = [1,1]





        # INITIALIZATION

        self.calibCam    = 0

        self.calib	     = 0

        self.motorIndex  = 0

        self.cameraIndex = 0

        self.nShot	     = 10

        self.nStep       = 7

        self.shot        = 0

        self.step        = 0

        self.getImage1   = 0

        self.getImage2   = 0

        self.imCalc	     = 0



        self.loadSlope   = True



        self.alignInit = 0

        self.altDS     = 0

        self.alignInit = 0

        self.altSwitch = 0

        self.primed    = 0

        self.switch    = 0





        # CALIBRATION ROUTINE

        self.ui.imageView.process_image = functools.partial(self.process_image, 1)

        self.ui.imageView_2.process_image = functools.partial(self.process_image, 2)





        # BEAM MARKER

        self.markers  = list()

        self.blobs    = list()

        self.markers2 = list()

        self.blobs2   = list()



        self.cam_res	  = [epics.caget(f'{self.imageList[0]}:RESOLUTION'),epics.caget(f'{self.imageList[1]}:RESOLUTION')]

        self.markers_lock = threading.Lock()







    ######################################

    # IMPORTANT SELF.FUNCTIONS



    # reference designer file for GUI.

    def ui_filename(self):



        return 'main.ui'



    # set ALL alignment flags to 0.

    def stopAlignment(self):

        self.alignInit = 0

        self.altDS     = 0

        self.alignInit = 0

        self.altSwitch = 0

        self.primed    = 0

        self.switch    = 0

        self.called    = 0



        return # nothing.



    # begin auto-alignment process.

    def initAlignment(self):

        # prime system to take center coordinates.

        # assume beams are in "good-ish" position to begin auto-alignment.



        # INITIALIZE.

        self.foilVert()       # set FV foil vertical.

        self.foilExtract()    # switch to DSOTR.

        self.showBM_FV()      # ensure BM's are showing...

        self.showBM_DSOTR()   # ...



        M              = load_object('slopeMatrix.pickle')     # save slope matrix.

        self.FV        = [[M[0][0],M[0][2]],[M[2][0],M[2][2]]]

        self.DS        = [[M[1][1],M[1][3]],[M[3][1],M[3][3]]]



        self.alignInit = True                                  # set initialized flag.

        self.called    = True







    # set FV foil vertical.

    def foilVert(self):

        print(f"Setting FrontView's foil to 80 rev VERTICAL (M1).")

        epics.caput('XPS:LI20:MC05:M1.VAL', 80)



        return # nothing.







    # extract FV foil.

    def foilExtract(self):

        print(f"Extracting FrontView foil to -150 rev HORIZONTAL (M2).")

        epics.caput('XPS:LI20:MC05:M2.VAL',-150)



        return # nothing.





    # insert FV foil.

    def foilInsert(self):

        print(f"Inserting FrontView foil to -95 rev HORIZONTAL (M2).")

        epics.caput('XPS:LI20:MC05:M2.VAL',-95)



        return # nothing.







    # show the beam marker for FrontView.

    def showBM_FV(self):

        cam_num = 1

        bm_x    = epics.caget(f'{self.imageList[cam_num-1]}:X_BM_CTR')

        bm_y    = epics.caget(f'{self.imageList[cam_num-1]}:Y_BM_CTR')



        bm_x     = bm_x/(self.cam_res[cam_num-1]*0.001); bm_y = -bm_y/(self.cam_res[cam_num-1]*0.001) # convert mm to pixels.

        with self.markers_lock:

            view = self.ui.imageView.getView().getViewBox()



        for m in self.markers:

            if m in view.addedItems:

                view.removeItem(m)



        print(f'FrontView Beam Mark: ({bm_x}, {bm_y})')



        m = ImageMarker((bm_x, bm_y), size=35, pen=mkPen((100, 100, 255), width=5))

        self.markers.append(m)

        view.addItem(m)



        return # nothing.







    # show the beam marker for DSOTR.

    def showBM_DSOTR(self):

        cam_num = 2

        bm_x    = epics.caget(f'{self.imageList[cam_num-1]}:X_BM_CTR')

        print(self.imageList[cam_num-1])

        bm_y    = epics.caget(f'{self.imageList[cam_num-1]}:Y_BM_CTR')



        bm_x      = -bm_x/(self.cam_res[cam_num-1]*0.001); bm_y = -bm_y/(self.cam_res[cam_num-1]*0.001) # convert mm to pixels.

        with self.markers_lock:

            view2 = self.ui.imageView_2.getView().getViewBox()



        for m in self.markers2:

            if m in view2.addedItems:

                view2.removeItem(m)



        print(f'DSOTR Beam Mark: ({bm_x}, {bm_y})')



        m = ImageMarker((bm_x, bm_y), size=35, pen=mkPen((100, 100, 255), width=5))

        self.markers2.append(m)

        view2.addItem(m)



        return # nothing.







    # calculate the positional move needed to align to BM.

    def posAdjust(self):

        bm_FV    = self.posCalc(1)

        bm_DSOTR = self.posCalc(2)



        dX = [bm_FV[0]    - self.fitCoords1[0],

              bm_DSOTR[0] - self.fitCoords2[0],

              bm_FV[1]    - self.fitCoords1[1],

              bm_DSOTR[1] - self.fitCoords2[1]]



        print(dX)

        self.dX = dX



        return # nothing.







    # calculate the position change needed to move from current position to the beam marker (BM).

    def posCalc(self,cam_num):

        bm_x = epics.caget(f'{self.imageList[cam_num-1]}:X_BM_CTR')

        bm_y = epics.caget(f'{self.imageList[cam_num-1]}:Y_BM_CTR')



        if cam_num==1: # bm_FrontView

            bm_x =  bm_x/(self.cam_res[cam_num-1]*0.001); bm_y = -bm_y/(self.cam_res[cam_num-1]*0.001) # convert mm to pixels.



            return (bm_x, bm_y)



        elif cam_num==2: # bm_DSOTR

            bm_x = -bm_x/(self.cam_res[cam_num-1]*0.001); bm_y = -bm_y/(self.cam_res[cam_num-1]*0.001) # convert mm to pixels.



            return (bm_x, bm_y)



        else:

            print(f'No camera number!')

            pass







    # obtain the current position of some camera.

    def getCurrentPos(self, cam_num, new_image):

        if self.called:

            print(f'Caller: cam_num {cam_num}...')

            image_array = new_image

            image_array[image_array < 100] = 0

            x_cum = image_array.sum(axis=0) ; y_cum = image_array.sum(axis=1)



            # now fit gaussians to the x_cum and y_cum data.

            x    = np.arange(0,np.shape(image_array)[1]) ; y = x_cum

            mean = np.mean(x) ; sigma = np.std(x)



            popt, _ = optimize.curve_fit(gaussian, x, y, p0 = [10, mean, sigma], maxfev=10000)

            xGauss0 = popt[1]



            # fit for y-axis distribution.

            x    = np.arange(0,np.shape(image_array)[0]) ; y = y_cum

            mean = np.mean(x) ; sigma = np.std(x)



            popt, _ = optimize.curve_fit(gaussian, x, y, p0 = [10, mean, sigma], maxfev=10000)

            yGauss0 = popt[1]



            if cam_num   == 1:

                self.fitCoords1 = (xGauss0, yGauss0)

                self.getImage1  = 0

            elif cam_num == 2:

                self.fitCoords2 = (xGauss0, yGauss0)

                self.getImage2  = 0

            else:

                print(f'No camera number!')



            print(f'Found CAM {cam_num}\'s gaussian fit center: ({xGauss0}, {yGauss0})')

            self.called = False



            return new_image

        else:

            print(f'Entered without being called!!!!')







    # once calibration has been initialized, call the process routine.

    def process_image(self, cam_num, new_image):

        if self.calib:

           self.process_calibrate(cam_num,new_image)

        # Send the original image data to the image widget



        if self.getImage2:

            if cam_num==2:

                self.getCurrentPos(cam_num, new_image)

                print(f'Calculating DSOTR\'s beam center...')

                # self.imCalc = 1



        if self.getImage1:

            if cam_num==1:

                self.getCurrentPos(cam_num, new_image)

                print(f'Calculating FV\'s beam center...')

                # self.imCalc = 1







        # in our continuous function call, check if auto-align initialized:

        if self.alignInit:

            # check if foil movement to DSOTR is over.

            moveBool = math.isclose(epics.caget('XPS:LI20:MC05:M2.RBV'), -150, rel_tol=1e-5)

            if moveBool:

                print(f"FrontView Foil (M2) initialized to {epics.caget('XPS:LI20:MC05:M2.RBV')}.")

                if self.called:

                    self.getCurrentPos(2, new_image)    # get center of DSOTR.

                if self.altDS:

                    self.posAdjust()  # calculate dX needed to move to BM.

                    self.mtrAlign()   # calculate motor operations needed based on this.



                    self.saveMove2 = (epics.caget(f'{self.motorList[2]}.RBV')+self.mFVAdjust[0,0])

                    self.saveMove3 = (epics.caget(f'{self.motorList[3]}.RBV')+self.mFVAdjust[1,0])



                    epics.caput(self.motorList[2], epics.caget(f'{self.motorList[2]}.RBV')+self.mDSAdjust[0,0]) # CH3

                    epics.caput(self.motorList[3], epics.caget(f'{self.motorList[3]}.RBV')+self.mDSAdjust[1,0]) # CH4



                    self.altDS     = False

                    self.alignInit = False

                    self.altSwitch = True

                    self.called    = True



                    return # nothing.



                else:

                    self.foilInsert()  # switch to FrontView.



                    self.alignInit = False  # set above if statement to false.

                    self.primed    = True   # set the next flag.

                    self.called    = True



                    return # nothing.



        if self.primed: # looking at FrontView.

            moveBool = math.isclose(epics.caget('XPS:LI20:MC05:M2.RBV'), -95, rel_tol=1e-5)

            if moveBool: # once moved into position:

                print(f"FrontView Foil (M2) initialized to {epics.caget('XPS:LI20:MC05:M2.RBV')}.")

                if self.called:

                    self.getCurrentPos(1, new_image)       # calculate FV beam center.



                self.posAdjust()  # calculate dX needed to move to BM.

                self.mtrAlign()   # calculate motor operations needed based on this.





                self.saveMove0 = (epics.caget(f'{self.motorList[0]}.RBV')+self.mFVAdjust[0,0])

                self.saveMove1 = (epics.caget(f'{self.motorList[1]}.RBV')+self.mFVAdjust[1,0])



                epics.caput(self.motorList[0], self.saveMove0) # CH1

                epics.caput(self.motorList[1], self.saveMove1) # CH2



                self.primed = False

                self.switch = True

                self.called = True



                return # nothing.



        if self.switch:

            print(f'Switched to switch!')

            print(f'Compare the RBV of {epics.caget(self.motorList[1])}')

            print(f'to the saved move of {self.saveMove1}')

            moveBool  = math.isclose(epics.caget(f'{self.motorList[1]}.RBV'), self.saveMove1, rel_tol=1e-5)

            moveBool2 = math.isclose(epics.caget(f'{self.motorList[0]}.RBV'), self.saveMove0, rel_tol=1e-5)

            if moveBool and moveBool2: # wait for motors to finish moves.

                if self.called:

                    self.getCurrentPos(1, new_image)       # calculate FV beam center.

                self.foilExtract()     # switch back to DSOTR.



                self.switch    = False    # set flag to False.

                self.altDS     = True     # flag alternate DSOTR calculation.

                self.alignInit = True

                self.called    = True



                return # nothing.



        if self.altSwitch:

            moveBool  = math.isclose(epics.caget(f'{self.motorList[2]}.RBV'), self.saveMove2, rel_tol=1e-5)

            moveBool2 = math.isclose(epics.caget(f'{self.motorList[3]}.RBV'), self.saveMove3, rel_tol=1e-5)

            if moveBool and moveBool2: # wait for motors to finish moves.

                if self.called:

                    self.getCurrentPos(2, new_image)    # get center of DSOTR.

                self.foilInsert()      # switch back to FrontView.



                self.altSwitch    = False    # set flag to False.

                self.primed       = True     # return to FrontView code.

                self.called       = True



                return # nothing.



        return new_image







    def mtrAlign(self):

        # print(np.matrix(self.FV))

        # print('\n')

        # print(np.matrix(self.DS))



        FV2by2 = np.linalg.inv(self.FV)

        DS2by2 = np.linalg.inv(self.DS)



        FVmove = np.matrix([self.dX[0],self.dX[2]]).T

        print(FVmove)

        DSmove = np.matrix([self.dX[1],self.dX[3]]).T

        print(DSmove)



        self.mDSAdjust = np.matmul(DS2by2,DSmove)

        print(f'\n motor adjustments for DS \n {self.mDSAdjust}') # CH3, CH4



        self.mFVAdjust = np.matmul(FV2by2,FVmove)

        print(f'\n motor adjustments for FV \n {self.mFVAdjust}') # CH1, CH2



        return # nothing.







    def posFV(self):

        self.getImage1 = 1



        return # nothing.







    def posDSOTR(self):

        self.getImage2 = 1



        return # nothing.







    # take the DSOTR ladder out.

    def ladderOUT(self):

        print(f"Taking out DSOTR's ladder.")

        epics.caput('OTRS:LI20:3206:MOTR',-500)



        return # nothing.





    # insert the DSOTR ladder.

    def ladderIN(self):

        print(f"Inserting 300 um foil at DSOTR's ladder.")

        epics.caput('OTRS:LI20:3206:MOTR',-48000)



        return # nothing.







    # begin calibration for FrontView (1).

    def calibrateCam1(self):

        self.calibCam=1

        self.calibrateTest(1)



        return # nothing.







    # begin calibration for DSOTR (2).

    def calibrateCam2(self):

        self.calibCam=2

        self.calibrateTest(2)



        return # nothing.







    # initialize self attributes for calibration routine.

    def calibrateTest(self,cam_num):

        print(f"Calibrating camera {cam_num}...")



        camPV        = self.imageList[cam_num-1]

        self.xPixels = epics.caget(f'{camPV}:Image:ArraySize1_RBV')

        self.yPixels = epics.caget(f'{camPV}:Image:ArraySize0_RBV')

        print(self.xPixels,self.yPixels)



        self.motorInitialize = True

        self.initMotor()



        self.initd	    = False

        self.motorMove  = False

        self.imageArray = np.empty(shape=(self.xPixels, self.yPixels, self.nShot,self.nStep), dtype=np.uint16)

        self.calib	    = True

        self.reset	    = True



        return # nothing.







    # initialize the current motor channel + move to first position.

    def initMotor(self):

        self.motorCenter = epics.caget(self.motorList[self.motorIndex]+'.RBV') # FOR ALL 4 CHANNELS, (ch1,ch2,ch3,ch4)

        mRange           = self.motorScale[self.calibCam-1]*0.15 # rev

        mSteps           = 0.05 # rev



        # take the current channel's center.

        startVal  = self.motorCenter - mRange

        endVal    = self.motorCenter + mRange



        # motor rev values. scale by some factor depending on the camera.

        self.vals = np.linspace(startVal,endVal,num=self.nStep,endpoint=True)

        nSteps    = len(self.vals); # number of steps to take.

        print(self.vals)



        self.moveMotor(self.vals[0])

        # self.motorInitialize = 0

        print(f"Moving {self.motorList[self.motorIndex]} to initial position...")



        return # nothing.







    # check if motor is currently moving.

    def checkMotor(self):

        moveBool = math.isclose(epics.caget(self.motorList[self.motorIndex]+'.RBV'), self.target, rel_tol=1e-5)

        if moveBool:

            print(f"Motor initialized to {epics.caget(self.motorList[self.motorIndex]+'.RBV')}.")

            self.motorMove = True

            self.initd     = True



        return # nothing.







    # move motor channel to value.

    def moveMotor(self,value):

        self.motorMove = False

        print(f"moving {self.motorList[self.motorIndex]}")



        epics.caput(self.motorList[self.motorIndex], value)

        self.target    = value

        print(f"We want to move the motor to: {value} rev.")



        return # nothing.







    # data-taking routine, saves '.pickle' files for each motor channel, for each camera.

    def process_calibrate(self,cam_num,new_image):

        if cam_num!=self.calibCam:

            return # nothing.



        if not self.motorMove:

            self.checkMotor()

            return # nothing.



        if self.motorIndex < len(self.motorList):        # iterate over motors.

            if self.initd:                      # once first move is complete, self.initd is true.

                if self.step < self.nStep:	# iterate over motor steps.

                    if self.shot < self.nShot:  # if motor NOT moving AND shot < nShot, take data.

                        self.imageArray[:,:,self.shot,self.step] = new_image

                        self.shot += 1

                        print(self.shot)



                        return # nothing.



                    else:	# if data complete:

                        print(f"Done with shots!")

                        self.shot  = 0

                        self.step += 1



                        if self.step < self.nStep:	# if step < nStep, move motor to next position.

                            self.moveMotor(self.vals[self.step])

                        else:

                            print(f"Resetting motor to central position.")

                            # reset motor channel to the initial center.

                            self.moveMotor(self.motorCenter)



                        return # nothing.



                else:

                    print(f"Reached end of motor scan values. Switching motor channels...")

                    print(f"Size of saved pickle object: {np.shape(self.imageArray)}.")



                    # save images.

                    save_object(self.imageArray,f"{self.imageName[self.calibCam-1]}:{self.motorList[self.motorIndex]}.pickle")

                    save_object(self.vals,f"{self.imageName[self.calibCam-1]}:MOTORVALS:CH{self.motorIndex+1}.pickle")



                    print(f"Resetting image array...")

                    self.imageArray   = np.empty(shape=(self.xPixels, self.yPixels, self.nShot,self.nStep), dtype=np.uint16)

                    self.step         = 0

                    self.motorIndex  += 1

                    # self.motorInitialize = 1

                    #self.initd = 0



                    if self.motorIndex < len(self.motorList):

                        self.initMotor()



                    return # nothing.



        else:

            print(f"Done with ALL MOTOR CHANNELS.")

            self.calib      = 0

            self.motorIndex = 0

            self.initd      = 0



            return # nothing.







# create an instance of the class.

intelclass = ImageViewer


