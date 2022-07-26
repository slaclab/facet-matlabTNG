classdef acFlipper < handle
   methods(Abstract)
      flip(obj)
      sStr = getState(obj)
   end
end