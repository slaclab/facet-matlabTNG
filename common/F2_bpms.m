classdef F2_bpms < handle
  properties
  end
  properties(SetAccess=private)
    bpmname
    bpmlocation
  end
  properties(Constant)
    secname=["INJ" "L1" "L2" "L3" "S20"] ;
  end
  methods
    function obj = F2_bpms()
      
      % Form master BPM list
      
    end
    function readbuffer(obj,npulse)
      aidainit;
      import edu.stanford.slac.aida.lib.da.DaObject;
      da = DaObject();
      da.reset;
      da.setParam('BPMD', '57');
      da.setParam('NRPOS', num2str(npulse));
      da.setParam('BPM1', 'BPMS:LI11:701');
      
      buffdata = da.getDaValue(strcat('FACET-II', '//BUFFACQ'));
      
      buffdata.get(2).getAsDoubles()
    end
  end
end
