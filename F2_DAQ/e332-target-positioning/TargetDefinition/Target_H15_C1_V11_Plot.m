t = Target_H15_C1_V11();

holes = (1:t.numberOfHoles)';
positions = t.getHolePosition(holes);
x = positions(:, 2);
y = positions(:, 1);

plot(x, y, '--k');
hold on
plot(x, y, 'o');

for i = 1:length(holes)
    %    text(x(j), y(j), sprintf('%d\n%s', j, Target_H15_C1_V10.holeStringFromNumber(j)), 'fontsize', 6);
    text(x(i), y(i), num2str(i), ...
        'fontsize', 5, ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle');
end

for col = 1:t.columnCount
    pos = t.getHolePosition(t.holeNumberFromRowCol(1, col));
    text(pos(2) - 0.003, pos(1), num2str(col), 'fontsize', 8);
end
for row = 1:t.rowCount
    pos = t.getHolePosition(t.holeNumberFromRowCol(row, 1));
    text(pos(2), pos(1) - 0.002, char('A' + row - 1), 'fontsize', 8);
end

hold off

xlim([min(x) - 5e-3, max(x) + 5e-3]);
ylim([min(y) - 5e-3, max(y) + 5e-3]);
daspect([1 1 1])