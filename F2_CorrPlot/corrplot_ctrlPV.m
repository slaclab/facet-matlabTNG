classdef corrplot_ctrlPV < handle
    % object to hold attributes of a control PV in the corrPlot GUI
    
    properties
        name % name of the PV
        pv = struct('name',{},'val',{},'ts',{},'desc',{},'egu',{}); % initial values from util_readPV
        range % [low, high]
        idx = 1 % index in the vallist currently being looked at
        settletime = 1 % time to wait between successive sets of the PV
        vallist % list of values to which to set the PV
        numvals % number of sets to do
        currentVal % live value of the PV
        relative = 0
    end
    
    methods
        function obj = corrplot_ctrlPV(name, low, high, numvals, settletime, relative)
            % instatiate a ctrlPV by setting each property
            if nargin < 6, relative = 0; end
            if nargin < 5, settletime = 1; end
            if nargin < 4, numvals = 1; end
            if nargin < 3, high = 1; end
            if nargin < 2, low = 0; end
                
            obj.name = name;
            obj.pv = util_readPV(obj.name, 1); % read initial value of the pv
            if strcmp(obj.name, 'MKB:VAL')
                obj.pv.val = 0;
            end
            obj.currentVal = obj.pv.val;
            obj.numvals = numvals;
            obj.relative = relative;
            setRange(obj, low, high);
            obj.settletime = settletime;
            
        end
        
        % setters
        function setRange(obj, low, high)
            % set a new range, which impacts the val list
            obj.range = [low, high]; 
            calcValList(obj);
        end
        
        function setRelative(obj, relative)
            % change the relative option, which will in turn change the
            % value list
            obj.relative = relative; 
            calcValList(obj);
        end
        
        function setIdx(obj, idx)
            % change the current index
            if idx > 0 && idx <= length(obj.vallist)
                obj.idx = idx;
            end
        end
        
        function setNumvals(obj, numvals)
            % set the number of values in the vallist
            obj.numvals = numvals;
            if obj.idx > numvals
                obj.idx = numvals;
            end
            calcValList(obj);
        end
        
        function pvSet(obj, relative, refList, element)
            % set the PV to the value of the current index in vallist
            if nargin < 4, element = []; end
            if nargin < 3, refList = []; end
            if nargin < 2, relative = 0; end
                
            % if non mkb scan, val = obj.pv.val + obj.vallist(obj.idx)
            
            if relative
                % set the value relative to the previously set one
                currVal = obj.vallist(element);
                refIdx = find(refList == element);
                if refIdx > 1
                    oldVal = obj.vallist(refList(refIdx - 1));
                else
                    oldVal = currVal;
                end
                val = currVal - oldVal;
            else
                val = obj.vallist(obj.idx);
            end
            % do the actual setting, make sure it was successful
            wasSet = obj.putVal(obj.name, val);
            if wasSet, obj.currentVal = val; end
        end
        
        function pvReset(obj, relative, refList)
            % set the PV to its initial value
            if nargin < 3, refList = []; end
            if nargin < 2, relative = 0; end
            
            % if a non-mkb relative scan, this needs to go to the else
            if relative 
                % relative difference will be negative of the last
                % set value
                val = -obj.vallist(refList(end));
            else
                val = obj.pv.val;
            end
            % do the actual setting, make sure it was successful
            wasSet = obj.putVal(obj.name, val);
            if wasSet, obj.currentVal = val; end
        end
        
        function setNewVal(obj, val)
            % update the pv with new current val and time
            if nargin < 2
                obj.pv = util_readPV(obj.name, 1);
            else
                obj.pv.val = val;
            end
        end
        
        function calcValList(obj)
            % calculate a new list of values
            if isempty(obj.numvals), obj.numvals = 2; end
            if obj.relative
                useRange = obj.range + obj.pv.val;
            else
                useRange = obj.range;
            end
            if useRange(1) ~= useRange(2)
                obj.vallist = linspace(useRange(1), useRange(2), obj.numvals);
            else
                obj.vallist = useRange(1) * ones(1, obj.numvals);
            end
        end
        
        function val = getVal(obj)
            % return the value pointed at by the current index
            val = obj.vallist(obj.idx);
        end
        
        
    end
    
    methods(Static)
        
        function setVal = putVal(pv, val)
            % put the desired value to the PV
            global da_mkb
            [micro, prim, unit, secn] = model_nameSplit(pv);
            % identify if pv may need a special acquisition (magnet, aida)
            if strncmp(pv,'LI',2) || strncmp(pv,'TA',2) || strncmp(pv,'DR12',4) || strncmp(pv,'MKB:VAL',7)
                %    if strcmp(secn,'BDES') || strcmp(secn,'VDES')
                if strcmp(secn,'BDES')
                    try
                        control_magnetSet(strcat(micro, ':', prim, ':', unit), val);
                        setVal = true;
                    catch
                        fprintf('Error setting magnet %s', pv)
                        setVal = false; 
                    end
                else
                    if ~ispc
                        aidapva;
                        try
                            if strncmp(pv,'MKB:VAL',7)
                                da_mkb.set(val);
                                setVal = true;
                            else
                                pvaSet(strcat(prim, ':', micro, ':',unit,':',secn), val);
                                setVal = true;
                            end
                        catch
                            disp(['Error in setting value for ' pv]);
                            setVal = false;
                        end
                    else
                        lcaPutSmart(pv,val);
                        setVal = true;
                    end
                end
            else
                lcaPutSmart(pv,val);
                setVal = true;
                if strcmp(pv,'SIOC:SYS0:ML00:AO9999') %Test input
%                     [hObj,h]=util_appFind('fxnTest_gui');
%                     set(h.fxn_pmu,'Value',3);
%                     set(h.fxnInput,'String',num2str(val));
%                     fxnTest_gui('fxnInput_Callback',hObj, [], guidata(hObj));
                end
            end
        end
        
    end
    
end

