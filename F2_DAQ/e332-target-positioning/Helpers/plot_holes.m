ta = E332TargetAssembly(PVEngineLca(), PVEngineMock());

figure()
hold on


plot(ta.config.targetAlPositionLat, ta.config.targetAlPositionVert, 'o', 'DisplayName','Al 100um');
plot(ta.config.targetIdlePositionLat, ta.config.targetIdlePositionVert, 'o', 'DisplayName','Standby');


for i = 1:length(ta.targets)
    x = [];
    y = [];
    for holeNumber = 1:ta.targets{i}.getNumberOfHoles()
        pos = ta.targets{i}.getHolePosition(holeNumber);
        x(holeNumber) = pos.lat;
        y(holeNumber) = pos.vert;
    end
    plot(x, y, '-x', 'DisplayName', sprintf('Target %i', i));
end

for i = 1:length(ta.targetAreas)
    x = [];
    y = [];
    targetArea = ta.targetAreas{i};
    for holeNumber = 1:targetArea.getNumberOfHoles()
        pos = targetArea.getHolePosition(holeNumber);
        x(holeNumber) = pos.lat;
        y(holeNumber) = pos.vert;
    end
    fprintf('TargetArea %i: %i/%i\n', i, targetArea.getCurrentHolePosition().hole, targetArea.getNumberOfHoles())
    plot(x, y, '-x', 'DisplayName', sprintf('Target area %i (MF%i)', i, targetArea.parameters.numFoils));
end
legend()
hold off