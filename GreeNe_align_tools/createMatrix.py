#################################
# IMPORTS
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import image
from matplotlib import patches
from PIL import Image

from scipy import optimize
from scipy import stats

import os
from os.path import dirname, join as pjoin
import scipy.io as sio
import pickle
from sklearn.metrics import mean_squared_error
#
#################################
# FUNCTION DEFINITIONS

# save '.pickle' objects.
def save_object(obj,filename):
    try:
        with open(filename, "wb") as f:
            pickle.dump(obj, f, protocol=pickle.HIGHEST_PROTOCOL)
    except Exception as ex:
        print("Error during pickling object (Possibly unsupported):", ex)



# load .pickle objects.
def load_object(filename):
    try:
        with open(filename, "rb") as f:
            return pickle.load(f)
    except Exception as ex:
        print("Error during unpickling object (Possibly unsupported):", ex)


# define gassian for beam center fit.
def gaussian(x, amplitude, mean, stddev):
    return amplitude * np.exp(-((x - mean) / np.sqrt(2) / stddev)**2)



# read image contents and return list of beam center coordinates.
def imgReader(img_contents):

    coordinateList = np.empty((np.shape(img_contents)[3],np.shape(img_contents)[2],2))

    # extract image data.
    for motorStep in range(np.shape(img_contents)[3]):
        for snapNum in range(np.shape(img_contents)[2]):
            image_array = img_contents[:,:,snapNum,motorStep]
            image_array[image_array < 100] = 0
            x_cum = image_array.sum(axis=0) ; y_cum = image_array.sum(axis=1)

            # now fit gaussians to the x_cum and y_cum data.
            x = np.arange(0,np.shape(img_contents)[1]) ; y = x_cum
            mean = np.mean(x) ; sigma = np.std(x)

            popt, _ = optimize.curve_fit(gaussian, x, y, p0 = [1, mean, sigma], maxfev=5000)
            xGauss0 = popt[1]

            x = np.arange(0,np.shape(img_contents)[0]) ; y = y_cum
            mean = np.mean(x) ; sigma = np.std(x)

            popt, _ = optimize.curve_fit(gaussian, x, y, p0 = [1, mean, sigma], maxfev=5000)
            yGauss0 = popt[1]

            coordinateList[motorStep,snapNum] = (xGauss0,yGauss0)

    return coordinateList



# obytain the mirror/beam-center relations and plot them.
def fastFit(motorValCH, centerCH, img_contents, channel):
    mCH = []
    for i in range(np.shape(centerCH)[1]):
        mCH.append(motorValCH)
    print(np.shape(mCH))


    mCHFit      = np.reshape(mCH, (np.shape(mCH)[0]*np.shape(mCH)[1]))

    centerCHFit = np.reshape(np.transpose(centerCH)[0], (np.shape(mCH)[0]*np.shape(mCH)[1]))
    resx = stats.linregress(mCHFit.astype(np.float64), centerCHFit.astype(np.float64))
    print('slope of CH-x: ', resx.slope)

    rmsx = mean_squared_error(centerCHFit, resx.intercept + resx.slope*mCHFit)
    print('CH-x rms: ', rmsx)

    plt.plot(mCH[0], resx.intercept + resx.slope*mCH[0], 'black', label='fitted line',alpha=0.875)

    plt.scatter(mCHFit, centerCHFit, label='gaussian fit', color='red',s=15,marker='x')
    plt.xlabel(f'{channel} movement');plt.ylabel('x direction response')
    plt.grid(alpha=0.5)
    # plt.ylim(0,np.shape(img_contents)[1])
    plt.legend()
    plt.show()

    centerCHFit = np.reshape(np.transpose(centerCH)[1], (np.shape(mCH)[0]*np.shape(mCH)[1]))
    resy = stats.linregress(mCHFit.astype(np.float64), centerCHFit.astype(np.float64))
    print('slope of CH-y: ', resy.slope)

    rmsy = mean_squared_error(centerCHFit, resy.intercept + resy.slope*mCHFit)
    print('CH-y rms: ', rmsy)

    plt.plot(mCH[0], resy.intercept + resy.slope*mCH[0], 'black', label='fitted line',alpha=0.875)

    plt.scatter(mCHFit, centerCHFit, label='gaussian fit', color='red',s=15,marker='x')
    plt.xlabel(f'{channel} movement');plt.ylabel('y direction response')
    plt.grid(alpha=0.5)
    # plt.ylim(0,np.shape(img_contents)[0])
    plt.legend()
    plt.show()

    return resx.slope, resy.slope



#################################
# ANALYSIS

# store paths for each .pickle object.
figList = ['calibrationData/'+entry for entry in os.listdir('calibrationData/')]
# print(figList)



# read in pickle objects.
# NOTE: the order of these is subject to how the .pickle objects are stored in the calibrationData/ directory!
motorValDSOTRCH1 = load_object(figList[5])
motorValDSOTRCH2 = load_object(figList[8])
motorValDSOTRCH3 = load_object(figList[7])
motorValDSOTRCH4 = load_object(figList[12])

imagesDSOTRCH1   = load_object(figList[13])
imagesDSOTRCH2   = load_object(figList[11])
imagesDSOTRCH3   = load_object(figList[10])
imagesDSOTRCH4   = load_object(figList[14])

motorValFrontViewCH1 = load_object(figList[9])
motorValFrontViewCH2 = load_object(figList[4])
motorValFrontViewCH3 = load_object(figList[15])
motorValFrontViewCH4 = load_object(figList[6])

imagesFrontViewCH1   = load_object(figList[0])
imagesFrontViewCH2   = load_object(figList[1])
imagesFrontViewCH3   = load_object(figList[2])
imagesFrontViewCH4   = load_object(figList[3])



# now calculate beam centers.
centerDSOTRCH1 = imgReader(imagesDSOTRCH1)
centerDSOTRCH2 = imgReader(imagesDSOTRCH2)
centerDSOTRCH3 = imgReader(imagesDSOTRCH3)
centerDSOTRCH4 = imgReader(imagesDSOTRCH4)

centerFrontViewCH1 = imgReader(imagesFrontViewCH1)
centerFrontViewCH2 = imgReader(imagesFrontViewCH2)
centerFrontViewCH3 = imgReader(imagesFrontViewCH3)
centerFrontViewCH4 = imgReader(imagesFrontViewCH4)



# save the mirror-center relations.
resxDSOTRCH1, resyDSOTRCH1 = fastFit(motorValDSOTRCH1, centerDSOTRCH1, imagesDSOTRCH1, 'CH1')
resxDSOTRCH2, resyDSOTRCH2 = fastFit(motorValDSOTRCH2, centerDSOTRCH2, imagesDSOTRCH2, 'CH2')
resxDSOTRCH3, resyDSOTRCH3 = fastFit(motorValDSOTRCH3, centerDSOTRCH3, imagesDSOTRCH3, 'CH3')
resxDSOTRCH4, resyDSOTRCH4 = fastFit(motorValDSOTRCH4, centerDSOTRCH4, imagesDSOTRCH4, 'CH4')

resxFrontViewCH1, resyFrontViewCH1 = fastFit(motorValFrontViewCH1, centerFrontViewCH1, imagesFrontViewCH1, 'CH1')
resxFrontViewCH2, resyFrontViewCH2 = fastFit(motorValFrontViewCH2, centerFrontViewCH2, imagesFrontViewCH2, 'CH2')
resxFrontViewCH3, resyFrontViewCH3 = fastFit(motorValFrontViewCH3, centerFrontViewCH3, imagesFrontViewCH3, 'CH3')
resxFrontViewCH4, resyFrontViewCH4 = fastFit(motorValFrontViewCH4, centerFrontViewCH4, imagesFrontViewCH4, 'CH4')



# save the slope matrix for later use.
slopeMatrix = [[resxFrontViewCH1, resxFrontViewCH3, resxFrontViewCH2, resxFrontViewCH4],
               [resxDSOTRCH1,     resxDSOTRCH3,     resxDSOTRCH2,     resxDSOTRCH4],
               [resyFrontViewCH1, resyFrontViewCH3, resyFrontViewCH2, resyFrontViewCH4],
               [resyDSOTRCH1,     resyDSOTRCH3,     resyDSOTRCH2,     resyDSOTRCH4]]

save_object(slopeMatrix,'slopeMatrix.pickle')
exit()

