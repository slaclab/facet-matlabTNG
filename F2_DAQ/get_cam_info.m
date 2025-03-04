function cam_info = get_cam_info(camPV)

info_pvs = {':Model_RBV';
            ':DataType';
            ':MaxSizeX_RBV';
            ':MaxSizeY_RBV';
            ':MinX_RBV';
            ':MinY_RBV';
            ':SizeX_RBV';
            ':SizeY_RBV';
            ':BinX_RBV';
            ':BinY_RBV';
            ':ArraySizeX_RBV';
            ':ArraySizeY_RBV';
            ':ROI:MinX_RBV';
            ':ROI:SizeX_RBV';
            ':ROI:BinX_RBV';
            ':ROI:ArraySizeX_RBV';
            ':ROI:MinY_RBV';
            ':ROI:SizeY_RBV';
            ':ROI:BinY_RBV';
            ':ROI:ArraySizeY_RBV';
            ':ROI:ArraySize0_RBV';
            ':ROI:ArraySize1_RBV';
            ':AcquireTime_RBV';
            ':Gain_RBV'};
        
cam_info = struct();
cam_info.PV = camPV;
for i = 1:numel(info_pvs)
    try
        cam_info.(strrep(info_pvs{i}(2:end),':','_')) = lcaGetSmart([camPV info_pvs{i}]);
    catch
        disp('Could not get camera PV')
    end
end

if ~contains(camPV,'SPEC')
    info_pvs_no_spec = {':X_ORIENT';
            ':Y_ORIENT';
            ':IS_ROTATED';
            ':RESOLUTION'};
    for i = 1:numel(info_pvs_no_spec)
        try
            cam_info.(strrep(info_pvs_no_spec{i}(2:end),':','_')) = lcaGetSmart([camPV info_pvs_no_spec{i}]);
        catch
            disp('Could not get camera PV')
        end
    end
end


