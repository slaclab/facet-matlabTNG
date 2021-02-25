classdef GUI_PREFS
  %GUI_PREFS Global preferences for GUIs
  
  properties
    guiLampCol(1,3) cell = {'red','green','black'} % Colors for GUI lamp objects (on, off, error/unknown states)
    gaugeLimitExtension(1,2) single {mustBePositive,mustBeLessThan(gaugeLimitExtension,1)} = [0.1,0.1] % how far to extend guage readings past min/max vals
    gaugeCol(1,3) cell = {'red' 'green' 'red'} % Guage colors for in-range and beyond range regions (LinearGauge ScaleColors property)
    gaugeLims(1,2) single = [0,inf] % Limits to gauge display
  end
  
end

