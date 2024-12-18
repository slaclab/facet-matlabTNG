classdef scanFunc_E332_TargetPosition < handle
    %SCANFUNC_E332TARGETPOSITION DAQ scan function (class) for the E332 target

    properties
        targetAssembly
        pvEngine
        daqhandle
        transform
        currentPosition

        pvlist PV
        pvs
        guihan
        freerun
        tolerance
    end

    properties(Constant)
        % Constants required by the DAQ
        control_PV = "SIOC:SYS1:ML03:AO654"
        readback_PV = "SIOC:SYS1:ML03:AO654"
    end

    methods
        function obj = scanFunc_E332_TargetPosition(daqhandle)
            %SCANFUNC_E332TARGETPOSITION Constructor
            %   daqhandle: daqhandle provided by the DAQ
            %   pvEngine: the PV engine (wrapper) to use. Defaults to PVEngineLca()
            %   transform: the coordinate transform to use. Defaults to
            %   RTSTransform(), which is rotation+translation+scale.
            %             arguments
            %                 daqhandle = DaqHandleMock()
            %                 pvEngine (1,1) PVEngine = PVEngineLca()
            %                 transform (1,1) CoordinateTransform = RTSTransform()
            %             end

            addpath(genpath('e332-target-positioning'));

            % Check if scanfunc called by DAQ
            if ~exist('daqhandle','var')
                daqhandle = DaqHandleMock();
            end

            if isprop(daqhandle,'guihan')
                if isa(daqhandle.guihan,'F2_DAQ')
                    obj.guihan = daqhandle.guihan;
                    obj.guihan.Blockbeam.Value = true;
                end
            end


            pvEngine = PVEngineLca();
            transform = RTSTransform();

            obj.pvEngine = pvEngine;
            obj.daqhandle = daqhandle;

            context = PV.Initialize(PVtype.EPICS_labca);
            obj.pvlist=[...
                PV(context,'name',"control",'pvname',obj.control_PV,'mode',"rw",'monitor',true); % Control PV
                PV(context,'name',"readback",'pvname',obj.readback_PV,'mode',"r",'monitor',true); % Readback PV
                ];
            pset(obj.pvlist,'debug',0);
            obj.pvs = struct(obj.pvlist);


            %             % Find the number of installed targets
            %             numTargets = pvEngine.get(obj.numTargets_PV);
            %             for i = 1:numTargets
            %                 target = E332Target(i, pvEngine, transform);
            %                 target.tolerance = obj.tolerance;
            %                 obj.targets{i} = target;
            %             end
            obj.tolerance = 0.1;
            obj.targetAssembly = E332TargetAssembly(pvEngine, pvEngine);
        end

        function delta = set_value(obj, holeNumber)
            %SET_VALUE Moves the E332 target to a specific hole denoted by
            %the hole number
            timer = tic;
            obj.targetAssembly.moveToHole(floor(holeNumber));
            elapsedTime = toc(timer);

            %             targetNumber = floor(holeNumber / 1000) + 1;
            %             targetHoleNumber = mod(holeNumber, 1000);
            %             target = obj.targets{targetNumber};
            %
            %             delta = target.moveToHole(targetHoleNumber, obj.asyncMove);
            %             obj.pvEngine.put(obj.control_PV, holeNumber);
            %info = PVStorage.getInformationSection(pvEngine);

            obj.daqhandle.dispMessage(sprintf('Moved to hole %d in %.3f seconds.', holeNumber, elapsedTime))
        end

        function restoreInitValue(obj)
            obj.daqhandle.dispMessage('NOT Restoring initial value!');
        end
    end
end

