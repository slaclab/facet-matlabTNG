classdef F2GunDiagnostics
  %F2GUNDIAGNOSTICS - Intepret diagnostic data taken from FACET-II RF Gun
  
  properties
    GunEnergyLookupData % raw data for gun energy lookup
    verbose=2; % 0: no output 1: text only 2: text + graphics
    axhan % axis handle for plots (UIAxes for app or empty to generate standalone figure window)
    dfh % secondary figure handle for duplicate plotting
  end
  
  methods
    
    function obj=F2GunDiagnostics(Ecal_datafile)
      %FD=F2GUNDIAGNOSTICS(datafile)
      % datafile contents: 
      %  sc : GunEnergyLookupData generated with solcal
      
      % Load data files
      if exist('Ecal_datafile','var') && exist(Ecal_datafile,'file') || exist(sprintf('%s.mat',Ecal_datafile),'file')
        ld=load(Ecal_datafile);
        dat.SolI = ld.solcur ;
        dat.table = ld.dat_xcor ;
        dat.table_y = ld.dat_ycor ;
        obj.GunEnergyLookupData = dat ;
        if obj.verbose>0
          disp('Loaded GunEnergyLookupData');
        end
      else
        warning('No calibration data loaded');
      end
      
    end
    
    function Ecalplot(obj,solI)
      %ECALPLOT Display calibration curve for give solenoid strength
      %Ecalplot(solI)
      % plot r vs. theta vs. energy for solenoid current solI (A)
      
      % Get pre-computed lookup tables of r vs. th vs. energy for different solenoid settings
      dat=obj.GunEnergyLookupData;
      
      % Get the nearest lookup table for this solenoid setting and pull out required data
      isol=interp1(dat.SolI,1:length(dat.SolI),solI,'nearest');
      R=dat.table{isol}.r(:);
      TH=abs(dat.table{isol}.th(:));
      E=dat.table{isol}.E(:);
      X=[R TH E];
      
      % New or existing figure
      if isempty(obj.axhan)
        figure;
        ah=axes;
      else
        cla(obj.axhan)
        ah=obj.axhan;
      end
      
      % Draw E vs. r vs. th curve
      if ~isempty(obj.dfh) && ishandle(obj.dfh)
        nhan=2;
      else
        nhan=1;
      end
      for ihan=1:nhan
        if ihan==2
          ah=axes(obj.dfh); %#ok<LAXES>
        end
        plot3(ah,X(:,1).*1e3,X(:,2),X(:,3)); grid(ah,'on');
        xlabel(ah,'R/I [mm/A]');ylabel(ah,'\theta [deg]');zlabel(ah,'E_{gun} [MeV]');
      end
      
    end
    
    function [Efit1,Efit2,Efit3] = Ecalc(obj,dx,dy,dcorI,solI,dir,emin,emax)
      %ECALC Calculate gun energy based on x and y screen position changes for given corrector strength change and solenoid strength
      %[Efit1,Efit2,Efit3] = Ecalc(dx,dy,dcorI,solI,dir [,emin,emax])
      % dx / dy [mm]:   Change in horizontal and vertical beam position on PR10241
      % dcorI [A]: Change in Gun corrector current used (XC10121 or YC10122)
      % solI [A]: Solenoid current used
      % dir: 'x' for XC10121 and 'y' for YC10122
      % emin (optional): lower bound on energy to fit
      % emax (optional): upper bound on energy to fit
      %
      % Efit1 [MeV]: Gun energy using closest fit to calibration curve using both "R" and "Theta" data
      % Efit2 [MeV]: Gun energy using fit biased by "R" data
      % Efit3 [MeV]: Gun energy using fit biased by "Theta" data
      
      % check inputs
      if (nargin~=6 && nargin~=8) || ~isnumeric(dx) || ~isnumeric(dy) || ~isnumeric(dcorI) || (dir~='x' && dir~='y')
        error('Incorrect input format')
      end
      
      % Get r and th- the vector length and angle from the provided screen data
      r=sqrt(dx^2+dy^2);
      th=abs(atand(dy/dx));
      
      % Normalize vector length to 1A corrector current assuming linear relationship
      r=r/abs(dcorI);
      
      % Get pre-computed lookup tables of r vs. th vs. energy for different solenoid settings
      if isempty(obj.GunEnergyLookupData)
        error('Gun energy lookup table data not loaded')
      end
      table_solI = obj.GunEnergyLookupData.SolI;
      if dir=='y'
        dattable=obj.GunEnergyLookupData.table_y;
      elseif dir=='x'
        dattable=obj.GunEnergyLookupData.table;
      end
      
      % Get the nearest lookup table for this solenoid setting and pull out required data
      isol=interp1(table_solI,1:length(table_solI),solI,'nearest');
      R=dattable{isol}.r(:).*1e3;
      TH=abs(dattable{isol}.th(:));
      E=dattable{isol}.E(:);
      
      % Check data within range of lookup tables
      if th<min(TH(:)) || th>max(TH(:))
        error('Data (Theta) outside range of lookup table')
      end
      if r<min(R(:)) || r>max(R(:))
        error('Data (R) outside range of lookup table')
      end
      if solI<min(table_solI) || solI>max(table_solI)
        error('Data (solenoid current) outside range of lookup table')
      end
      
      % Find energy which when combined with given r and th lies closest to lookup curve of r vs th vs E
      X=[R TH E];
      % scale R and TH values for 2-d closest search
      Xs=X;
      ranR=range(X(:,1)); ranTH=range(X(:,2));
      Xs(:,1)=Xs(:,1)./ranR;
      Xs(:,2)=Xs(:,2)./ranTH;
      if exist('emin','var')
        Efit1=fminbnd(@(x) obj.enersearch1(x,Xs,delaunayn(Xs),r/ranR,th/ranTH),emin,emax);
      else
        Efit1=fminbnd(@(x) obj.enersearch1(x,Xs,delaunayn(Xs),r/ranR,th/ranTH),min(E),max(E));
      end
      k=dsearchn(Xs,delaunayn(Xs),[r/ranR,th/ranTH,Efit1]); % closest point on curve index to fitted energy
      
      % Find closest match based just on r
      kfit=fminsearch(@(x) obj.enersearch2(x,R,r),k);
      rfit(1)=interp1(R,kfit); thfit(1)=interp1(TH,kfit);
      Efit2=interp1(E,kfit);
      
      % Find closest match based just on th
      kfit=fminsearch(@(x) obj.enersearch2(x,TH,th),k);
      rfit(2)=interp1(R,kfit); thfit(2)=interp1(TH,kfit);
      Efit3=interp1(E,kfit);
      
      % Print results
      if obj.verbose==1
        fprintf('Gun Energy (best fit) = %g MeV\n',Efit1)
        fprintf('Gun Energy (best fit based on r data): %g MeV\n',Efit2)
        fprintf('Gun Energy (best fit based on th data): %g MeV\n',Efit3)
      end
      
      % Visualize results
      if obj.verbose>1
        if isempty(obj.axhan)
          figure;
          ah=axes;
        else
          cla(obj.axhan)
          ah=obj.axhan;
        end
        if ~isempty(obj.dfh) && ishandle(obj.dfh)
          nhan=2;
        else
          nhan=1;
        end
        for ihan=1:nhan
          if ihan==2
            ah=axes(obj.dfh); %#ok<LAXES>
          end
          % Draw E vs. r vs. th curve
          plot3(ah,X(:,1),X(:,2),X(:,3)); hold(ah,'on'); grid(ah,'on');
          xlabel(ah,'R/I [mm/A]');ylabel(ah,'\theta [deg]');zlabel(ah,'E_{gun} [MeV]');
          % Show fitted r, th, Energy point
          plot3(ah,r,th,Efit1,'rx','MarkerSize',8)
          % Show closest point on curve to provided r, th data and fitted energy
          plot3(ah,X(k,1),X(k,2),X(k,3),'ro','MarkerSize',4);
          % Show line between fitted point and curve
          line(ah,[r X(k,1)],[th X(k,2)],[Efit1 X(k,3)],'Color','r','LineStyle','--');
          % Show best fit using just r or just th
          plot3(ah,rfit(1),thfit(1),Efit2,'k^')
          plot3(ah,rfit(2),thfit(2),Efit3,'kd')
          hold(ah,'off');
          legend(ah,{'Lookup Curve' 'Data' 'Closest Point on Curve' 'DCA' 'R Fit' '\theta Fit'});
        end
      end
      
    end
    
  end
  
  % fitting functions
  methods(Static,Hidden)
    function dx = enersearch1(x,X,T,r,th)
      k=dsearchn(X,T,[r,th,x]);
      dx=norm(X(k,:)-[r,th,x]);
    end
    function dr = enersearch2(x,rq,r)
      dr=(r-interp1(rq,x))^2;
    end
  end
  
end

