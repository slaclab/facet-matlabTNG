function DAQPVs = camera_DAQ_PVs(camPVs)

daq_pvs = {
    ':Acquisition';
    ':Acquire';
    ':ArrayCounter_RBV';
    ':ArrayCounter';
    ':AsynIO.CNCT';
    ':DetectorState_RBV';
    ':NumImagesCounter_RBV';
    ':Image:ArrayData'
    ':ImageMode_RBV';
    ':ImageMode';
    ':NumImages_RBV';
    ':NumImages';
    ':ROI:EnableCallbacks';
    ':TSS_SETEC';
    ':TIFF:AutoIncrement';
    ':TIFF:AutoSave';
    ':TIFF:EnableCallbacks';
    ':TIFF:Capture';
    ':TIFF:FileTemplate';
    ':TIFF:FileName';
    ':TIFF:FileNumber_RBV';
    ':TIFF:FileNumber';
    ':TIFF:FilePathExists_RBV';
    ':TIFF:FilePath';
    ':TIFF:FileWriteMode';
    ':TIFF:NumCaptured_RBV';
    ':TIFF:NumCapture';
    ':TIFF:SetPort';
    ':HDF5:AutoIncrement';
    ':HDF5:AutoSave';
    ':HDF5:EnableCallbacks';
    ':HDF5:Capture';
    ':HDF5:FileTemplate';
    ':HDF5:FileName';
    ':HDF5:FileName_RBV';
    ':HDF5:FileNumber_RBV';
    ':HDF5:FileNumber';
    ':HDF5:FilePathExists_RBV';
    ':HDF5:FilePath';
    ':HDF5:FileWriteMode';
    ':HDF5:NumCaptured_RBV';
    ':HDF5:NumCapture';
    ':HDF5:ExtraDimSizeN';
    ':HDF5:NumExtraDims';
    ':HDF5:ExtraDimSizeX';
    ':HDF5:ExtraDimSizeY';
    ':HDF5:WriteFile';
    ':HDF5:WriteFile_RBV';
    ':HDF5:WriteStatus';
    ':DataType';
    ':DAQ_InUse';
    };

DAQPVs = struct();
for i = 1:numel(daq_pvs)
    pv_str = strrep(daq_pvs{i}(2:end),':','_');
    pv_str = strrep(pv_str,'.','_');
    DAQPVs.(pv_str) = strcat(camPVs, daq_pvs{i});
end

