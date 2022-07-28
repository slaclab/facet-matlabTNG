function [delta] = set_Spec_QuadDipole(obj, quadPV, BDESs)

    %Sets the spectrometer quads to whatever BDES values you want
    delta = set_QuadsDipole_BDES(obj, quadPV, BDESs);

    obj.daqhandle.dispMessage(sprintf('Q0D-Q1D set to within tolerance'));

end


function [delta] = set_QuadsDipole_BDES(obj, quadPVs, values)

        control_magnetSet({quadPVs.control_PV0,quadPVs.control_PV1,quadPVs.control_PV2,quadPVs.control_PV3},values,'action','TRIM');
        obj.daqhandle.dispMessage(sprintf('Setting Quads %s %s %s to %0.2f %0.2f %0.2f, and dipole %s to %0.2f', quadPVs.control_PV0,quadPVs.control_PV1,quadPVs.control_PV2,quadPVs.control_PV3, values(1), values(2), values(3), values(4)));

        current_value = control_magnetGet({quadPVs.readback_PV0,quadPVs.readback_PV1,quadPVs.readback_PV2,quadPVs.readback_PV3});

        while max(abs(current_value - values)) > obj.tolerance
            current_value = control_magnetGet({quadPVs.readback_PV0,quadPVs.readback_PV1,quadPVs.readback_PV2,quadPVs.readback_PV3});
            pause(0.4);
        end

        delta = max(abs(current_value - values));
        obj.daqhandle.dispMessage(sprintf('%s %s %s and %s readback is %0.2f %0.2f %0.2f and %0.2f', quadPVs.readback_PV0,quadPVs.readback_PV1,quadPVs.readback_PV2,quadPVs.readback_PV3, current_value(1), current_value(2), current_value(3), current_value(4)));
            
end
