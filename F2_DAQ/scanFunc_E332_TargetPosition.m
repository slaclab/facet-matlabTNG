classdef scanFunc_E332TargetPosition < handle
%SCANFUNC_E332TARGETPOSITION DAQ scan function (class) for the E332 target
    
    properties
        target
        pvEngine
        daqhandle
        transform
        currentPosition
    end

    properties(Constant)
        asyncMove = false
    end
    
    properties(Constant)
        % Constants required by the DAQ
        control_PV = "SIOC:SYS1:ML03:AO657"
        readback_PV = "SIOC:SYS1:ML03:AO657"
        tolerance = 1e-1
    end

    methods
        function obj = scanFunc_E332TargetPosition(daqhandle, pvEngine, transform)
            %SCANFUNC_E332TARGETPOSITION Constructor
            %   daqhandle: daqhandle provided by the DAQ
            %   pvEngine: the PV engine (wrapper) to use. Defaults to PVEngineLca()
            %   transform: the coordinate transform to use. Defaults to
            %   RTSTransform(), which is rotation+translation+scale.
            arguments
                daqhandle = DaqHandleMock()
                pvEngine (1,1) PVEngine = PVEngineLca()
                transform (1,1) CoordinateTransform = RTSTransform()
            end

            obj.pvEngine = pvEngine;
            obj.daqhandle = daqhandle;
            
            obj.target = E332Target(pvEngine, transform);
            obj.target.tolerance = obj.tolerance;
        end
        
        function delta = set_value(obj, holeNumber)
            %SET_VALUE Moves the E332 target to a specific hole denoted by
            %the hole number
            timer = tic;
            delta = obj.target.moveToHole(holeNumber, obj.asyncMove);
            elapsedTime = toc(timer);
            obj.pvEngine.put(obj.control_PV, holeNumber);
            obj.daqhandle.dispMessage(sprintf("Target moved to hole %d at Lat=%.6f and Vert=%.6f in %.3f seconds.", obj.target.currentPosition.hole, obj.target.currentPosition.lat, obj.target.currentPosition.vert, elapsedTime))
        end

        function restoreInitValue(obj)
            obj.daqhandle.dispMessage("NOT Restoring initial value!");
        end
    end
end

