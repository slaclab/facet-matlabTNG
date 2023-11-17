classdef RTSTransform_Test < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function unityTransform(testCase)
            coordinatesIn = rand(2,2);
            coordinatesOut = coordinatesIn;
            testCoordinates = rand(10, 2);

            tr = RTSTransform();
            tr.calibrate(coordinatesIn, coordinatesOut);
            transformedCoordinates = tr.transform(testCoordinates);
            testCase.assertEqual(transformedCoordinates, testCoordinates, "AbsTol", 1e-6)
        end

        function ScaleTransform(testCase)
            scale = 2;
            coordinatesIn = [[0,0];[1,1]];
            coordinatesOut = coordinatesIn * scale;
            testCoordinates = rand(10, 2);

            tr = RTSTransform();
            tr.calibrate(coordinatesIn, coordinatesOut);
            transformedCoordinates = tr.transform(testCoordinates);

            testCase.assertEqual(transformedCoordinates, testCoordinates * scale, "AbsTol", 1e-6)
        end      
        
        function RotationTransform(testCase)
            coordinatesIn = [[0,0];[1,1]];
            coordinatesOut = [[0,0];[1,-1]];

            tr = RTSTransform();
            tr.calibrate(coordinatesIn, coordinatesOut);
            transformedCoordinates = tr.transform(coordinatesIn);

            testCase.assertEqual(transformedCoordinates, coordinatesOut, "AbsTol", 1e-6)
        end 
    end
    
end