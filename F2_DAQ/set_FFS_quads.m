function [delta] = set_FFS_quads(obj, quadPV, BDESs)
    %Sets the spectrometer quads to whatever BDES values you want
    delta = set_Quads_BDES(obj, quadPV, BDESs);
    obj.daqhandle.dispMessage(sprintf('Quads set to within tolerance'));
end


function [delta] = set_Quads_BDES(obj, quadPVs, values)

%         control_magnetSet({quadPVs.control_PV0,quadPVs.control_PV1,quadPVs.control_PV2,quadPVs.control_PV3,quadPVs.control_PV4,quadPVs.control_PV5,quadPVs.control_PV_QS0,quadPVs.control_PV_QS1,quadPVs.control_PV_QS2},values,'action','TRIM');
        obj.daqhandle.dispMessage(sprintf('Setting %s %s %s %s %s %s %s %s %s to %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f', quadPVs.control_PV_FF0,quadPVs.control_PV_FF1,quadPVs.control_PV_FF2, quadPVs.control_PV_FF3,quadPVs.control_PV_FF4,quadPVs.control_PV_FF5,quadPVs.control_PV_QS0,quadPVs.control_PV_QS1,quadPVs.control_PV_QS2, values(1), values(2), values(3), values(4), values(5), values(6),values(7), values(8), values(9)));

        current_value = control_magnetGet({quadPVs.readback_PV_FF0,quadPVs.readback_PV_FF1,quadPVs.readback_PV_FF2,...
                                           quadPVs.readback_PV_FF3,quadPVs.readback_PV_FF4,quadPVs.readback_PV_FF5,...
                                           quadPVs.readback_PV_QS0,quadPVs.readback_PV_QS1,quadPVs.readback_PV_QS2});
current_value = values; %added for test        
        while max(abs(current_value - values)) > obj.tolerance
            current_value = control_magnetGet({quadPVs.readback_PV_FF0,quadPVs.readback_PV_FF1,quadPVs.readback_PV_FF2,...
                                              quadPVs.readback_PV_FF3,quadPVs.readback_PV_FF4,quadPVs.readback_PV_FF5,...
                                              quadPVs.readback_PV_QS0,quadPVs.readback_PV_QS1,quadPVs.readback_PV_QS2});
            pause(0.4);
        end

        delta = max(abs(current_value - values));
        obj.daqhandle.dispMessage(sprintf('%s %s %s %s %s %s %s %s %s readback is %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f %0.2f', quadPVs.readback_PV_FF0,quadPVs.readback_PV_FF1,quadPVs.readback_PV_FF2,quadPVs.readback_PV_FF3,quadPVs.readback_PV_FF4,quadPVs.readback_PV_FF5,quadPVs.readback_PV_FF0,quadPVs.readback_PV_FF1,quadPVs.readback_PV_FF2, current_value(1), current_value(2), current_value(3),current_value(4), current_value(5), current_value(6),current_value(7), current_value(8), current_value(9)));
            
end
