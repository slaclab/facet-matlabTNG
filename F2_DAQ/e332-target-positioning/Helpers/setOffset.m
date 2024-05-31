function setOffset(lat, vert)
    pvEngine = PVEngineLca();
    config = PVStorage.getConfigurationSection(pvEngine);
    config.targetGlobalOffsetLat = lat;
    config.targetGlobalOffsetVert = vert;
    display(config);
    PVStorage.setConfigurationSection(pvEngine, config);
end