t = Target_H15_C1_V10();

holes = (1:t.numberOfHoles)';
positions = t.getHolePosition(holes);
x = positions(:, 1);
y = positions(:, 2);

plot(x, y, '--k');
hold on
plot(x, y, 'o');

for j = 1:length(holes)
    text(x(j), y(j), num2str(j));
end
hold off

xlim([min(x) - 5e-3, max(x) + 5e-3]);
ylim([min(y) - 5e-3, max(y) + 5e-3]);
daspect([1 1 1])