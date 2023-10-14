classdef Target_H15_C1_V10_Test < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        function coordinateTest(testCase)
            t = Target_H15_C1_V10();
            actual = t.getHolePosition([1;26;27]);
            expected = [[0,0];[0,37.5e-3];[1.3e-3,36.75e-3]];
            testCase.assertEqual(actual, expected, "AbsTol", 1e-6)
        end
        function plot(testCase)
            t = Target_H15_C1_V10();
            holes = 1:t.numberOfHoles;
            pos = t.getHolePosition(holes');
            lat = pos(:,1);
            vert = pos(:,2);
            figure();
            hold on
            plot(lat, vert, '--k')
            plot(lat, vert, 'o')
            hold off
            daspect([1 1 1])
            pause(0.05);
        end
    end

end




