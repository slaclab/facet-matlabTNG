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
  properties(Constant)
    timeout=15 % AIDA-PVA EPICS RPC call timeout / s
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
          obj.builder.timeout(obj.timeout);
          obj.set(0);
          obj.Name = mkname ;
          break
        catch ME
          F2_common.LogMessage("Failed to initialize SCP multiknob through AIDA-PVA",ME.message);
          fprintf(2,"SCP_MKB: Failed to initialize SCP multiknob through AIDA-PVA\n");
          if itry==3
            throw(ME);
          else
            pause(1);
          end
        end
      end
        
    end
    function mkval = get(obj)
      %GET Get SCP multiknob data
      aidapva;
      try
        dat = ML(obj.builder.get());
        obj.DeviceNames = string(dat.values.name) ;
        obj.DeviceVals = dat.values.value ;
        mkval = obj.val ;
      catch ME
        F2_common.LogMessage("SCP_MKB: Error getting MKB "+obj.Name,ME.message);
        fprintf(2,'Error getting MKB %s:\n%s',obj.Name,ME.message);
      end
    end
    function set(obj,val)
      %SET Set a SCP multiknob value
      %set(val)
      aidapva;
      try
        dat = ML(obj.builder.set(double(val-obj.val)));
        obj.DeviceNames = string(dat.values.name) ;
        obj.DeviceVals = dat.values.value ;
        obj.val = val ;
      catch ME
        F2_common.LogMessage("SCP_MKB: Error setting MKB "+obj.Name,ME.message);
        fprintf(2,'Error setting MKB %s:\n%s',obj.Name,ME.message);
      end
    end
  end
end

