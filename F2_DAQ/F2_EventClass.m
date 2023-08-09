classdef F2_EventClass < handle
    % sgess 2023: if this isn't working, and you can't get a hold of me,
    % ask Nate Lipkowitz

    properties

        INCL_VALS
        INCL_NAME
        INCL_STOP_VALS        
        EXCL_NAME        
        EXCL_VALS

        
        RATE = 'BEAM'
    end

    properties(Constant)
        
        
        % This is from original FACET and we are using it to turn DAQ rate on and off
        STOP_BIT_NAME  = 'DUMP_2_9'
        STOP_BIT_ENUM  = 'I'
        STOP_BIT_VAL   = 0x4000
        
        % These are the suffixes for the mod bit PVs
        INCL_ENUMS = {'I','J','K','L','M'};
        EXCL_ENUMS = {'N','O','P','Q','R'};
        
        % These are modifer INCL/EXCL bit vals for BEAM, 10 Hz, and 1 Hz
        MODIFIER_INCL_BEAM = [0x10u32 0x400000u32 0x0u32 0x0u32 0x0u32]; % modifiers for 203
        MODIFIER_EXCL_BEAM = [0x10802Fu32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 203
        
        MODIFIER_INCL_10HZ = [0x10u32 0x400u32 0x0u32 0x0u32 0x0u32]; % modifiers for 223
        MODIFIER_EXCL_10HZ = [0x2Fu32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 223
        
        MODIFIER_INCL_5HZ = [0x10u32 0x10000u32 0x0u32 0x0u32 0x0u32]; % modifiers for 224
        MODIFIER_EXCL_5HZ = [0x2Fu32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 224
        
        MODIFIER_INCL_1HZ = [0x1000010u32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 225
        MODIFIER_EXCL_1HZ = [0x2Fu32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 225
        
        MODIFIER_INCL_05HZ = [0x20010u32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 226
        MODIFIER_EXCL_05HZ = [0x2Fu32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 226
        
        % These are modifer INCL/EXCL bit vals when 2-9 stop bit is used
        MODIFIER_INCL_BEAM_STOP = [0x4010u32 0x400000u32 0x0u32 0x0u32 0x0u32]; % modifiers for 203 with 2-9
        MODIFIER_INCL_10HZ_STOP = [0x4010u32 0x400u32 0x0u32 0x0u32 0x0u32]; % modifiers for 223 with 2-9
        MODIFIER_INCL_5HZ_STOP = [0x4010u32 0x10000u32 0x0u32 0x0u32 0x0u32]; % modifiers for 224 with 2-9
        MODIFIER_INCL_1HZ_STOP = [0x1004010u32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 225 with 2-9
        MODIFIER_INCL_05HZ_STOP = [0x24010u32 0x0u32 0x0u32 0x0u32 0x0u32]; % modifiers for 226 with 2-9
        
        
        % This just returns event code (214)
        DAQ_EVNT_PV    = 'EVNT:SYS1:1:PMAQCHCK' % EC 214
        
        % These return event rates
        BEAM_RATE_PV   = 'EVNT:SYS1:1:BEAMRATE' % EC 203
        DAQ_RATE_PV    = 'EVNT:SYS1:1:PMAQRATE' % EC 214
        
        TENH_RATE_PV   = 'EVNT:SYS1:1:TS5_TE_RATE' % EC 223
        FIVH_RATE_PV   = 'EVNT:SYS1:1:TS5_FV_RATE' % EC 224
        ONEH_RATE_PV   = 'EVNT:SYS1:1:TS5_ON_RATE' % EC 225
        HLFH_RATE_PV   = 'EVNT:SYS1:1:TS5_HF_RATE' % EC 226
        
        % These return pulse IDs
        BEAM_PID_PV    = 'PATT:SYS1:1:PULSEIDBR';
        ONEH_PID_PV    = 'PATT:SYS1:1:PULSEID1H';
        TENH_PID_PV    = 'PATT:SYS1:1:PULSEIDTH';
    end
    
    methods
        
        function obj = F2_EventClass()
            
            % Set up default inclusion bits for beam rate
            obj.INCL_VALS = obj.MODIFIER_INCL_BEAM;
            obj.EXCL_VALS = obj.MODIFIER_EXCL_BEAM;
            obj.INCL_STOP_VALS = obj.MODIFIER_INCL_BEAM_STOP;
            obj.INCL_NAME = obj.INCL_ENUMS;
            obj.EXCL_NAME = obj.EXCL_ENUMS;
            
            
            
        end
        
        function stop_event(obj)
            % This includes DUMP_2_9 which sets rate to 0
            % This affects the 'I' bit with index 1 in our list
            lcaPut([obj.DAQ_EVNT_PV '.' obj.STOP_BIT_ENUM], double(obj.INCL_STOP_VALS(1)));
        end
        
        function start_event(obj)
            % This removes DUMP_2_9 which enables rate
            % This affects the 'I' bit with index 1 in our list
            lcaPut([obj.DAQ_EVNT_PV '.' obj.STOP_BIT_ENUM], double(obj.INCL_VALS(1)));
        end
        
        function set_default(obj) % default = beam
            % This function loops over bits and sets them to desired value
            % for beam rate
            
            obj.INCL_VALS = obj.MODIFIER_INCL_BEAM;
            for i = 1:numel(obj.INCL_VALS)
                lcaPut([obj.DAQ_EVNT_PV '.' obj.INCL_NAME{i}], double(obj.INCL_VALS(i)));
            end
            
            obj.EXCL_VALS = obj.MODIFIER_EXCL_BEAM;
            for i = 1:numel(obj.EXCL_VALS)
                lcaPut([obj.DAQ_EVNT_PV '.' obj.EXCL_NAME{i}], double(obj.EXCL_VALS(i)));
            end
            
            obj.INCL_STOP_VALS = obj.MODIFIER_INCL_BEAM_STOP;
            
            obj.RATE = 'BEAM';
        end
        
        function set_fixed(obj,rate)
            
            if strcmp(rate,'TEN_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_10HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_10HZ;
                obj.INCL_STOP_VALS = obj.MODIFIER_INCL_10HZ_STOP;
            elseif strcmp(rate,'FIVE_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_5HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_5HZ;
                obj.INCL_STOP_VALS = obj.MODIFIER_INCL_5HZ_STOP;
            elseif strcmp(rate,'ONE_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_1HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_1HZ;
                obj.INCL_STOP_VALS = obj.MODIFIER_INCL_1HZ_STOP;
            elseif strcmp(rate,'HALF_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_05HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_05HZ;
                obj.INCL_STOP_VALS = obj.MODIFIER_INCL_05HZ_STOP;
            else
                error(['Rate ' rate ' not recognized.']);
            end
     
            
            for i = 1:numel(obj.INCL_VALS)
                lcaPut([obj.DAQ_EVNT_PV '.' obj.INCL_NAME{i}], double(obj.INCL_VALS(i)));
            end

            for i = 1:numel(obj.EXCL_VALS)
                lcaPut([obj.DAQ_EVNT_PV '.' obj.EXCL_NAME{i}], double(obj.EXCL_VALS(i)));
            end
            
            obj.RATE = rate;
        end
        
        function select_rate(obj,rate)
            
            if strcmp(rate,'BEAM')
                obj.set_default();
            else
                try                    
                    obj.set_fixed(rate);
                catch
                    
                    error('Invalid rate modifier.');
                    
                end
            end
            disp(['Set rate ' rate]);
        end
        
        function event_info = evt_struct(obj)
            
            event_info = struct();
            event_info.EC = 214;

            event_info.incmSet = obj.INCL_NAME;
            event_info.incmReset =  {''};
            event_info.excmSet = obj.EXCL_NAME;
            event_info.excmReset = {''};
            event_info.beamcode = 10;
            event_info.ratePV = obj.DAQ_RATE_PV;
            event_info.beamRatePV = obj.BEAM_RATE_PV;
            
            if strcmp(obj.RATE,'BEAM')
                event_info.PID_PV = obj.BEAM_PID_PV;
                event_info.ratePV = obj.BEAM_RATE_PV;
            elseif strcmp(obj.RATE,'HALF_HERTZ')
                event_info.PID_PV = obj.BEAM_PID_PV;
                event_info.ratePV = obj.HLFH_RATE_PV;
            elseif strcmp(obj.RATE,'ONE_HERTZ')
                event_info.PID_PV = obj.ONEH_PID_PV;
                event_info.ratePV = obj.ONEH_RATE_PV;
            elseif strcmp(obj.RATE,'FIVE_HERTZ')
                event_info.PID_PV = obj.BEAM_PID_PV;
                event_info.ratePV = obj.FIVH_RATE_PV;
            elseif strcmp(obj.RATE,'TEN_HERTZ')
                event_info.PID_PV = obj.TENH_PID_PV;
                event_info.ratePV = obj.TENH_RATE_PV;
            else
                error('Invalid rate modifier.');
            end
            
            event_info.liveRate = lcaGet(event_info.ratePV);
            event_info.beamRate = lcaGet(event_info.beamRatePV);
            event_info.rateRatio = event_info.beamRate/event_info.liveRate;
            
        end

            
        
    end
    
end