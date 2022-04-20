classdef F2_common < handle
  %F2_COMMON
  
  properties(Constant)
    confdir = "/u1/facet/matlab/config"
    modeldir = "/usr/local/facet/tools/facet2-lattice/Lucretia/models"
    LucretiaLattice = "/usr/local/facet/tools/facet2-lattice/Lucretia/models/FACET2e/FACET2e.mat"
    % LucretiaLattice = "/usr/local/facet/tools/facet2-lattice/Lucretia/models/FACET2e/FACET2e_altL2Match.mat" % lattice with Q11401 OFF
    ColorOrder = [ 0         0.4470    0.7410 ;
      0.8500    0.3250    0.0980 ;
      0.9290    0.6940    0.1250 ;
      0.4940    0.1840    0.5560 ;
      0.4660    0.6740    0.1880 ;
      0.3010    0.7450    0.9330 ;
      0.6350    0.0780    0.1840 ]
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
      persistent br
      if ~obj.monirate
        lcaSetMonitor('IOC:SYS1:MP01:MS_RATE');
        obj.monirate=true;
        br = double(regexp(string(lcaGet('IOC:SYS1:MP01:MS_RATE',1)),'(\d+)','match')) ;
      else
        if lcaNewMonitorValue('IOC:SYS1:MP01:MS_RATE')
          br = double(regexp(string(lcaGet('IOC:SYS1:MP01:MS_RATE',1)),'(\d+)','match')) ;
        end
      end
      beamrate=uint8(br);
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
    function AddMagnetPlotZ( istart, iend, ahan )
      %ADDMAGNETPLOTZ -- add a schematic of magnets to a plot vs. Z coordinate.
      %AddMagnetPlotZ(istart,iend,axesObject) 
      
      global BEAMLINE PS
            
      % box heights:
      hfrac=0.2; % Height as a fraction of axis height
      ha=0.8;    % relative height of RF rectangle 
      hb=1;      % relative height of bend rectangle
      hq=4;      % relative height of quadrupole rectangle (only show lower or bottom half depending on polarity)
      hs=3;      % relative height of sextupole rectangle
      ho=2;      % relative height of octupole rectangle
      hr=1;      % relative height of solenoid rectangle
      
      % box colors
      ca = 'y' ;
      cb = 'b' ;
      cq = 'r' ;
      cs = 'g' ;
      co = 'c' ;
      cr = 'm' ;
      
      % master coordinate definitions
      barX = zeros(iend-istart+1,1) ;
      barWidth = barX ;
      barHeight = barX ; % convert to fraction of max height
      maxHeight = max([ha,hb,hq,hs,ho,hr]) ;
      barPolarity = barX ;
      barColor = [] ;
      
      nElem = 0 ; count = istart-1 ;
      
      % loop over elements
      while (count < iend)
        count = count + 1 ;
        height = 0 ;
        switch BEAMLINE{count}.Class
          case {'LCAV','TCAV'}
            height = ha ;
            color = ca ;
          case 'SBEN'
            height = hb ;
            color = cb ;
          case 'PLENS'
            height = hb ;
            color = cq ;
          case 'QUAD'
            height = hq ;
            color = cq ;
            strength = BEAMLINE{count}.B ;
            if (isfield(BEAMLINE{count},'PS'))
              ps = BEAMLINE{count}.PS ;
              if (ps > 0)
                strength = strength * PS(BEAMLINE{count}.PS).Ampl ;
              end
            end
            if (strength<0)
              barPolarity(nElem+1) = -1 ;
            else
              barPolarity(nElem+1) = 1 ;
            end
          case 'SEXT'
            height = hs ;
            color = cs ;
          case 'OCTU'
            height = ho ;
            color = co ;
          case 'SOLENOID'
            height = hr ;
            color = cr ;
        end
        if (height == 0)
          continue ;
        end
        nElem = nElem + 1 ;
        
        % look for a slice definition, if found use it
        if (isfield(BEAMLINE{count},'Slices'))
          LastSlice = BEAMLINE{count}.Slices(end) ;
        else
          LastSlice = count ;
        end
        LastSlice = min([LastSlice iend]) ;
        
        % fill in the data boxes
        barX(nElem) = BEAMLINE{count}.Coordi(3) ;
        barWidth(nElem) = BEAMLINE{LastSlice}.Coordf(3) ;
        barHeight(nElem) = (range(ahan.YLim)*hfrac) * (height ./ maxHeight) ;
        barColor = [barColor ; color] ;
        
        % move the counter to the last slice and loop
        count = LastSlice ;
        
      end
      
      % truncate the data vectors
      if (nElem == 0)
        warning('Lucretia:AddMagnetPlot:nomags','No magnets to plot') ;
        return
      end
      barX = barX(1:nElem) ;
      barWidth = barWidth(1:nElem) - barX ;
      barHeight = barHeight(1:nElem) ;
      
      % plot the magnet schematic
      hold(ahan,'on');
      xax=ahan.XLim;
      yax=ahan.YLim;
      y0 = ahan.YLim(2) + max(barHeight)/2 ;
      rectangle('Position',[ahan.XLim(1) , y0-max(barHeight)/2 , range(ahan.XLim) , max(barHeight)],'FaceColor','white','Parent',ahan,'LineStyle','none');
      line(ahan,ahan.XLim,[y0 y0]-max(barHeight)/2,'Color','black','LineWidth',1);
      line(ahan,ahan.XLim,[y0  y0],'Color','black');
      for count = 1:nElem
        x = barX(count)  ;
        w = barWidth(count) ;
        switch barPolarity(count)
          case 0
            y = -barHeight(count)/2 ; h = barHeight(count) ;
          case 1
            y = 0 ; h = barHeight(count)/2 ;
          case -1
            y = -barHeight(count)/2 ; h = barHeight(count)/2 ;
        end
        color = barColor(count) ;
        rectangle('Position',[x,y0+y,w,h],'FaceColor',color,'Parent',ahan) ;
      end
      hold(ahan,'off');
      ahan.YLim=yax; ahan.YLim(2)=y0+max(barHeight)/2 ;
      ahan.XLim=xax;
    end
    function LogMessage(src,mess)
      %LOGMESSAGE Write message using java message logger
      %LogMessage(AppSource,Message)
      % e.g. LogMessage('F2_Feedback','Something went wrong')
      ml = edu.stanford.slac.logapi.MessageLogAPI.getInstance(char(src));
      ml.log(char(mess));
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

