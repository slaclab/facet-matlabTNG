classdef MIA_GUI_model < handle
    % Model object for MIA GUI to hold data and state of the app
    
    properties
        BG_mdl % BSA GUI model object holding data and state of originating BSA_GUI
        MIA_GUI % MIA_GUI app object
        X % data for X bpms
        Y % data for Y bpms
        dispersion % dispersion bpm struct
        beamLine % HXR or SXR
    end
    
    methods
        function MIA_mdl = MIA_GUI_model(MIA_GUI, BG_mdl)
            % Object constructor
            MIA_mdl.BG_mdl = BG_mdl;
            MIA_mdl.MIA_GUI = MIA_GUI;
            
            setup_dispersion(MIA_mdl);
            
            bl = {'CUH','CUS'};
            MIA_mdl.beamLine = bl{MIA_mdl.BG_mdl.isSxr + 1};
            
            init_svd(MIA_mdl);
        end
        
        function init_svd(MIA_mdl)
            % identify BPMS and assign their index within the_matrix, a
            % 1:num_bpms array, their names, and their data, and a
            % 1:num_pulses array to the appropriate X and Y structs
            MIA_mdl.X.bpm_idx = find(contains(MIA_mdl.BG_mdl.ROOT_NAME,'BPMS') & endsWith(MIA_mdl.BG_mdl.ROOT_NAME,'X'));
            MIA_mdl.Y.bpm_idx = find(contains(MIA_mdl.BG_mdl.ROOT_NAME,'BPMS') & endsWith(MIA_mdl.BG_mdl.ROOT_NAME,'Y'));
            MIA_mdl.X.bpm_num = 1:length(MIA_mdl.X.bpm_idx);
            MIA_mdl.Y.bpm_num = 1:length(MIA_mdl.Y.bpm_idx);
            MIA_mdl.X.bpm_names = MIA_mdl.BG_mdl.ROOT_NAME(MIA_mdl.X.bpm_idx);
            MIA_mdl.Y.bpm_names = MIA_mdl.BG_mdl.ROOT_NAME(MIA_mdl.Y.bpm_idx);
            MIA_mdl.X.bpm_data = full(MIA_mdl.BG_mdl.the_matrix(MIA_mdl.X.bpm_idx,:));
            MIA_mdl.Y.bpm_data = full(MIA_mdl.BG_mdl.the_matrix(MIA_mdl.Y.bpm_idx,:));
            MIA_mdl.X.pulse_num = 1:size(MIA_mdl.X.bpm_data,2);
            MIA_mdl.Y.pulse_num = MIA_mdl.X.pulse_num;
            
            % time stamp flexibility for different BSA file formats
            if isempty(MIA_mdl.BG_mdl.time_stamps)
                t=MIA_mdl.BG_mdl.t_stamp;
            else
                t=MIA_mdl.BG_mdl.time_stamps;
            end
            
            MIA_mdl.X.time_stamps = t;
            MIA_mdl.Y.time_stamps = t;
            
            MIA_mdl.X.bpm_data(isnan(MIA_mdl.X.bpm_data))=0;
            MIA_mdl.Y.bpm_data(isnan(MIA_mdl.Y.bpm_data))=0;
            
            % perform SVD calculations for X and Y
            B_x = MIA_mdl.X.bpm_data;
            [M_x, P_x] = size(B_x);
            meanB_x = repmat(util_meanNan(B_x,2), 1, P_x);
            BB_x = 1000 * (B_x - meanB_x) / sqrt(P_x);
            [MIA_mdl.X.U,MIA_mdl.X.S,MIA_mdl.X.V] = svd(BB_x');
            MIA_mdl.X.S = sum(MIA_mdl.X.S)./sqrt(length(MIA_mdl.X.bpm_idx));
            
            B_y = MIA_mdl.Y.bpm_data;
            [M_y, P_y] = size(B_y);
            meanB_y = repmat(util_meanNan(B_y,2), 1, P_y);
            BB_y = 1000 * (B_y - meanB_y) / sqrt(P_y);
            [MIA_mdl.Y.U,MIA_mdl.Y.S,MIA_mdl.Y.V] = svd(BB_y');
            MIA_mdl.Y.S = sum(MIA_mdl.Y.S)./sqrt(length(MIA_mdl.Y.bpm_idx));
            
            % Noise floor calculation, this is not currently used and needs
            % more brain power to be implemented
            dSx = find(round(diff(MIA_mdl.X.S))==0);
            MIA_mdl.X.noise_floor = dSx(1);
            dSy = find(round(diff(MIA_mdl.Y.S))==0);
            MIA_mdl.Y.noise_floor = dSy(1);
        end
        
        function reconstruct(MIA_mdl, coor_str, evs)
            coor = MIA_mdl.(coor_str);
            nf = coor.noise_floor;
            U_bar = coor.U(:,evs);
            S_bar = coor.S(evs);
            V_bar = coor.V(:,evs);
            
            MIA_mdl.(coor_str).reconstructed = (U_bar .* S_bar * V_bar' .* sqrt(length(coor.bpm_idx)))';
        end
        
        function setup_dispersion(MIA_mdl)
            % hard code the dispersion bpms
            
            MIA_mdl.dispersion.X.CUH = {'BPMS:IN20:731:X',
                'BPMS:LI21:233:X',
                'BPMS:LI24:801:X',
                'BPMS:LTUH:250:X',
                'BPMS:LTUH:450:X'};
            
            MIA_mdl.dispersion.X.CUS = {'BPMS:IN20:731:X',
                'BPMS:LI21:233:X',
                'BPMS:LI24:801:X',
                'BPMS:LTUS:235:X',
                'BPMS:LTUS:370:X',
                'BPMS:CLTS:420:X',
                'BPMS:CLTS:620:X'};
            
            MIA_mdl.dispersion.Y.CUH = {'BPMS:LTUH:130:Y',
                'BPMS:LTUH:150:Y',
                'BPMS:LTUH:170:Y',
                'BPMS:DMPH:502:Y',
                'BPMS:DMPH:693:Y'};
            
            MIA_mdl.dispersion.Y.CUS = {'BPMS:CLTS:450:Y',
                'BPMS:CLTS:590:Y',
                'BPMS:DMPS:502:Y',
                'BPMS:DMPS:693:Y'};
        end
        
        function id_dispersion(MIA_mdl, coor, evs)
            % in theory, this function would identify which eigenvectors
            % correspond to dispersion
            for ev_idx = 1:length(evs)
                ev = coor.V(:,evs(ev_idx));
                [pks,i] = findpeaks(abs(ev));
                nopeaks = ev; nopeaks(i)=[];
                baseline = mean(nopeaks);
                maxpeak = max(pks-baseline);
                truepeaks = pks > maxpeak * 0.1;
                truepeak_idx = i(truepeaks);
            end
            
        end
        
        function degreesOfFreedomPlot(MIA_mdl, coor, dof)
            
            coor = MIA_mdl.(coor);
            dof_data = [];
            bpm_data = coor.bpm_data;
            [bpms,pulses] = size(bpm_data);
            bpm_mean = repmat(util_meanNan(bpm_data,2),1,pulses);
            bpm_data = (bpm_data - bpm_mean) / sqrt(pulses);
            
            names = coor.bpm_names;
            for i=1:length(names)
                name = names{i};
                names(i) = {name(1:length(name)-2)};
            end
            
            z = model_rMatGet(names,[],{'TYPE=DESIGN',['BEAMPATH=CU_', MIA_mdl.beamLine(3), 'XR']},'Z');
            [z, ~] = sort(z);
            
            % for each bpm, calculate the SVD for 1 up to that number of
            % bpm. record the singular values
            for bpm = 1:length(coor.bpm_idx)
                [u,s,v] = svd(bpm_data(1:bpm,:)');
                s = diag(s)';
                if length(s) < dof
                    s = [s zeros(1,dof-length(s))];
                end
                dof_data = [dof_data;s(1:dof)];
                clear u s v
            end
            
            figure
            plot_menus_BSA(MIA_mdl.BG_mdl.app)
            for d=1:dof
                p = plot(z,dof_data(:,d));
                dt = p.DataTipTemplate;
                dt.DataTipRows(1).Value = coor.bpm_names;
                dt.DataTipRows(1).Label = '';
                hold on
            end
            
            set(gca,'FontUnits','normalized', 'FontSize',0.035);
            xlabel('Z (m)',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035]);
            ylabel('Singular Values',...
                'Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035]);
            
            text('Units','normalized',...
                'FontUnits','normalized',...
                'FontSize',[0.035],...
                'Position',[1.0 -0.07],...
                'HorizontalAlignment','right',...
                'String',...
                [MIA_mdl.BG_mdl.t_stamp]);
        end
    end
end

