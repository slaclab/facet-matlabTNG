classdef F2_EventClass < handle

    properties
        INCL_NAME
        INCL_UNIQ
        INCL_VALS
        INCL_VAL0
        EXCL_NAME
        EXCL_UNIQ
        EXCL_VALS
        EXCL_VAL0
    end

    properties(Constant)
        %INCL_BIT_NAMES = {'TS5','FFTB_ext','MPS_POCKCELL'}
        %INCL_BIT_ENUMS = {'I'  ,'J'       ,'M'           }
        %INCL_BIT_VALUE = {0x10 ,0x400000  ,0x100000      }
        
        INCL_BIT_NAMES = {'TS5','FFTB_ext'}
        INCL_BIT_ENUMS = {'I'  ,'J'       }
        INCL_BIT_VALUE = {0x10 ,0x400000  }
        
        EXCL_BIT_NAMES = {'BCSFAULT','NO_GUN_PERM','TS1','TS2','TS3','TS4','TS6'}
        EXCL_BIT_ENUMS = {'N'       ,'N'          ,'N'  ,'N'  ,'N'  ,'N'  ,'N'  }
        EXCL_BIT_VALUE = {0x8000    ,0x100000     ,0x1  ,0x2  ,0x4  ,0x8  ,0x20 }
        
        STOP_BIT_NAME  = 'DUMP_2_9'
        STOP_BIT_ENUM  = 'I'
        STOP_BIT_VAL   = 0x4000
        
        RATE_BIT_NAMES = {'TEN_HERTZ','FIVE_HERTZ','ONE_HERTZ','HALF_HERTZ','ASSET'} % asset is 0.2 Hz
        RATE_BIT_ENUMS = {'J'        ,'J'         ,'I'        ,'I'         ,'J'    }
        RATE_BIT_VALUE = {0x400      ,0x10000     ,0x1000000  ,0x20000     ,0x40000}
        
        DAQ_EVNT_PV    = 'EVNT:SYS1:1:PMAQCHCK' % EC 214
    end
    
    methods
        
        function obj = F2_EventClass()
            
            % First, set up default bits
            obj.INCL_UNIQ = unique(obj.INCL_BIT_ENUMS);
            obj.INCL_VAL0 = zeros(1,numel(obj.INCL_UNIQ),'uint32');
            for i = 1:numel(obj.INCL_BIT_ENUMS)
                ind = find(strcmp(obj.INCL_BIT_ENUMS{i},obj.INCL_UNIQ));
                obj.INCL_VAL0(ind) = obj.INCL_VAL0(ind) + uint32(obj.INCL_BIT_VALUE{i});
            end
            obj.INCL_VALS = obj.INCL_VAL0;
            obj.INCL_NAME = obj.INCL_BIT_NAMES;
            
            obj.EXCL_UNIQ = unique(obj.EXCL_BIT_ENUMS);
            obj.EXCL_VAL0 = zeros(1,numel(obj.EXCL_UNIQ),'uint32');
            for i = 1:numel(obj.EXCL_BIT_ENUMS)
                ind = find(strcmp(obj.EXCL_BIT_ENUMS{i},obj.EXCL_UNIQ));
                obj.EXCL_VAL0(ind) = obj.EXCL_VAL0(ind) + uint32(obj.EXCL_BIT_VALUE{i});
            end
            obj.EXCL_VALS = obj.EXCL_VAL0;
            obj.EXCL_NAME = obj.EXCL_BIT_NAMES;
            
        end
        
        function stop_event(obj)
            % This includes DUMP_2_9 which sets rate to 0
            ind = find(strcmp(obj.STOP_BIT_ENUM,obj.INCL_UNIQ));
            obj.INCL_VALS(ind) = obj.INCL_VALS(ind) + uint32(obj.STOP_BIT_VAL);
            lcaPut([obj.DAQ_EVNT_PV '.' obj.STOP_BIT_ENUM], double(obj.INCL_VALS(ind)));
        end
        
        function start_event(obj)
            % This removes DUMP_2_9 which enables rate
            ind = find(strcmp(obj.STOP_BIT_ENUM,obj.INCL_UNIQ));
            obj.INCL_VALS(ind) = obj.INCL_VALS(ind) - uint32(obj.STOP_BIT_VAL);
            lcaPut([obj.DAQ_EVNT_PV '.' obj.STOP_BIT_ENUM], double(obj.INCL_VALS(ind)));
        end
        
        function set_default(obj)
            obj.INCL_NAME = obj.INCL_BIT_NAMES;
            obj.INCL_VALS = obj.INCL_VAL0;
            for i = 1:numel(obj.INCL_UNIQ)
                lcaPut([obj.DAQ_EVNT_PV '.' obj.INCL_UNIQ{i}], double(obj.INCL_VALS(i)));
            end
            
            obj.EXCL_NAME = obj.EXCL_BIT_NAMES;
            obj.EXCL_VALS = obj.EXCL_VAL0;
            for i = 1:numel(obj.EXCL_UNIQ)
                lcaPut([obj.DAQ_EVNT_PV '.' obj.EXCL_UNIQ{i}], double(obj.EXCL_VALS(i)));
            end
        end
        
        function select_rate(obj,rate)
            
            if strcmp(rate,'BEAM')
                obj.set_default();
            else
                try
                    obj.set_default();
                    
                    ind  = find(strcmp(rate,obj.RATE_BIT_NAMES));
                    enum = obj.RATE_BIT_ENUMS{ind};
                    val  = obj.RATE_BIT_VALUE{ind};
                    
                    obj.INCL_NAME = [obj.INCL_BIT_NAMES {rate}];
                    
                    ind = find(strcmp(enum,obj.INCL_UNIQ));
                    obj.INCL_VALS(ind) = obj.INCL_VAL0(ind) + uint32(val);
                    lcaPut([obj.DAQ_EVNT_PV '.' enum], double(obj.INCL_VALS(ind)));
               
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
            event_info.ratePV = 'EVNT:SYS1:1:PMAQRATE';
            event_info.beamRatePV = 'EVNT:SYS1:1:BEAMRATE';
            
            event_info.liveRate = lcaGet(event_info.ratePV);
            event_info.beamRate = lcaGet(event_info.beamRatePV);
            event_info.rateRatio = event_info.beamRate/event_info.liveRate;
            
        end

            
        
    end
    
end