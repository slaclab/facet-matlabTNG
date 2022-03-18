classdef F2_common < handle
  %F2_COMMON
  
  properties(Constant)
    confdir = "/u1/facet/matlab/config"
    modeldir = "/usr/local/facet/tools/facet2-lattice/Lucretia/models"
    LucretiaLattice = "/usr/local/facet/tools/facet2-lattice/Lucretia/models/FACET2e/FACET2e.mat"
    % LucretiaLattice = "/usr/local/facet/tools/facet2-lattice/Lucretia/models/FACET2e/FACET2e_altL2Match.mat" % lattice with Q11401 OFF
  end
  properties
    UseArchive logical = false % Extract data from archive if true, else get live data
    ArchiveDate(1,6) = [2021,7,1,12,1,1] % [yr,mnth,day,hr,min,sec]
  end
  properties(Dependent)
    datadir
    beamrate
  end
  properties(Access=private)
    monirate logical = false
  end
  methods
    function beamrate = get.beamrate(obj)
      if ~obj.monirate
        lcaSetMonitor('IOC:SYS1:MP01:MS_RATE');
        obj.monirate=true;
        beamrate = double(regexp(string(lcaGet('IOC:SYS1:MP01:MS_RATE',1)),'(\d+)','match')) ;
      else
        if lcaNewMonitorValue('IOC:SYS1:MP01:MS_RATE')
          beamrate = double(regexp(string(lcaGet('IOC:SYS1:MP01:MS_RATE',1)),'(\d+)','match')) ;
        end
      end
      beamrate=uint8(beamrate);
    end
    function dname = get.datadir(obj) %#ok<MANU>
      ds=datestr(now,29);
      dname = "/u1/facet/matlab/data/" + regexp(ds,'^\d+','match','once') + "/" + ...
        regexp(ds,'^\d+-\d+','match','once') + "/" + ds ;
    end
    function [bact,bdes] = MagnetGet(obj,name)
      %MAGNETGET Get magnet BDES & BACT data from live EPICS or archive
      %[bact,bdes] = MagnetGet(name)
      % name in cellstr format
      if obj.UseArchive
        [bact,bdes] = archive_magnetGet(name,obj.ArchiveDate) ;
      else
        [bact,bdes] = control_magnetGet(name) ;
      end
    end
  end
  methods(Static)
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

