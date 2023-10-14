classdef E332Target_Test < matlab.unittest.TestCase
    
    properties(Constant)
        pvEngineCalibration = PVEngineMock();
        pvEngineMotors = PVEngineMock(duration(0,0,0.5), true);
        coordinateTransform = UnityTransform();
        targetDefinition = Target_H15_C1_V10();
    end
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function moveToCorners_AllMock(testCase)
            % Create mock pv engine
            pvEngine = PVEngineMock();
            pvEngine.readbackDelay = duration(0, 0, 0.2);
            pvEngine.verbose = false;
            
            % Set calibtraion points such that hole B2 is at (0,0) and hole Y33 at (1,1)
            points(1).hole = Target_H15_C1_V10.holeNumberFromString("B2");
            points(1).lat = 0;
            points(1).vert = 0;
            
            points(2).hole = Target_H15_C1_V10.holeNumberFromString("Y33");
            points(2).lat = 1;
            points(2).vert = 1;
            
            calibration = Calibration(pvEngine);
            for i = 1:length(points)
                point = points(i);
                calibration.setCalibrationPoint(i, point.hole, point.lat, point.vert);
            end
            
            target = E332Target(pvEngine);
            %target.pvEngineMotors = PVEngineMock();
            
            holes = ["A1", "Z1", "Z34", "A34", "A1"];
            for hole = holes
                holeNumber = target.targetDefinition.holeNumberFromString(hole);
                nextPosition = target.getHolePosition(holeNumber);
                fprintf('Next hole: %s with position lat = %f, vert = %f\n', hole, nextPosition.lat, nextPosition.vert);
                input('Move to next hole?');
                target.moveToHole(holeNumber);
                fprintf('Moved to position: lat = %f, vert = %f\n\n', target.currentPosition.lat, target.currentPosition.vert);
                
            end
        end
        
        function moveToCorners_MockMotors(testCase)
            target = E332Target(PVEngineLca());
            target.pvEngineMotors = PVEngineMock();
            target.pvEngineMotors.readbackDelay = duration(0, 0, 2);
            target.pvEngineMotors.verbose = false;
            
            holes = ["A1", "X1", "X34", "A34", "A1"];
            for hole = holes
                holeNumber = target.targetDefinition.holeNumberFromString(hole);
                nextPosition = target.getHolePosition(holeNumber);
                fprintf('Next hole: %s with position lat = %f, vert = %f\n', hole, nextPosition.lat, nextPosition.vert);
                input('Move to next hole?');
                target.moveToHole(holeNumber);
                fprintf('Moved to position: lat = %f, vert = %f\n\n', target.currentPosition.lat, target.currentPosition.vert);
                
            end
        end
        
        function moveToCorners_Lca(testCase)
            target = E332Target(PVEngineLca());
            
            holes = ["A1", "X1", "X34", "A34", "A1"];
            for hole = holes
                holeNumber = target.targetDefinition.holeNumberFromString(hole);
                nextPosition = target.getHolePosition(holeNumber);
                fprintf('Next hole: %s with position lat = %f, vert = %f\n', hole, nextPosition.lat, nextPosition.vert);
                input('Move to next hole?');
                target.moveToHole(holeNumber);
                fprintf('Moved to position: lat = %f, vert = %f\n\n', target.currentPosition.lat, target.currentPosition.vert);
            end
        end
        
        
        function moveToAllHoles_AllMock(testCase)
            % Create mock pv engine
            pvEngine = PVEngineMock();
            pvEngine.readbackDelay = duration(0, 0, 0.2);
            pvEngine.verbose = true;
            
            % Set calibtraion points such that hole B2 is at (0,0) and hole Y33 at (1,1)
            points(1).hole = Target_H15_C1_V10.holeNumberFromString("B2");
            points(1).lat = 0;
            points(1).vert = 0;
            
            points(2).hole = Target_H15_C1_V10.holeNumberFromString("Y33");
            points(2).lat = 1;
            points(2).vert = 1;
            
            calibration = Calibration(pvEngine);
            for i = 1:length(points)
                point = points(i);
                calibration.setCalibrationPoint(i, point.hole, point.lat, point.vert);
            end
            
            target = E332Target(pvEngine);
            
            holeNumbers = 1:target.targetDefinition.numberOfHoles;
            
            figure()
            pos = NaN(2, length(holeNumbers) + 1);
            pos(:,1) = [target.currentPosition.lat, target.currentPosition.vert];
            
            plot(pos(1,:), pos(2,:), '--k');
            hold on
            plot(pos(1,:), pos(2,:), 'o');
            hold off
            drawnow;
            
            for i = 1:length(holeNumbers)
                holeNumber = holeNumbers(i);
                
                nextPosition = target.getHolePosition(holeNumber);
                fprintf('Next hole: %i with position lat = %f, vert = %f\n', holeNumber, nextPosition.lat, nextPosition.vert);
                input('Move to next hole?');
                target.moveToHole(holeNumber);
                fprintf('Moved to position: lat = %f, vert = %f\n\n', target.currentPosition.lat, target.currentPosition.vert);
                
                pos(:,i) = [target.currentPosition.lat, target.currentPosition.vert];
                
                plot(pos(1,:), pos(2,:), '--k');
                hold on
                plot(pos(1,:), pos(2,:), 'o');
                hold off
                drawnow;
            end
        end
        
        
        function moveToAllHoles_Lca(testCase)
            
            target = E332Target(PVEngineLca());
            
            holeNumbers = 1:target.targetDefinition.numberOfHoles;
            
            figure()
            pos = NaN(2, length(holeNumbers) + 1);
            pos(:,1) = [target.currentPosition.lat, target.currentPosition.vert];
            
            plot(pos(1,:), pos(2,:), '--k');
            hold on
            plot(pos(1,:), pos(2,:), 'o');
            hold off
            drawnow;
            
            for i = 1:length(holeNumbers)
                holeNumber = holeNumbers(i);
                
                nextPosition = target.getHolePosition(holeNumber);
                fprintf('Next hole: %i with position lat = %f, vert = %f\n', holeNumber, nextPosition.lat, nextPosition.vert);
                %input('Move to next hole?');
                tic;
                target.moveToHole(holeNumber);
                fprintf('Moved to position: lat = %f, vert = %f\n\n', target.currentPosition.lat, target.currentPosition.vert);
                toc;
                pos(:,i) = [target.currentPosition.lat, target.currentPosition.vert];
                
                plot(pos(1,:), pos(2,:), '--k');
                hold on
                plot(pos(1,:), pos(2,:), 'o');
                hold off
                drawnow;
            end
        end
        function moveToAllHoles_LcaNoplot(testCase)
            
            target = E332Target(PVEngineLca());
            
            holeNumbers = 1:target.targetDefinition.numberOfHoles;
            
            
            for i = 1:length(holeNumbers)
                holeNumber = holeNumbers(i);
                
                nextPosition = target.getHolePosition(holeNumber);
                fprintf('Next hole: %i with position lat = %f, vert = %f\n', holeNumber, nextPosition.lat, nextPosition.vert);
                tic;
                target.moveToHole(holeNumber);
                fprintf('Moved to position: lat = %f, vert = %f\n\n', target.currentPosition.lat, target.currentPosition.vert);
                toc;

            end
        end
        
        
    end
    
end