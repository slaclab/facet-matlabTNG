function [max_delta] = set_Spec_Quad_new(obj, quadPV, BDESs)

    %Sets the spectrometer quads to whatever BDES values you want
    
    
    [deltas] = set_Quads_BDES(obj, quadPV, BDESs);
%     [delta1] = set_Quad_BDES(obj, quadPV.control_PV1, quadPV.readback_PV1, BDES1);
%     [delta2] = set_Quad_BDES(obj, quadPV.control_PV2, quadPV.readback_PV2, BDES2);

     obj.daqhandle.dispMessage(sprintf('Q0D-Q1D set to within tolerance'));

     max_delta = max([delta0, delta1, delta2]);
end


function [delta] = set_Quads_BDES(obj, quadPVs, values)

        control_magnetSet({quadPVs.control_PV0,quadPVs.control_PV1,quadPVs.control_PV2},values,'action','TRIM');
        obj.daqhandle.dispMessage(sprintf('Setting %s to %0.2f', control_PV, value));

        current_value = control_magnetGet(readback_PV);

        while abs(current_value - value) > obj.tolerance
            current_value = control_magnetGet(readback_PV);
            pause(0.4);
        end

        delta = current_value - value;
        obj.daqhandle.dispMessage(sprintf('%s readback is %0.2f', readback_PV, current_value));
            
end
