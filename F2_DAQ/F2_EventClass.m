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
        
        eDefNum
        eDefStr
        BUFF_ACQ_PV
        nAvg = 1
        nPos = 2800
        BEAMCODE = 10
    end

    properties(Constant)
        
        
        % This is from original FACET and we are using it to turn DAQ rate on and off
        STOP_BIT_NAME  = 'DUMP_2_9'
        STOP_BIT_ENUM  = 'I'
        STOP_BSA_ENUM  = '1'
        STOP_BIT_VAL   = 0x4000
        
        % These are the suffixes for the EC mod bit PVs
        INCL_ENUMS = {'I','J','K','L','M'};
        EXCL_ENUMS = {'N','O','P','Q','R'};
        
        % These are the suffixes for the BSA mod bit PVs
        BSA_ENUMS  = {'1','2','3','4','5'};
        
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
        DAQ_EVNT_ON    = 'EVNT:SYS1:1:PMAQCTRL.E' % EC 214 on/off
        DAQ_EVNT_NUM   = 'EVNT:SYS1:1:PMAQCTRL.H' % Number of shots
        
        % These return event rates
        BEAM_RATE_PV   = 'EVNT:SYS1:1:BEAMRATE' % EC 203
        DAQ_RATE_PV    = 'EVNT:SYS1:1:PMAQRATE' % EC 214
        
        TENH_RATE_PV   = 'EVNT:SYS1:1:TS5_TE_RATE' % EC 223
        FIVH_RATE_PV   = 'EVNT:SYS1:1:TS5_FV_RATE' % EC 224
        ONEH_RATE_PV   = 'EVNT:SYS1:1:TS5_ON_RATE' % EC 225
        HLFH_RATE_PV   = 'EVNT:SYS1:1:TS5_HF_RATE' % EC 226
        
        % These return pulse IDs
        BEAM_PID_PV    = 'PATT:SYS1:1:PULSEIDBR'
        ONEH_PID_PV    = 'PATT:SYS1:1:PULSEID1H'
        TENH_PID_PV    = 'PATT:SYS1:1:PULSEIDTH'
        
        % BUFF ACQ N Runs PV
        BSA_RUNS_PV    = 'SIOC:SYS1:ML02:AO500'
    end
    
    methods
        
        function obj = F2_EventClass()
            
            % Set up default inclusion bits for beam rate
            obj.INCL_VALS = obj.MODIFIER_INCL_BEAM;
            obj.EXCL_VALS = obj.MODIFIER_EXCL_BEAM;
            obj.INCL_STOP_VALS = obj.MODIFIER_INCL_BEAM_STOP;
            %obj.INCL_NAME = obj.INCL_ENUMS;
            %obj.EXCL_NAME = obj.EXCL_ENUMS;
            
            % Reserve eDef
            obj.reserve_eDef();
            
        end
        
        function stop_event(obj)
            % This includes DUMP_2_9 which sets rate to 0
            
            % This affects the 'I' bit (Modifier 2) with index 1 in our list of EC214 INCLs
            lcaPut([obj.DAQ_EVNT_PV '.' obj.STOP_BIT_ENUM], double(obj.INCL_STOP_VALS(1)));
            
            % This affects the '1' bit (Modifier 2) with index 1 in our list of BUFFACQ INCLs
            lcaPut([obj.BUFF_ACQ_PV ':INCLUSION' obj.STOP_BSA_ENUM], double(obj.INCL_STOP_VALS(1)));
        end
        
        function stop_event_HDF5(obj)
            lcaPut([obj.BUFF_ACQ_PV ':CTRL'],0);
            lcaPut(obj.DAQ_EVNT_ON,0);
        end
        
        function start_event(obj)
            % This removes DUMP_2_9 which enables rate
            
            % This affects the 'I' bit (Modifier 2) with index 1 in our list of EC214 INCLs
            lcaPut([obj.DAQ_EVNT_PV '.' obj.STOP_BIT_ENUM], double(obj.INCL_VALS(1)));
            
            % This affects the '1' bit (Modifier 2) with index 1 in our list of BUFFACQ INCLs
            lcaPut([obj.BUFF_ACQ_PV ':INCLUSION' obj.STOP_BSA_ENUM], double(obj.INCL_VALS(1)));
        end
        
        function start_event_HDF5(obj)
            lcaPut([obj.BUFF_ACQ_PV ':CTRL'],1);
            lcaPut(obj.DAQ_EVNT_ON,1);
        end
        
        function set_default(obj) % default = beam
            % This function loops over bits and sets them to desired value
            % for beam rate
            
            % Set bits to default for beam rate
            obj.INCL_VALS = obj.MODIFIER_INCL_BEAM;
            obj.EXCL_VALS = obj.MODIFIER_EXCL_BEAM;
            obj.INCL_STOP_VALS = obj.MODIFIER_INCL_BEAM_STOP;
            
            
            % Loop over INCL bits
            for i = 1:numel(obj.INCL_VALS)
                
                % This affects EC214 INCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.INCL_ENUMS{i}], double(obj.INCL_VALS(i)));
                
                % This affects BUFFACQ INCLs
                lcaPut([obj.BUFF_ACQ_PV ':INCLUSION' obj.BSA_ENUMS{i}], double(obj.INCL_VALS(i)));
            end
            
            % Loop over EXCL bits
            for i = 1:numel(obj.EXCL_VALS)

                % This affects EC214 EXCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.EXCL_ENUMS{i}], double(obj.EXCL_VALS(i)));
                
                % This affects BUFFACQ EXCLs
                lcaPut([obj.BUFF_ACQ_PV ':EXCLUSION' obj.BSA_ENUMS{i}], double(obj.EXCL_VALS(i)));
            end
            
            obj.RATE = 'BEAM';
        end
        
        function set_default_HDF5(obj) % default = beam
            % This function loops over bits and sets them to desired value
            % for beam rate
            
            % Set bits to default for beam rate
            obj.INCL_VALS = obj.MODIFIER_INCL_BEAM;
            obj.EXCL_VALS = obj.MODIFIER_EXCL_BEAM;
            
            
            % Loop over INCL bits
            for i = 1:numel(obj.INCL_VALS)
                
                % This affects EC214 INCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.INCL_ENUMS{i}], double(obj.INCL_VALS(i)));
                
                % This affects BUFFACQ INCLs
                lcaPut([obj.BUFF_ACQ_PV ':INCLUSION' obj.BSA_ENUMS{i}], double(obj.INCL_VALS(i)));
            end
            
            % Loop over EXCL bits
            for i = 1:numel(obj.EXCL_VALS)

                % This affects EC214 EXCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.EXCL_ENUMS{i}], double(obj.EXCL_VALS(i)));
                
                % This affects BUFFACQ EXCLs
                lcaPut([obj.BUFF_ACQ_PV ':EXCLUSION' obj.BSA_ENUMS{i}], double(obj.EXCL_VALS(i)));
            end
            
            obj.RATE = 'BEAM';
        end
        
        function set_fixed(obj,rate)
            % This function loops over bits and sets them to desired value
            % for fixed rate
            
            % First choose your bits
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
            
            % Then loop over INCL bits
            for i = 1:numel(obj.INCL_VALS)
                
                % This affects EC214 INCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.INCL_ENUMS{i}], double(obj.INCL_VALS(i)));
                
                % This affects BUFFACQ INCLs
                lcaPut([obj.BUFF_ACQ_PV ':INCLUSION' obj.BSA_ENUMS{i}], double(obj.INCL_VALS(i)));
            end
            
            % Then loop over EXCL bits
            for i = 1:numel(obj.EXCL_VALS)

                % This affects EC214 EXCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.EXCL_ENUMS{i}], double(obj.EXCL_VALS(i)));
                
                % This affects BUFFACQ EXCLs
                lcaPut([obj.BUFF_ACQ_PV ':EXCLUSION' obj.BSA_ENUMS{i}], double(obj.EXCL_VALS(i)));
            end
            
            obj.RATE = rate;
        end
        
        function set_fixed_HDF5(obj,rate)
            % This function loops over bits and sets them to desired value
            % for fixed rate
            
            % First choose your bits
            if strcmp(rate,'TEN_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_10HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_10HZ;
            elseif strcmp(rate,'FIVE_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_5HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_5HZ;
            elseif strcmp(rate,'ONE_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_1HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_1HZ;
            elseif strcmp(rate,'HALF_HERTZ')
                obj.INCL_VALS = obj.MODIFIER_INCL_05HZ;
                obj.EXCL_VALS = obj.MODIFIER_EXCL_05HZ;
            else
                error(['Rate ' rate ' not recognized.']);
            end
            
            % Then loop over INCL bits
            for i = 1:numel(obj.INCL_VALS)
                
                % This affects EC214 INCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.INCL_ENUMS{i}], double(obj.INCL_VALS(i)));
                
                % This affects BUFFACQ INCLs
                lcaPut([obj.BUFF_ACQ_PV ':INCLUSION' obj.BSA_ENUMS{i}], double(obj.INCL_VALS(i)));
            end
            
            % Then loop over EXCL bits
            for i = 1:numel(obj.EXCL_VALS)

                % This affects EC214 EXCLs
                lcaPut([obj.DAQ_EVNT_PV '.' obj.EXCL_ENUMS{i}], double(obj.EXCL_VALS(i)));
                
                % This affects BUFFACQ EXCLs
                lcaPut([obj.BUFF_ACQ_PV ':EXCLUSION' obj.BSA_ENUMS{i}], double(obj.EXCL_VALS(i)));
            end
            
            obj.RATE = rate;
        end
        
        function select_rate(obj,rate)
            % Choose DAQ rate
            
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
        
        function reserve_eDef(obj)
            % Reserve a BUFFACQ edef
            
            % Update number of runs
            nRuns = lcaGet(obj.BSA_RUNS_PV)+1;
            lcaPut(obj.BSA_RUNS_PV,nRuns);
            obj.eDefStr = sprintf('BUFFACQ %d',nRuns);
            
            % Reserve eDef
            obj.eDefNum = eDefReserve(obj.eDefStr);
            
            % This is dumb
            while obj.eDefNum > 11
                eDefRelease(obj.eDefNum);
                obj.eDefNum = eDefReserve(obj.eDefStr);
            end
            
            obj.BUFF_ACQ_PV = ['EDEF:SYS1:' num2str(obj.eDefNum)];
            
            % Now set beam code and max buffer
            lcaPut([obj.BUFF_ACQ_PV ':BEAMCODE'],obj.BEAMCODE);
            lcaPut([obj.BUFF_ACQ_PV ':MEASCNT'],obj.nPos);
            
        end
        
        function release_eDef(obj)
            
            eDefRelease(obj.eDefNum);
            
        end
        
        function start_eDef(obj)
            
            lcaPut([obj.BUFF_ACQ_PV ':CTRL'],1);
            
        end
        
        function stop_eDef(obj)
            
            lcaPut([obj.BUFF_ACQ_PV ':CTRL'],0);
            
        end
        
        function event_info = evt_struct(obj)
            % This function returns a metadata struct about the event
            
            event_info = struct();
            event_info.EC = 214;

            event_info.incmSet = obj.INCL_ENUMS;
            event_info.incmReset =  {''};
            event_info.excmSet = obj.EXCL_ENUMS;
            event_info.excmReset = {''};
            event_info.inclBits = obj.INCL_VALS;
            event_info.exclBits = obj.EXCL_VALS;
            
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