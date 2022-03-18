classdef SCP_MKB < handle
  %SCP_MKB SCP Multiknob
  %   Set and Get SCP multiknob data
  
  properties
    DeviceNames string % Names of multiknob devices
    DeviceVals % Multiknob device values
    val = 0 % Multiknob value
    Name string
  end
  properties(Access=protected)
    builder
  end
  
  methods
    function obj = SCP_MKB(mkname)
      %SCP_MKB(mkname)
      %  mknames = SCP multiknob name (either with or without mkb:: prefix and/or .mkb extension)
      
      % Initialize multiknob through AIDA-PVA
      for itry=1:3
        try
          aidapva;
          mkname="mkb:"+regexprep(lower(mkname),"^mkb:","");
          mkname=regexprep(lower(mkname),"\.mkb$","")+".mkb";
          obj.builder = pvaRequest('MKB:VAL');
          obj.builder.with('MKB', char(mkname));
          obj.set(0);
          obj.Name = mkname ;
          break
        catch ME
          fprintf(2,"Failed to initialize SCP multiknob through AIDA-PVA\n");
          if itry==3
            throw(ME);
          else
            pause(1);
          end
        end
      end
        
    end
    function mkval = get(obj)
      %MKBGET Get SCP multiknob data
      aidapva;
      dat = ML(obj.builder.get());
      obj.DeviceNames = string(dat.values.name) ;
      obj.DeviceVals = dat.values.value ;
      mkval = obj.val ;
    end
    function set(obj,val)
      %MKBSET Set a SCP multiknob value
      %MKBset(val)
      aidapva;
      dat = ML(obj.builder.set(double(val-obj.val)));
      obj.DeviceNames = string(dat.values.name) ;
      obj.DeviceVals = dat.values.value ;
      obj.val = val ;
    end
  end
end

