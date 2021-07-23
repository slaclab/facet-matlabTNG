classdef F2_common < handle
  %F2_COMMON
  
  properties(Constant)
    confdir = "/u1/facet/matlab/config"
    modeldir = "/usr/local/facet/tools/facet2-lattice/Lucretia/models"
    LucretiaLattice = "/usr/local/facet/tools/facet2-lattice/Lucretia/models/FACET2e/FACET2e.mat"
  end
  properties(Dependent)
    datadir
  end
  methods
    function dname = get.datadir(obj) %#ok<MANU>
      ds=datestr(now,29);
      dname = "/u1/facet/matlab/data/" + regexp(ds,'^\d+','match','once') + "/" + ...
        regexp(ds,'^\d+-\d+','match','once') + "/" + ds ;
    end
  end
  methods(Static)
    function aidaput(pv,val)
      aidainit;
      import java.util.Vector;
      import edu.stanford.slac.aida.lib.da.DaObject;
      import edu.stanford.slac.aida.lib.util.common.*;
      da = DaObject();
      da.setParam('TRIM','YES');
      try
        da.setDaValue(char(pv),DaValue(java.lang.Float(val)));
      catch ME
        da.reset;
        fprintf(2,'Error setting AIDA PV: %s\n',pv);
        fprintf(2,'%s',ME.message)
      end
      da.reset;
    end
    function dnum = epics2mltime(tstamp)
      % Put epics time stamp as Matlab datenum format in gui requested
      % local time
      persistent toffset tzoffset
      if isempty(toffset)
        toffset=datenum('1-jan-1970');
        tzoffset=-double(java.util.Date().getTimezoneOffset()/60);
      end
      dnum=toffset+floor(tstamp+tzoffset*3600)*1e3/86400000;
    end
  end
end

