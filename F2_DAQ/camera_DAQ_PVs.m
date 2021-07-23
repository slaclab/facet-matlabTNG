function DAQPVs = camera_DAQ_PVs(camPVs)

daq_pvs = {
    ':Acquisition';
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
    ':DataType';
    };

DAQPVs = struct();
for i = 1:numel(daq_pvs)
    pv_str = strrep(daq_pvs{i}(2:end),':','_');
    pv_str = strrep(pv_str,'.','_');
    DAQPVs.(pv_str) = strcat(camPVs, daq_pvs{i});
end

