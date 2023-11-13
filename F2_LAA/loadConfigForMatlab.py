import os
import sys
import numpy as np

# Hardcode paths like a noob
sys.path.append(os.path.realpath("/usr/local/facet/tools/pydm/display/user-facet/"))

from config.loadConfig import loadS20LaserConfig, loadS20AutoAlignerConfig

def loadConfig():
    S20Config = loadS20LaserConfig()
    AAConfig = loadS20AutoAlignerConfig()
    # Make the structure what matlab wants
    for name, section in AAConfig.items():
        cameraConfig = {}
        for name in section['cameras']:
            cameraConfig[name] = S20Config[name]
        section['cameras'] = cameraConfig
    del AAConfig["B0B1IR"]
    return AAConfig

def loadIRConfig():
    S20Config = loadS20LaserConfig()
    AAConfig = loadS20AutoAlignerConfig()
    # Make the structure what matlab wants
    section = AAConfig["B0B1IR"]
    cameraConfig = {}
    for name in section['cameras']:
        cameraConfig[name] = S20Config[name]
    section['cameras'] = cameraConfig
    config = {"B0B1IR": section}
    return config
    
