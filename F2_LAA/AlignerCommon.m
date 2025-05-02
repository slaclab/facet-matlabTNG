classdef AlignerCommon
    %ALIGNERCOMMON Functions common between both aligner apps
    %   This class abstracts the common alignment functionality used by
    %   both the base auto-aligner and the IR mode auto-aligner
    
    properties
        app
    end
    
    methods
        function obj = AlignerCommon(app)
            %ALIGNERCOMMON Construct an instance of this class
            %   Needs the app instance in order to write to the log
            obj.app = app;
        end
        
        function clearReferences(self)
            % CLEAR REFERENCES Sets all the reference parameter fields in
            % config to empty arrays.
            
            sections = fieldnames(self.app.config);
            for i=1:numel(sections)
                section = self.app.config.(sections{i});
                cameras = fieldnames(section.cameras);
                for j=1:numel(cameras)
                    camera = section.cameras.(cameras{j});
                    camera.refSumCts = [];
                    camera.refRMSSize = [];
                    camera.refExposureTime = [];
                    camera.refROIminX = [];
                    camera.refROIminY = [];
                    camera.refROIsizeX = [];
                    camera.refROIsizeY = [];
                    self.app.config.(sections{i}).cameras.(cameras{j}) = camera;
                end
            end
            self.app.appendMessage('Cleared Reference Laser Parameters');
        end
        
        function checkBool = checkReferences(self, checkBool)
            % CHECKREFERENCES Check that references are set for all the cameras
            
            sections = fieldnames(self.app.config);
            notWarned = 1;
            for i=1:numel(sections)
                section = self.app.config.(sections{i});
                cameras = fieldnames(section.cameras);
                for j=1:numel(cameras)
                    camera = section.cameras.(cameras{j});
                    if (isempty(camera.refSumCts) || isempty(camera.refRMSSize) || isempty(camera.refExposureTime)) && notWarned
                        self.app.appendMessage('ERROR - No laser references grabbed');
                        checkBool = 0;
                        notWarned = 0;
                    end
                end
            end
        end
        
        % #################################################################
        % #
        % # Core alignment checks and logic
        % #
        % #################################################################
        function exitcondition = evaluateExitCondition(self, section)
            % EXITCONDITION Checks if the camera image and settings match
            % the references for all the camera in a section.
            %
            % Args:
            %     section: Section struct to check.
            
            % Only check for sections that we are aligning on
            if lcaGetSmart(section.feedbackOnPV) 
                self.app.appendMessage(newline); %Seperate out the sections in the log
                % Get the reference settings for this section of the laser
                exitCondition = 0;
                cameras = fieldnames(section.cameras);
                for j=1:numel(cameras)
                    camera = section.cameras.(cameras{j});
                    newCamera = getParamsAndStats(camera, self.app.fitMethod);
                    newSumCts = newCamera.refSumCts;
                    newRMSSize = newCamera.refRMSSize;
                    newExposureTime = newCamera.refExposureTime;
                    ts = newCamera.TS;
                    
                    % Apply logic
                    % Check that the exposure time has not changed
                    exposureFail = any(abs(newExposureTime-camera.refExposureTime)>1e-10);
                    if exposureFail
                        msg = ['WARNING - Camera exposure time changed on ', cameras{j}];
                        self.app.appendMessage(msg);
                    end
                    % Check that the RMS size is within 25%
                    relativeRMSChange = (newRMSSize/camera.refRMSSize)-1;
                    rmsSizeFail = any(abs(relativeRMSChange)>0.40);
                    if rmsSizeFail
                        msg = ['WARNING - RMS spotsize has changed by more than 25% on ', cameras{j}];
                        self.app.appendMessage(msg);
                    end
                    % Check that the sum counts has not changed by >50%
                    relativeSumCtsChange = (newSumCts/camera.refSumCts)-1;
                    sumCtsFail = any(abs(relativeSumCtsChange)>0.5);
                    if sumCtsFail
                        msg = ['WARNING - Sum counts has changed by more than 50% on ', cameras{j}];
                        self.app.appendMessage(msg);
                    end
                    if self.app.disableTimestampCheckForCameras
                        tsFail = 0;
                        self.app.appendMessage('WARNING - timestamp check disabled for cameras by user. Go to expert panel to re-enable.');
                    else
                        tenSec = 1/360/24;
                        tsFail = any(abs(now-ts)>tenSec);
                        if tsFail
                            msg = ['WARNING - Image timestamp more than 10 s old for ', cameras{j}];
                            self.app.appendMessage(msg);
                        end
                    end
                    exitcondition = any([ ...
                        exitCondition ...
                        lcaGetSmart(self.app.feedbackExitPV) ...
                        ~lcaGetSmart(section.feedbackOnPV) ...
                        exposureFail ...
                        rmsSizeFail ...
                        sumCtsFail ...
                        tsFail]);
                end
                validGainFail = any(isnan(section.gain));
                if validGainFail
                    self.app.appendMessage('One or more invalid Gain values. Skipping alignment');
                end
                exitcondition = any([ ...
                    exitcondition, ...
                    validGainFail]);
                if exitcondition == 1
                    self.app.appendMessage(['Alignment skipped for ', section.name]);
                end
            else
                exitcondition = 1;
            end
        end
        
        function alignLaserToSetpoint(self, section)
            % ALIGNLASERTOSETPOINT Calculates picomotor movements and moves the motors
            % 
            %   Args:
            %       section: struct containing all of the info about the section
            
            offsets = self.getOffsetsFromSetpoint(section);
            self.app.appendMessage(['Offset from setpoint: ', newline, num2str(offsets.')]);
            failed = self.checkOffsets(section, offsets);
            if failed == 1; return; end
            mirrorMovements = self.getMirrorCorrection(section, offsets);
            self.app.appendMessage(['Motor motion: ', newline, num2str(mirrorMovements.')]);
            self.moveMirrors(section, mirrorMovements);
            self.app.appendMessage(['Move finished at ', datestr(now)]);
        end
        
        function offsets = getOffsetsFromSetpoint(self, section)
            % GETOFFSETFROMSETPOINT Finds the current offset of the beam
            % from the setpoint.
            %
            %   Args:
            %       section: struct containing all of the info about the section
            %   Returns:
            %       offsets: column vector of offsets (x1, y1, x2, y2, ...)
            %           for cameras 1, 2, ... 
            
            cameras = fieldnames(section.cameras);
            N = section.nShotsAveraged;
            M = numel(cameras);
            offsets = zeros(2*M, 1);
            for j=1:M
                % Load the image for each camera and calculate how far from the target the beam center is
                camera = section.cameras.(cameras{j});
                for n=1:N
                    [stats(n, :), img, data] = grabLaserProperties(camera.cameraPV, self.app.fitMethod);
                end
                centerX = mean(stats(:, 1)) + data.roiX;
                centerY = mean(stats(:, 2)) + data.roiY;
                offsets(1+2*(j-1)) = double(camera.target(1)) - centerX;
                offsets(2*j) = double(camera.target(2)) - centerY;
            end
            % Round the offsets to 2 decimal places and don't do anything if the beam is less than 0.5px off
            offsets = round(offsets, 2);
            indicesToZero = abs(offsets) < 0.5;
            offsets(indicesToZero) = 0;
        end
        
        function failed = checkOffsets(self, section, offsets)
            % CHECKOFFSETS Checks that the offsets are within tolerance.
            %
            %   Args:
            %       section: struct containing all of the info about the section
            %       offsets: column vector of offsets (x1, y1, x2, y2, ...)
            %           for cameras 1, 2, ... 
            
            % TODO figure out a way to get rid of this if MPA NF/FF special
            % case, maybe put tolerance in the config and set the config
            % from fields in the expert panel
            failed = 0;
            if strcmp(section.name, 'Mainamp Near and Far')% Special case for MPA near and far
                moveToBig = any(abs(offsets)>self.app.MPANearFarmaxMisalignmentTolerance);
                if any(moveToBig)
                    self.app.appendMessage(['WARNING - Laser offset is larger than max of ', ...
                        num2str(self.app.MPANearFarmaxMisalignmentTolerance)]);
                    failed = 1;
                end
            elseif strcmp(section.name, 'Comp Far')% Special case for Comp Far
                moveToBig = any(abs(offsets)>self.app.CompFarmaxMisalignmentTolerance);
                if any(moveToBig)
                    self.app.appendMessage(['WARNING - Laser offset is larger than max of ', ...
                        num2str(self.app.CompFarmaxMisalignmentTolerance)]);
                    failed = 1;
                end
            else
                moveToBig = any(abs(offsets)>self.app.maxMisalignmentTolerance);
                if any(moveToBig)
                    self.app.appendMessage(['WARNING - Laser offset is larger than max of ', ...
                        num2str(self.app.maxMisalignmentTolerance)]);
                    failed = 1;
                end
            end
        end
        
        function mirrorMovements = getMirrorCorrection(app, section, offsets)
            % GETMIRRORCORRECTION Calculates how much to move the mirrors
            % for the given offsets.
            % 
            %   Args:
            %       section: struct containing all of the info about the section
            %       offsets: column vector of offsets (x1, y1, x2, y2, ...)
            %           for cameras 1, 2, ... 
            %
            %   Returns:
            %       mirrorMovements: column vector of motor steps, has 
            %           the same structure as offsets.
            
            mirrorMovements = lscov(section.calibrationMatrix, offsets);
            mirrorMovements = section.gain*mirrorMovements;
            if any(isnan(mirrorMovements))
                app.appendMessage('WARNING - NaN mirror movements requested, setting to zero.');
                mirrorMovements(isnan(mirrorMovements)) = 0;
            end
            mirrorMovements = round(mirrorMovements, 3); % Round to nearest thousandth revolution   
        end
        
        function moveMirrors(self, section, mirrorMovements)
            % MOVEMIRRORS Performs the given mirror movement
            % 
            %   Args:
            %       section: struct containing all of the info about the section
            %       mirrorMovements: column vector of motor steps, (x1, y1, x2, y2, ...)
            %           for cameras 1, 2, ... 
            
            cameras = fieldnames(section.cameras);
            M = numel(cameras);
            for j=1:M
                % Check that the motors are connected
                camera = section.cameras.(cameras{j});
                motorStatusH = lcaGetSmart(strcat(camera.horizontalPV, '_TYPE'));
                motorStatusV = lcaGetSmart(strcat(camera.verticalPV, '_TYPE'));
                if regexp('No motor', motorStatusH{1}, 'once') == 1
                    self.app.appendMessage(['WARNING - ', camera.horizontalPV, 'not responding.']);
                end
                if regexp('No motor', motorStatusV{1}, 'once') == 1
                    self.app.appendMessage(['WARNING - ', camera.verticalPV, 'not responding.']);
                end
                 
                % Check that the motor value is equal to the readback value
                motor_rbvH = lcaGetSmart(strcat(camera.horizontalPV, '.RBV'));
                motor_rbvV = lcaGetSmart(strcat(camera.verticalPV, '.RBV'));
                motor_valH = lcaGetSmart(camera.horizontalPV);
                motor_valV = lcaGetSmart(camera.verticalPV);
                if abs(motor_rbvH-motor_valH) > 1e-3
                    self.app.appendMessage('WARNING - Motor value not equal to readback value. Setting motor value to readback value.');
                    lcaPutSmart(camera.horizontalPV, motor_rbvH);
                end
                if abs(motor_rbvV-motor_valV) > 1e-3
                    self.app.appendMessage('WARNING - Motor value not equal to readback value. Setting motor value to readback value.');
                    lcaPutSmart(camera.verticalPV, motor_rbvV);
                end
                
                 lcaPutSmart(strcat(camera.horizontalPV, '.TWV'), mirrorMovements(1+2*(j-1))); % Set relative step
                 lcaPutSmart(strcat(camera.verticalPV, '.TWV'), mirrorMovements(2*j)); % Set relative step
                 lcaPutSmart(strcat(camera.horizontalPV, '.TWF'), 1.0); % Move motor
                 lcaPutSmart(strcat(camera.verticalPV, '.TWF'), 1.0); % Move motor
                 
                 motor_statusH = lcaGetSmart(strcat(camera.horizontalPV, '.MSTA'));
                 motor_statusV = lcaGetSmart(strcat(camera.verticalPV, '.MSTA'));
                 while (motor_statusH ~= 2) || (motor_statusV ~= 2) % motor_status = 2 means it's done moving
                    motor_statusH = lcaGetSmart(strcat(camera.horizontalPV, ':MOTOR.MSTA'));
                    motor_statusV = lcaGetSmart(strcat(camera.verticalPV, ':MOTOR.MSTA'));
                    drawnow()
                 end
                 pause(0.1);
            end
        end
    end
end

