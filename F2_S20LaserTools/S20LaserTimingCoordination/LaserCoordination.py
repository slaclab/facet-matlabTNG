from pydm import Display, PyDMChannel
from qtpy import QtCore, QtWidgets, QtGui
from os import path
import epics
import pdb

class MyDisplay(Display):
    def __init__(self, parent=None, args=None, macros=None):
        super(MyDisplay, self).__init__(parent=parent, args=args, macros=macros)
        self.timesteps = (("1ns",1),("10ns",10),("100ns",100))
        self.configure_controls()
        self.stepsize = 1

    def ui_filename(self):
        return 'LaserCoordinationUI.ui'

    def ui_filepath(self):
        return path.join(path.dirname(path.realpath(__file__)), self.ui_filename())

    def configure_controls(self):
        self.ui.loadOffsetsBtn.clicked.connect(self.getOffsets)
        self.ui.trackingEnabledCtl.toggled.connect(self.trackingEnableToggled)
        self.monitor = PyDMChannel(self.ui.regenTrigger.channel, value_slot=self.updateTimes)
        self.monitor.connect()
        for entry in self.timesteps:
            self.ui.stepSizeSelect.addItem(entry[0])
        self.ui.stepSizeSelect.currentIndexChanged.connect(self.updateTimeStepSize)
        self.ui.stepSizeSelect.setEnabled(True)
        # pdb.set_trace()
        # self.ui.incPushButton.pressed.connect(self.incrementTargetTime)
        # self.ui.decPushButton.pressed.connect(self.decrementTargetTime)

        # self.spinboxch = PyDMChannel(self.ui.targTimeSpinbox.channel, value_slot=self.updateTimes)
        # self.spinboxch.connect()
        # self.ui.targTimeSpinbox.setEnabled(True)

    def updateTimes(self,time):
        """ Get the current trigger time and set the follow triggers per the offset values."""
        if self.ui.trackingEnabledCtl.isChecked():
            ctrig = float(self.ui.regenTrigger.text())
            self.ui.trig1tdes.setText(str(ctrig+float(self.ui.trig1offsetEdit.text())))
            self.ui.trig2tdes.setText(str(ctrig+float(self.ui.trig2offsetEdit.text())))
            self.ui.trig3tdes.setText(str(ctrig+float(self.ui.trig3offsetEdit.text())))
            self.ui.trig4tdes.setText(str(ctrig+float(self.ui.trig4offsetEdit.text())))
            self.ui.trig1tdes.send_value()
            self.ui.trig2tdes.send_value()
            self.ui.trig3tdes.send_value()
            self.ui.trig4tdes.send_value()

    # def incrementTargetTime(self):
    #     currentttime = self.ui.targetTimeField.value
    #     self.ui.targetTimeField.value = currentttime+self.stepsize
    #     self.ui.targetTimeField.send_value()
        
    # def decrementTargetTime(self):
    #     currentttime = self.ui.targetTimeField.value
    #     self.ui.targetTimeField.value = currentttime-self.stepsize
    #     self.ui.targetTimeField.send_value()

    def getOffsets(self):
        """ Get the values of the current trigger values, subtract the difference and put those in the offset fields. """
        reftrig = float(self.ui.regenTrigger.text())
        trig1value = self.ui.trig1tdes.value
        self.ui.trig1offsetEdit.setText(str(trig1value-reftrig))
        trig2value = self.ui.trig2tdes.value
        self.ui.trig2offsetEdit.setText(str(trig2value-reftrig))
        trig3value = self.ui.trig3tdes.value
        self.ui.trig3offsetEdit.setText(str(trig3value-reftrig))
        trig4value = self.ui.trig4tdes.value
        self.ui.trig4offsetEdit.setText(str(trig4value-reftrig))

    def updateTimeStepSize(self):
        currentindex = self.ui.stepSizeSelect.currentIndex()
        # self.ui.targTimeSpinbox.setSingleStep(self.timesteps[currentindex][1])
        self.stepsize =  self.timesteps[currentindex][1]
        self.ui.incPushButton.pressValue = self.stepsize
        self.ui.decPushButton.pressValue = -1.0*self.stepsize

    def trackingEnableToggled(self,state):
        if state:
            self.ui.loadOffsetsBtn.setEnabled(False)
            self.ui.trig1tdes.setEnabled(False)
            self.ui.trig2tdes.setEnabled(False)
            self.ui.trig3tdes.setEnabled(False)
            self.ui.trig4tdes.setEnabled(False)
        else:
            self.ui.loadOffsetsBtn.setEnabled(True)
            self.ui.trig1tdes.setEnabled(True)
            self.ui.trig2tdes.setEnabled(True)
            self.ui.trig3tdes.setEnabled(True)
            self.ui.trig4tdes.setEnabled(True)
