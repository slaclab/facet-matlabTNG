classdef F2_ProfMeas < handle
  %F2_PROFMEAS FACET-II Profile monitor measurement tools
  properties
    MeasMethod string = ["RMS" "Gaussian" "AGaussian"] % Measurement methods to include in Stats (some or all of "RMS", "Gaussian", "AGaussian")
    StoreImages logical = false % Store all images in Acquire method (else just store Stats)
  end
  properties(SetObservable)
    Device string {mustBeMember(Device,["PR10571" "PR10711" "PR11335" "PR11375" "PR14803" "PR15944" "PMON" "SYAG" "USTHz" "USOTR" "IPOTR1" "IPOTR1P" "IPOTR2" "DSOTR" "WDSOTR" "PRDMP"])} = "PR10571" % Device of interest
  end
  properties(SetAccess=private)
    Bkg % Stored background image
    Img cell % Profile image storeage
    Img_x % Img x-axis
    Img_y % Img y-axis
    Stats % Statistics derived from image acquisition
  end
  methods
    function obj = F2_ProfMeas(DeviceName)
      %F2_PROFMEAS
      %
      %PM = F2_ProfMeas(DeviceName)
      %
      if exist('DeviceName','var')
        obj.Device=DeviceName;
      end
    end
    function AcquireBkg(obj,nshot)
      %ACQUIREBKG Take backgound image with Laser MPS shutter inserted
      %
      %AcquireBkg([nshot])
      % Use average of nshot images (default=1)
      %
      %AcquireBkg(0)
      % Remove BKG image and don't use bkg subtraction in Acquire method
      if ~exist('nshot','var')
        nshot=1;
      elseif nshot==0
        obj.Bkg=[];
        return
      end
      for ishot=1:nshot
        data=profmon_grabBG(obj.Device);
        if ishot==1
          img=double(data.img);
        else
          img=img+double(data.img);
        end
      end
      obj.Bkg=img./nshot;
      sz=size(img);
      obj.Img_x = (0:sz(1)-1).*data.res.*1e-6 ;
      obj.Img_y = (0:sz(2)-1).*data.res.*1e-6 ;
    end
    function img = Acquire(obj,nshot)
      %ACQUIRE Acquire nshot images
      %
      %Acquire([nshot])
      % Use average of nshot images (default=1)
      % If Bkg property not empty, then subtract Bkg from each image acquisition
      if ~exist('nshot','var')
        nshot=1;
      end
      obj.Stats=[];
      obj.Img={};
      if obj.StoreImages && nshot>1
        obj.Img=cell(1,nshot);
      end
      for ishot=1:nshot
        data=profmon_grab(obj.Device);
        img = double(data.img) ;
        if ~isempty(obj.Bkg)
          if ~isequal(size(obj.Bkg),size(img))
            error('Mismatch between background and current image dimensions');
          end
          img=img-obj.Bkg;
          img(img<0)=0;
        end
        if ishot==1
          sz=size(img);
          obj.Img_x = (0:sz(1)-1).*data.res.*1e-6 ;
          obj.Img_y = (0:sz(2)-1).*data.res.*1e-6 ;
        end
        if obj.StoreImages % Just store all images
          obj.Img{ishot}=img;
        else % Store stats as we go
          obj.ImageStats(img);
        end
      end
    end
    function ImageStats(obj,img)
      %IMAGESTATS Get statistics on provided image, or store Image(s)
      if ~exist('img','var') % If no provided image then loop over store Images
        if isempty(obj.Img)
          error('No provided or store Image data');
        end
        for i_img=1:length(obj.Img)
          obj.ImageStats(obj.Img{i_img});
        end
      end
      istat=length(obj.Stats)+1;
      xw=sum(img,2); yw=sum(img); % lineout weights (x and y frequencies)
      obj.Stats(istat).Wx = xw ;
      obj.Stats(istat).Wy = yw ;
      if ismember("RMS",obj.MeasMethod)
        obj.Stats(istat).mean_x = sum(xw.*obj.Img_x)/sum(xw) ;
        obj.Stats(istat).mean_y = sum(yw.*obj.Img_y)/sum(yw) ;
        obj.Stats(istat).rms_x = sqrt(var(obj.Img_x,xw)) ;
        obj.Stats(istat).rms_y = sqrt(var(obj.Img_y,yw)) ;
      end
      if ismember("Gaussian",obj.MeasMethod)
        [yfit,q,dq,chisq_ndf] = gauss_fit(obj.Img_x,xw) ;
        obj.Stats(istat).Gauss.xdat = yfit ;
        obj.Stats(istat).Gauss.x_q = q ;
        obj.Stats(istat).Gauss.x_dq = dq ;
        obj.Stats(istat).Gauss.x_chisq_ndf = chisq_ndf ;
        [yfit,q,dq,chisq_ndf] = gauss_fit(obj.Img_y,yw) ;
        obj.Stats(istat).Gauss.ydat = yfit ;
        obj.Stats(istat).Gauss.y_q = q ;
        obj.Stats(istat).Gauss.y_dq = dq ;
        obj.Stats(istat).Gauss.y_chisq_ndf = chisq_ndf ;
      end
      if ismember("AGaussian",obj.MeasMethod)
        [yfit,q,dq,chisq_ndf] = agauss_fit(obj.Img_x,xw) ;
        obj.Stats(istat).AGauss.xdat = yfit ;
        obj.Stats(istat).AGauss.x_q = q ;
        obj.Stats(istat).AGauss.x_dq = dq ;
        obj.Stats(istat).AGauss.x_chisq_ndf = chisq_ndf ;
        [yfit,q,dq,chisq_ndf] = agauss_fit(obj.Img_y,yw) ;
        obj.Stats(istat).AGauss.ydat = yfit ;
        obj.Stats(istat).AGauss.y_q = q ;
        obj.Stats(istat).AGauss.y_dq = dq ;
        obj.Stats(istat).AGauss.y_chisq_ndf = chisq_ndf ;
      end
    end
    function PlotImg(obj,img,ahan)
      %PLOTIMG Plot acquired image and lineout
      %
      %PlotImg([img,ahan])
      % img: image ID or raw image (default=1)
      % ahan: axis handle for plotting (default = new figure window)
      istat=1;
      if ~exist('img','var') || isempty(img)
        img=1;
      end
      if length(img)==1
        if length(obj.Img)>img
          error('Erroneous Img reference');
        end
        istat=img;
        img=obj.Img{img};
      elseif isempty(obj.Stats)
        obj.ImageStats(img);
      end
      if ~exist('ahan','var') || ~ishandle(ahan)
        figure;ahan=axes;
      end
      imagesc(ahan,img); ahan.YDir='normal'; ahan.XAxis.Limits=[obj.Img_x(1) obj.Img_x(end)].*1e6; ahan.YAxis.Limits=[obj.Img_y(1) obj.Img_y(end)].*1e6;
      xlabel(ahan,'X [\mum]'); ylabel(ahan,'Y [\mum]'); colormap(ahan,'turbo');
      hold(ahan,'on');
      xv=obj.Img_x.*1e6;
      yv=ahan.YLim(1) + 0.4*range(ahan.YLim) * (obj.Stats(istat).Wx-min(obj.Stats(istat).Wx))./range(obj.Stats(istat).Wx);
      plot(ahan,xv,yv,'w');
      yv=obj.Img_y.*1e6;
      xv=ahan.XLim(1) + 0.4*range(ahan.XLim) * (obj.Stats(istat).Wy-min(obj.Stats(istat).Wy))./range(obj.Stats(istat).Wy);
      plot(ahan,xv,yv,'w');
      hold(ahan,'off');
    end
    function PlotStats(obj,stats,img,ahan)
      %PLOTSTATS Superimpose Gaussian or Asymmetric Gaussian plot
      %
      %PlotStats(stats [,img,ahan])
      %  stats = "Gaussian" or "AGaussian"
      %  img = raw image or image ID of current plot (default =1 )
      %  ahan = axis handle (default = current axis in detached window)
      istat=1;
      if ~exist('img','var') || isempty(img)
        img=1;
      end
      if length(img)==1
        if length(obj.Img)>img
          error('Erroneous Img reference');
        end
        istat=img;
      elseif isempty(obj.Stats)
        obj.ImageStats(img);
      end
      if ~exist('ahan','var') || ~ishandle(ahan)
        ahan=gca;
      end
      hold(ahan,'on');
      switch string(stats)
        case "Gaussian"
          xv=obj.Img_x.*1e6;
          yv=ahan.YLim(1) + 0.4*range(ahan.YLim) * (obj.Stats(istat).Gauss.xdat-min(obj.Stats(istat).Gauss.xdat))./range(obj.Stats(istat).Gauss.xdat);
          plot(ahan,xv,yv,'r--');
          yv=obj.Img_y.*1e6;
          xv=ahan.XLim(1) + 0.4*range(ahan.XLim) * (obj.Stats(istat).Gauss.ydat-min(obj.Stats(istat).Gauss.ydat))./range(obj.Stats(istat).Gauss.ydat);
          plot(ahan,xv,yv,'r--');
        case "AGaussian"
          xv=obj.Img_x.*1e6;
          yv=ahan.YLim(1) + 0.4*range(ahan.YLim) * (obj.Stats(istat).AGauss.xdat-min(obj.Stats(istat).AGauss.xdat))./range(obj.Stats(istat).AGauss.xdat);
          plot(ahan,xv,yv,'r--');
          yv=obj.Img_y.*1e6;
          xv=ahan.XLim(1) + 0.4*range(ahan.XLim) * (obj.Stats(istat).AGauss.ydat-min(obj.Stats(istat).AGauss.ydat))./range(obj.Stats(istat).AGauss.ydat);
          plot(ahan,xv,yv,'r--');
      end
      hold(ahan,'off');
    end
  end
  methods %set/get methods
    function set.Device(obj,name)
      obj.Device=name;
      % Clear store image and stats data for new device
      obj.Bkg=[];
      obj.Img={};
      obj.Img_x=[];
      obj.Img_y=[];
      obj.Stats=[];
    end
  end
end