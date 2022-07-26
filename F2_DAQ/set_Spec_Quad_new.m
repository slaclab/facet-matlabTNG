function [delta] = set_Spec_Quad_new(obj, quadPV, BDESs)

    %Sets the spectrometer quads to whatever BDES values you want
    delta = set_Quads_BDES(obj, quadPV, BDESs);

    obj.daqhandle.dispMessage(sprintf('Q0D-Q1D set to within tolerance'));

end


function [delta] = set_Quads_BDES(obj, quadPVs, values)

        control_magnetSet({quadPVs.control_PV0,quadPVs.control_PV1,quadPVs.control_PV2},values,'action','TRIM');
        obj.daqhandle.dispMessage(sprintf('Setting %s %s %s to %0.2f %0.2f %0.2f', quadPVs.control_PV0,quadPVs.control_PV1,quadPVs.control_PV2, values(1), values(2), values(3)));

        current_value = control_magnetGet({quadPVs.readback_PV0,quadPVs.readback_PV1,quadPVs.readback_PV2});

        while max(abs(current_value - values)) > obj.tolerance
            current_value = control_magnetGet({quadPVs.readback_PV0,quadPVs.readback_PV1,quadPVs.readback_PV2});
            pause(0.4);
        end

        delta = max(abs(current_value - values));
        obj.daqhandle.dispMessage(sprintf('%s %s %s readback is %0.2f %0.2f %0.2f', quadPVs.readback_PV0,quadPVs.readback_PV1,quadPVs.readback_PV2, current_value(1), current_value(2), current_value(3)));
            
end
