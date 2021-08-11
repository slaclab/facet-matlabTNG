classdef PicoDefender < handle
    
    % This should detect if the picomotor controller becomes unresponsive
    % and attempt to revive the device
    
    properties
        
        picomotor_list
        controller_list
        powerSupply_list
        
    end
    properties(Constant)
        
        pico_root = 'MOTR:LI20'
        
    end
    
end
    
    