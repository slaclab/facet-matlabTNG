classdef scanFunc_E332TargetPosition_Test < matlab.unittest.TestCase
    
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end
    
    methods(TestMethodSetup)
        % Setup for each test
    end
    
    methods(Test)
        % Test methods
        
        function move(testCase)
    
            tp = scanFunc_E332TargetPosition(DaqHandleMock(), PVEngineLca());


            holes = 1:tp.target.targetDefinition.numberOfHoles;

            % Create an empty plot where the data points will successively
            % be added to
            figure();
            x = NaN(1, length(holes));
            y = NaN(1, length(holes));

            elapsedTime = zeros(1, length(holes));

            % Move the target over each hole
            for i = holes
                % Move target
                tic;
                tp.set_value(i);
                elapsedTime(i) = toc;

                % Add new target position to list
                x(i) = tp.target.currentPosition.lat;
                y(i) = tp.target.currentPosition.vert;

                % Replot the figure (quick&dirty)
                plot(x, y, '--k');
                hold on
                plot(x, y, 'o');
                hold off
                xlim([-0.2, 1.2]);
                ylim([-0.2, 1.2]);
                daspect([1 1 1])
                drawnow
                
                %pause(0.05);
            end

            fprintf("Elapsed time for 'set_value' function: %.5f\n", mean(elapsedTime));

            % Just fail the test for now.
            testCase.verifyFail();
        end
        
        function move_noPlot(testCase)
            tp = scanFunc_E332TargetPosition(DaqHandleMock(), PVEngineLca());
            holes = 1:tp.target.targetDefinition.numberOfHoles;
            elapsedTime = zeros(1, length(holes));
            % Move the target over each hole
            for i = holes
                % Move target
                tic;
                tp.set_value(i);
                elapsedTime(i) = toc;
            end
            fprintf("Elapsed time for 'set_value' function: %.5f\n", mean(elapsedTime));
            % Just fail the test for now.
            testCase.verifyFail();
        end
    end
    
end