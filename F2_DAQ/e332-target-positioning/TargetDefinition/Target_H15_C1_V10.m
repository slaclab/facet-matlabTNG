classdef Target_H15_C1_V10 < TargetDefinition
    %Target definition for the Target-H1.5-C1-V1.0 target
    
    properties (Constant)
        rowCount = 26
        columnCount = 34

        holeSize = 1e-3
        holeDistance = 1.5e-3
    end
    
    properties(SetAccess=private, GetAccess=public)
        numberOfHoles = Target_H15_C1_V10.rowCount * Target_H15_C1_V10.columnCount
    end
   
    methods
        function pos = getHolePosition(obj, holeNumber)
            %Returns the lateral and vertical position of
            %a given hole number. Hole numbers start from 0.
            row = mod(holeNumber - 1, obj.rowCount);
            column = floor((holeNumber - 1) / obj.rowCount);
            
            % Reverse even row numbers
            idxInOddRow = find(mod(column, 2));
            row(idxInOddRow) = obj.rowCount - 1 - row(idxInOddRow);

            % Calculate lat and vert position
            vert = row .* obj.holeDistance;
            % Correct for even columns
            vert(idxInOddRow) = vert(idxInOddRow) - sin(30/180*pi) * obj.holeDistance;

            lat = column .* cos(30/180*pi) * obj.holeDistance;
            pos = [lat, vert];
        end
        
        function plot_holes(obj, ax)
            holes = (1:obj.getNumberOfHoles())';
            positions = obj.getHolePosition(holes);
            x = positions(:, 1);
            y = positions(:, 2);
            
            hold(ax, 'on');
            plot(ax, x, y, '--k');
            plot(ax, x, y, 'o');
            for j = 1:length(holes)
                text(x(j), y(j), num2str(j));
            end
            hold(ax, 'off');
            
            xlim([min(x) - 5e-3, max(x) + 5e-3]);
            ylim([min(y) - 5e-3, max(y) + 5e-3]);
            daspect([1 1 1])
        end
        function plot_outline(ax)
            hold(ax, 'on');
            
            arc = @(center, radius, start, stop) [radius * sin(linspace(start, stop, 20)) + center(1); radius * cos(linspace(start, stop, 20)) + center(1)];

            x = [];
            y = [];
            
            % Add the straight line segment
            %x(end+1) = 
            
            hold(ax, 'off');
        end
    end

    methods (Static)
        function holeNumber = holeNumberFromRowCol(row, col)
            %HOLENUMBERFROMROWCOL Returns the hole number from the grid row
            %and column (starting with 1).
            arguments
                row (1,1) {mustBeInteger}
                col (1,1) {mustBeInteger}
            end
            %mustBeInRange(row, 1, Target_H15_C1_V10.rowCount)
            %mustBeInRange(col, 1, Target_H15_C1_V10.columnCount)

            holeNumber = (col - 1) * Target_H15_C1_V10.rowCount;
            if mod(col, 2) == 0
                holeNumber = holeNumber + Target_H15_C1_V10.rowCount - row;
            else
                holeNumber = holeNumber + row - 1;
            end
            holeNumber = holeNumber + 1;
        end
        function holeNumber = holeNumberFromString(str)
            %HOLENUMBERFROMSTRING returns the hole number for strings
            %indicating the row and column. Ex. "A1" returns 1, "Z34"
            %returns 884. 'str' needs to be a single character followed by
            %a number
            str = string(str);
            str = str.upper();
            rowChar = str{1}(1);
            row = rowChar - 'A' + 1;
            col = str2num(str{1}(2:end));
            holeNumber = Target_H15_C1_V10.holeNumberFromRowCol(row, col);
        end

        function holeString = holeStringFromNumber(holeNumber)
            column = floor((holeNumber - 1) / Target_H15_C1_V10.rowCount);
            row = mod(holeNumber - 1, Target_H15_C1_V10.rowCount);
            if mod(column, 2) == 1
               row = Target_H15_C1_V10.rowCount - row - 1; 
            end
            rowChar = 'A' + row;
            columnString = num2str(column + 1);
            holeString = [rowChar, columnString];
        end
    end
end
