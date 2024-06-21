classdef AppSupportTemplate < handle
    % This file is a template for the MATLAB GUI tutorial.
    % Fill in the script to create an App that plots Process Variables
    % from EPICS.
    
    events
        PVUpdated
    end
    
    properties
        guihan
        plotOptionState
        componentParams
        inFile
        data
        beamOut
        LucBeamOut

    end
    
    properties (Hidden)
        listeners
    end
    
    properties (Constant)
         mE_SI = 9.1094e-31;
         c0_SI = 299792458;
         qE_SI = 1.6022e-19;
    end
    
    methods
        % This section contains functions that are needed to run the app
        
        function obj = AppSupportTemplate(apphandle)
            
            obj.inFile = nan;
            obj.beamOut = nan;
            obj.LucBeamOut = nan;

            obj.guihan = apphandle;
            obj.componentParams = zeros(6,3);
                      
        end
       
   
        % function plotVals(obj, graphnum)
        % 
        %     switch graphnum
        %         case 'Graph1'
        %             plot(obj.guihan.UIAxes,obj.data.Vals1,obj.data.Vals1,'b')
        %             drawnow
        %         case 'Graph2'
        % 
        %             plot(obj.guihan.UIAxes,obj.data.Vals1,obj.data.Vals2,'b')
        %             drawnow
        %    end
        % end

        function processFile(obj)
            dLengths = obj.componentParams(:,1);
            quadLengths = obj.componentParams(:,2);
            quadStrengths = obj.componentParams(:,3);

            if (~isnan(obj.inFile))
                beamLuc = load(obj.inFile);

                beam = struct();

                beam.y = beamLuc.Bunch.x(1,:);
                beam.thty  = beamLuc.Bunch.x(2,:);

                beam.x = beamLuc.Bunch.x(3,:);
                beam.thtx  = beamLuc.Bunch.x(4,:);

                beam.z = -beamLuc.Bunch.x(5,:);
                
                E = beamLuc.Bunch.x(6,:);

                beam.gamma = E*1000/0.511;
                obj.data.gamma = beam.gamma;

                beam.charge = beamLuc.Bunch.Q;

                beam.Pz = beam.gamma*obj.c0_SI*obj.mE_SI;

                N = length(beam.x);
                
                obj.data.xA = [beam.x; zeros(12, N)];
                obj.data.yA = [beam.y; zeros(12, N)];
                obj.data.zA = [beam.z; zeros(12, N)];

                obj.data.sigxA = [std(beam.x); zeros(12,1)];
                obj.data.sigyA = [std(beam.y); zeros(12,1)];
                obj.data.sigzA = [std(beam.z); zeros(12,1)];

                obj.data.thtxA = [beam.thtx; zeros(12, N)];
                obj.data.thtyA = [beam.thty; zeros(12, N)];

                start_z = mean(beam.z);

                total_length = start_z;
                obj.data.lengths = [start_z; zeros(12,1)];

                for ii = 1:6
                    qLength = quadLengths(ii);
                    
                    beam = quadrupole(beam, quadStrengths(ii), qLength);
                    obj.data.xA(2*ii,:) = beam.x;
                    obj.data.yA(2*ii,:) = beam.y;
                    obj.data.zA(2*ii,:) = beam.z;

                    obj.data.thtxA(2*ii,:) = beam.thtx;
                    obj.data.thtyA(2*ii,:) = beam.thty;

                    obj.data.sigxA(2*ii) = std(beam.x);
                    obj.data.sigyA(2*ii) = std(beam.y);

                    total_length = total_length + qLength;
                    obj.data.lengths(2*ii) = total_length;

                    dlength = dLengths(ii);
                    beam = driftSpace(beam, dlength);

                    obj.data.xA(2*ii+1,:) = beam.x;
                    obj.data.yA(2*ii+1,:) = beam.y;
                    obj.data.zA(2*ii+1,:) = beam.z;

                    obj.data.thtxA(2*ii+1,:) = beam.thtx;
                    obj.data.thtyA(2*ii+1,:) = beam.thty;

                    obj.data.sigxA(2*ii+1) = std(beam.x);
                    obj.data.sigyA(2*ii+1) = std(beam.y);

                    total_length = total_length + dlength;
                    obj.data.lengths(2*ii+1) = total_length;
                end

                obj.beamOut = beam;

                obj.LucBeamOut = beamLuc;

                obj.LucBeamOut.Bunch.x(1,:) = beam.y;
                obj.LucBeamOut.Bunch.x(2,:) = beam.thty;

                obj.LucBeamOut.Bunch.x(3,:) = beam.x;
                obj.LucBeamOut.Bunch.x(4,:) = beam.thty;

                obj.LucBeamOut.Bunch.x(5,:) = -beam.z;



                % plot(obj.guihan.UIAxes,lengths,sigxA,'b-o')
                % hold on
                % plot(obj.guihan.UIAxes,lengths,sigyA,'r-o')
                % 
                % xlabel('z [m]')
                % ylabel('/sigma')
                % legend('x', 'y')
                % 
                % drawnow

            else
                disp('No File Selected')
            end
        end

        function Out2FBPIC(obj, dirOut, fileOut)


            uz = (obj.beamOut.gamma.^2 - 1) - obj.beamOut.thtx.^2 - obj.beamOut.thty.^2;


            outMatrix = [obj.beamOut.x; obj.beamOut.y; obj.beamOut.z; obj.beamOut.thtx; obj.beamOut.thty; uz]';

            disp(size(outMatrix))

            writematrix(outMatrix, [dirOut, fileOut], 'Delimiter', ' ')

        end



        function Out2QuickPIC(obj,dirOut,fileOut)
            %  function TFF2QP(BeamIn,fileOutput)
            % BeamIn = input struct
            % fileOutput = complete directory+filename to which the QuickPIC output
            % is saved to.
            %  --- set SI costants ---

            %  --- set non-SI constants ---
            n0 = 1.e16; %/cm^3  ATTENTION:   Plasma density set here NEEDS to be the same set in the simulation input.
            % Otherwise the QuickPIC simulation scales wrong
            e0 = 0.511 * 1e-3 ; %GeV
            m =  9.1095e-28; %g
            c = 2.9979e10; %cm/s
            e = 4.8032e-10 ; %esu
            wp0 = sqrt(4 * pi * n0 * e^2/m);
            kpinv = c/wp0 * 1e-2 %m
            %     --------------------------

            x1 = obj.beamOut.y;
            x2 = obj.beamOut.x
            x3 = -obj.beamOut.z;  % QuickPIC convetion: Head of beam is at minimum z.

            p1 = tan(obj.beamOut.thty).* obj.beamOut.gamma;
            p2 = tan(obj.beamOut.thtx).* obj.beamOut.gamma;
            p3 = obj.beamOut.gamma; % This is gamma_z , not overall gamma.

            q = obj.beamOut.charge; % This is in C​

            normq = n0 * (kpinv * 1e2)^3 *  qE_SI;   %C
            x3 = x(5,:) / kpinv;
            x1 = x(1,:) / kpinv;
            x2 = x(3,:) / kpinv;
            p3 = x(6,:) / e0;
            l_array = x3>-4 & x3 < 3.5 & x1 > - 6 & x1 < 6 & x2 > - 6 & x2 < 6 & p3 > 1000 & beam.Bunch.stop <1;
            x1 = x1(l_array);
            x2 = x2(l_array);
            x3 = x3(l_array);


            p3 = x(6,l_array) / e0;
            q = q(l_array);
            p1 = x(2,l_array) .* p3;
            p2 = x(4,l_array) .* p3;

            x1 = x1 - mean(x1);
            x2 = x2 - mean(x2);
            x3 = x3 - min(x3);
            sum(q)
            sum(q(x3>5))
            q = -1 * q / normq;

            emit_est = std(x1 * kpinv) * std(p1)

            n = length(x1);
            step = 1000;
            num = int32(n/step);
            q_slice = zeros(num,1);
            x3_slice = linspace(min(x3),max(x3),num);
            for i = 1:num - 1
                q_slice(i) = sum(q(x3 >= x3_slice(i) & x3 < x3_slice(i+1)));
            end
            plot(x3_slice, q_slice)

            l_beam1 = x3 < 5.0;
            l_beam2 = x3 >= 5.0;

            x1_beam1 = x1(l_beam1);
            x2_beam1 = x2(l_beam1);
            x3_beam1 = x3(l_beam1);
            p1_beam1 = p1(l_beam1);
            p2_beam1 = p2(l_beam1);
            p3_beam1 = p3(l_beam1);
            q_beam1 = q(l_beam1);
            p_beam1 = sqrt(p1_beam1.^2 + p2_beam1.^2 + p3_beam1.^2);

            x1_beam2 = x1(l_beam2);
            x2_beam2 = x2(l_beam2);
            x3_beam2 = x3(l_beam2);
            p1_beam2 = p1(l_beam2);
            p2_beam2 = p2(l_beam2);
            p3_beam2 = p3(l_beam2);
            q_beam2 = q(l_beam2);
            p_beam2 = sqrt(p1_beam2.^2 + p2_beam2.^2 + p3_beam2.^2);

            spread1 = sqrt(sum(q_beam1 .* (p_beam1 - mean(p_beam1)).^2) / sum(q_beam1));
            spread2 = sqrt(sum(q_beam2 .* (p_beam2 - mean(p_beam2)).^2) / sum(q_beam2));
            %Path to the HDF5 file
            file_path = [dirOut,fileOut];

            %Write the data to the HDF5 file
            hdf5write(file_path, '/x1', x1_beam1);
            hdf5write(file_path, '/x2', x2_beam1, 'WriteMode', 'append');
            hdf5write(file_path, '/x3', x3_beam1, 'WriteMode', 'append');
            hdf5write(file_path, '/p1', p1_beam1, 'WriteMode', 'append');
            hdf5write(file_path, '/p2', p2_beam1, 'WriteMode', 'append');
            hdf5write(file_path, '/p3', p3_beam1, 'WriteMode', 'append');
            hdf5write(file_path, '/q', q_beam1, 'WriteMode', 'append');
        end

        function Out2HiPace(obj, DirOut,DatasetNameOut,varargin)
            % This function writes lucretia output into hipace dumps
            % function HIPACEPP_Lucretia2Hipace(folderIn,dataset,folderOut,datasetnameOut,Species,Time)
            % DirIn             = Directory of input file
            % DatasetName       = .mat file of lucretia beam dist.
            % DirOut            = Write to this directory
            % DatasetNameOut    = HiPace dump name e.g. openpmd_000000.h5
            % Species,Time      : optional input
            % varargin          =   varargin{1} = Species (standard: 'bunch')
            %                       varargin{2} = Time (standard: Time=0) ​
            %  --- Define SI constants
            mE=9.109383701e-31;
            c0=299792458;
            qE=1.602176634e-19;
            % --- Check for additional input
            nargin
            switch nargin
                case 3
                    Species='bunch';
                    Time=0;
                case 4
                    Species=varargin{1};
                    Time=0;
                case 5
                    Species=varargin{1};
                    Time=varargin{2};
                otherwise
                    Species=varargin{1};
                    Time=varargin{2};
            end

            if ismac
                if DirOut(end)~='/'
                    DirOut=[DirOut,'/'];
                end
            end
            if isunix
                if DirOut(end)~='/'
                    DirOut=[DirOut,'/'];
                end
            end
            if ispc
                if DirOut(end)~='\'
                    DirOut=[DirOut,'\'];
                end
            end
            
            % BeamIn=load([DirIn,DatasetName]); % load lucretia output
            % [a,isort]=find(BeamIn.beam.Bunch.stop==0); % I assume that the lucretia output structure is always like this. If not: Add conditions here.
            % BeamHipace.weight=BeamIn.beam.Bunch.Q(isort)/qE; % only use particles that weren't clipped.

            BeamHipace.weight=obj.beamOut.charge/qE;

            %y=BeamIn.beam.Bunch.x(1,:);
            %BeamHipace.y=y(isort);

            BeamHipace.y=obj.beamOut.y;
            Thetay=obj.beamOut.thty;
            
            BeamHipace.x=obj.beamOut.x;
            Thetax=obj.beamOut.thtx;         
            
            BeamHipace.z=obj.beamOut.z;
            Gamma=obj.beamOut.gamma;
            BeamHipace.pz=Gamma*c0;

            BeamHipace.px=tan(Thetax).*BeamHipace.pz;
            BeamHipace.py=tan(Thetay).*BeamHipace.pz;

            BeamHipace.Time=Time;

            NumberOfParticles=(length(obj.beamOut.x));
            BeamHipace.id=uint64([1:NumberOfParticles]+10000);  % HiPACE id needs to be at least 5 figures appearantly
            % ​
            srcOut=[DirOut,DatasetNameOut];

            if isfile([DirOut,DatasetNameOut])
                error('Output file cannot be overwritten. Delete output file and retry or use different path/filename.')
            end

            fid = H5F.create(srcOut);
            plist = 'H5P_DEFAULT';
            gid = H5G.create(fid,'/data/',plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,'/data/0',plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,'/data/0/particles',plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/charge'],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/mass'],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/momentum'],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/position'],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/positionOffset'],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/positionOffset/x'],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/positionOffset/y'],plist,plist,plist);
            H5G.close(gid);

            gid = H5G.create(fid,['/data/0/particles/',Species,'/positionOffset/z'],plist,plist,plist);
            H5G.close(gid);


            H5F.close(fid);

            h5create(srcOut,['/data/0/particles/',Species,'/id'],NumberOfParticles,'Datatype','uint64')

            h5create(srcOut,['/data/0/particles/',Species,'/weighting'],[NumberOfParticles],'Datatype','double')
            h5create(srcOut,['/data/0/particles/',Species,'/momentum/x'],[NumberOfParticles],'Datatype','double')
            h5create(srcOut,['/data/0/particles/',Species,'/momentum/y'],[NumberOfParticles],'Datatype','double')
            h5create(srcOut,['/data/0/particles/',Species,'/momentum/z'],[NumberOfParticles],'Datatype','double')

            h5create(srcOut,['/data/0/particles/',Species,'/position/x'],[NumberOfParticles],'Datatype','double')
            h5create(srcOut,['/data/0/particles/',Species,'/position/y'],[NumberOfParticles],'Datatype','double')
            h5create(srcOut,['/data/0/particles/',Species,'/position/z'],[NumberOfParticles],'Datatype','double')


            h5write(srcOut,['/data/0/particles/',Species,'/weighting'],BeamHipace.weight);
            h5write(srcOut,['/data/0/particles/',Species,'/momentum/x'],BeamHipace.px);
            h5write(srcOut,['/data/0/particles/',Species,'/momentum/y'],BeamHipace.py);
            h5write(srcOut,['/data/0/particles/',Species,'/momentum/z'],BeamHipace.pz);

            h5write(srcOut,['/data/0/particles/',Species,'/position/x'],BeamHipace.x);
            h5write(srcOut,['/data/0/particles/',Species,'/position/y'],BeamHipace.y);
            h5write(srcOut,['/data/0/particles/',Species,'/position/z'],BeamHipace.z);

            h5write(srcOut,['/data/0/particles/',Species,'/id'],BeamHipace.id);


            h5writeatt(srcOut,'/','basePath','/data/%T/');
            h5writeatt(srcOut,'/','date','2023-01-18 11:59:45 +0100');
            h5writeatt(srcOut,'/','iterationEncoding','fileBased');
            h5writeatt(srcOut,'/','iterationFormat','meshes/');
            h5writeatt(srcOut,'/','meshesPath','/data/%T/');
            h5writeatt(srcOut,'/','openPMD','1.1.0');
            h5writeatt(srcOut,'/','openPMDextension',uint32(0));
            h5writeatt(srcOut,'/','particlesPath','particles/');
            h5writeatt(srcOut,'/','software','openPMD-api');
            h5writeatt(srcOut,'/','softwareVersion','0.15.0-dev');


            h5writeatt(srcOut,'/data/0/','dt',1);
            h5writeatt(srcOut,'/data/0/','time',BeamHipace.Time);
            h5writeatt(srcOut,'/data/0/','timeUnitSI',BeamHipace.Time);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/'],'HiPACE_use_reference_unitSI',int8(1));

            h5writeatt(srcOut,['/data/0/particles/',Species,'/charge'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/charge'],'shape',uint64(NumberOfParticles));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/charge'],'timeOffset',single(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/charge'],'unitDimension',[0,0,1,1,0,0,0]);
            h5writeatt(srcOut,['/data/0/particles/',Species,'/charge'],'unitSI',1);
            h5writeatt(srcOut,['/data/0/particles/',Species,'/charge'],'value',-1.602176634e-19);


            h5writeatt(srcOut,['/data/0/particles/',Species,'/id'],'timeOffset',single(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/id'],'unitDimension',[0,0,0,0,0,0,0]);
            h5writeatt(srcOut,['/data/0/particles/',Species,'/id'],'unitSI',1);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/mass'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/mass'],'shape',uint64(NumberOfParticles));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/mass'],'timeOffset',single(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/mass'],'unitDimension',[0,1,0,0,0,0,0]);
            h5writeatt(srcOut,['/data/0/particles/',Species,'/mass'],'unitSI',1);
            h5writeatt(srcOut,['/data/0/particles/',Species,'/mass'],'value',9.109383701e-31);


            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum'],'macroWeighted',uint32(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum'],'timeOffset',single(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum'],'unitDimension',[1,1,-1,0,0,0,0]);
            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum'],'weightingPower',1);


            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum/x'],'HiPACE++_reference_unitSI',9.109383701e-31)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum/x'],'unitSI',9.109383701e-31);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum/y'],'HiPACE++_reference_unitSI',9.109383701e-31)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum/y'],'unitSI',9.109383701e-31);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum/z'],'HiPACE++_reference_unitSI',9.109383701e-31)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/momentum/z'],'unitSI',9.109383701e-31);


            h5writeatt(srcOut,['/data/0/particles/',Species,'/position'],'timeOffset',single(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/position'],'unitDimension',[1,0,0,0,0,0,0]);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/position/x'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/position/x'],'unitSI',1);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/position/y'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/position/y'],'unitSI',1);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/position/z'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/position/z'],'unitSI',1);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset'],'timeOffset',single(0))
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset'],'unitDimension',[1,0,0,0,0,0,0]);

            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/x'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/x'],'shape',uint64(NumberOfParticles))
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/x'],'unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/x'],'value',0)

            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/y'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/y'],'shape',uint64(NumberOfParticles))
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/y'],'unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/y'],'value',0)

            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/z'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/z'],'shape',uint64(NumberOfParticles))
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/z'],'unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/positionOffset/z'],'value',0)

            h5writeatt(srcOut,['/data/0/particles/',Species,'/weighting'],'HiPACE++_reference_unitSI',1)
            h5writeatt(srcOut,['/data/0/particles/',Species,'/weighting'],'macroWeighted',uint32(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/weighting'],'timeOffset',single(0));
            h5writeatt(srcOut,['/data/0/particles/',Species,'/weighting'],'unitDimension',[0,0,0,0,0,0,0]);
            h5writeatt(srcOut,['/data/0/particles/',Species,'/weighting'],'unitSI',1); 
            h5writeatt(srcOut,['/data/0/particles/',Species,'/weighting'],'weightingPower',0);
            
            if isfile([DirOut,DatasetNameOut])
                ['Output successfully written to:  ',srcOut]
            end
        end


    end
end

function beamOut = driftSpace(beamIn, length)

            xOut = beamIn.x + beamIn.thtx*length;
            yOut = beamIn.y + beamIn.thty*length;
            zOut = beamIn.z + length;

            beamOut = beamInit(xOut, yOut, zOut, beamIn.thtx, beamIn.thty, beamIn.Pz, beamIn.gamma, beamIn.charge);
end

function beamOut = quadrupole(beamIn, dBydx, length)

            qE_SI = 1.6022e-19;
            
            zOut = beamIn.z + length;

            k = qE_SI*dBydx./beamIn.Pz;

            xOut = beamIn.x.*cos(sqrt(k).*length) + beamIn.thtx./sqrt(k).*sin(sqrt(k).*length);
            thtxOut = beamIn.x.*-sqrt(k).*sin(sqrt(k).*length)+beamIn.thtx.*cos(sqrt(k).*length);

            yOut = beamIn.y.*cosh(sqrt(k).*length) + beamIn.thty./sqrt(k).*sinh(sqrt(k).*length);
            thtyOut = beamIn.y.*sqrt(k).*sinh(sqrt(k).*length)+beamIn.thty.*cosh(sqrt(k).*length);

            beamOut = beamInit(xOut, yOut, zOut, thtxOut, thtyOut, beamIn.Pz, beamIn.gamma, beamIn.charge);
end