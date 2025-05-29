classdef F2_SCPManager < handle

    properties
        SCP_lists
        DEV_lists
        nList
        DEVS
        nDEV
        isBPM
        DEVS_str
        DEVS_cmd
        numPulses
        command
        warnStruct

        nFile
        data

        metadata

        daq_handle
        freerun = true
    end

    properties(Constant) 
        nMax = 600
        BEAMCODE = 10
        SCPtimeout = 300
        script_str = './scpbuffacq.sh '
        warnID = 'MATLAB:table:ModifiedAndSavedVarnames'
        awk_cmd = 'awk ''{$1=$1}1'' '
    end
    
    methods
        
        function obj = F2_SCPManager(SCP_list,n_shot,daq_handle)

            if isempty(SCP_list); return; end
            if exist('daq_handle','var')
                obj.daq_handle = daq_handle;
                obj.freerun = false;
            end

            obj.SCP_lists = SCP_list;
            obj.nList = numel(SCP_list);
            
            % Loop over lists and add devices
            obj.DEVS = [];
            obj.DEV_lists = [];
            for i = 1:obj.nList
                devs = feval(obj.SCP_lists{i});
                lists = cell(size(devs));
                lists(:) = obj.SCP_lists(i);

                obj.DEVS = [obj.DEVS; devs];
                obj.DEV_lists = [obj.DEV_lists; lists];
            end
            obj.nDEV = numel(obj.DEVS);
            
            % loop over devs and decide if they are BPMS or KLYS
            obj.isBPM = zeros(obj.nDEV,1);
            for i = 1:obj.nDEV
                if strcmp(obj.DEVS{i}(1:4),'BPMS')
                    obj.isBPM(i) = 1;
                end
            end

            % Create metadata struct
            obj.createMetadata();

            % Create data struct
            obj.createData();

            % Format string of devices
            obj.DEVS_str = join(string(obj.DEVS)','","');
            obj.DEVS_cmd = char('''["' + obj.DEVS_str + '"]''');

            % This is fixed once object is created
            obj.numPulses = n_shot;

            % Not sure why we need this. . .
            obj.warnStruct = warning('off',obj.warnID);
            
        end

        function status = startBuffAcq(obj,step)
            
            % Format command
            obj.command = [obj.script_str num2str(obj.SCPtimeout) ' ' ...
                num2str(obj.numPulses) ' ' obj.DEVS_cmd ' > step' ...
                num2str(step) '.txt &'];

            % Start buffered acquisition
            status = system(obj.command);

        end

        function [data, status] = getSCPdata(obj,scanDim,totalSteps)

            if scanDim == 0
                obj.nFile = 1;
            else
                obj.nFile = totalSteps;
            end

            all_scp_data = cell(1,obj.nFile);

            % Check for SCP files
            scp_files = dir('step*.txt');
            if numel(scp_files) ~= obj.nFile
                obj.daq_handle.dispMessage(['Warning: Did not find SCP files. '...
                    num2str(obj.nFile) ' and ' num2str(numel(scp_files)) ' found.']);
                data = [];
                status = 1;
                return;
            end
            % Check that files have data
            for i = 1:obj.nFile
                if scp_files(i).bytes == 0
                    j = 0;
                    while j < 20
                        obj.daq_handle.dispMessage(['Warning: SCP Step ' num2str(i)...
                            ' file incomplete. Waiting 3 seconds.']);
                        pause(3);
                        scp_files = dir('step*.txt');
                        if scp_files(i).bytes ~= 0
                            obj.daq_handle.dispMessage(['Got SCP data for step ' num2str(i)]);
                            break;
                        end
                        j = j+1;
                    end
                    if scp_files(i).bytes == 0
                        obj.daq_handle.dispMessage(['Warning: SCP Step ' num2str(i)...
                            ' file incomplete. 1 minute timeout exceeded.']);
                        data = [];
                        status = 1;
                        return;
                    end
                
                end
            end


            % Remove extra spaces in the SCP files which cause problems for
            % for the MATLAB table functionality, then load data
            for i = 1:obj.nFile
                txtfilename = scp_files(i).name;
                clnfilename = ['clean_' txtfilename];

                % clean data
                awk_command = [obj.awk_cmd txtfilename ' > ' clnfilename];
                cmd_stat = system(awk_command);

                % extract data
                all_scp_data{i} = readtable(clnfilename,'MultipleDelimsAsOne',true);

            end

            % Loop over steps (file=step) and devices to extract data
            for i = 1:obj.nFile

                scp_data = all_scp_data{i};

                for j = 1:obj.nDEV

                    dev = obj.DEVS(j);
                    list = obj.DEV_lists{j};
                    isBPM = obj.isBPM(j);
                    tableInds = strcmp(dev,scp_data.BPMName);

                    if isBPM
                        x_vals = scp_data.xOffset_mm_(tableInds);
                        y_vals = scp_data.yOffset_mm_(tableInds);
                        t_vals = scp_data.numParticles_coulomb_(tableInds);
                        s_vals = scp_data.stat(tableInds);

                        obj.data.(list).([remove_dots(dev{1}) '_X']) = ...
                            [obj.data.(list).([remove_dots(dev{1}) '_X']); x_vals];
                        obj.data.(list).([remove_dots(dev{1}) '_Y']) = ...
                            [obj.data.(list).([remove_dots(dev{1}) '_Y']); y_vals];
                        obj.data.(list).([remove_dots(dev{1}) '_TMIT']) = ...
                            [obj.data.(list).([remove_dots(dev{1}) '_TMIT']); t_vals];
                        obj.data.(list).([remove_dots(dev{1}) '_STAT']) = ...
                            [obj.data.(list).([remove_dots(dev{1}) '_STAT']); s_vals];
                    else
                        p_vals = scp_data.xOffset_mm_(tableInds);
                        s_vals = scp_data.stat(tableInds);

                        obj.data.(list).([remove_dots(dev{1}) '_PHAS']) = ...
                            [obj.data.(list).([remove_dots(dev{1}) '_PHAS']); p_vals];
                        obj.data.(list).([remove_dots(dev{1}) '_STAT']) = ...
                            [obj.data.(list).([remove_dots(dev{1}) '_STAT']); s_vals];
                    end

                end

                obj.data.steps = [obj.data.steps; i*ones(obj.numPulses,1)];
                obj.data.pids = [obj.data.pids; scp_data.pulseId(tableInds)];
            end

            % clean up
            obj.rm_text_files();
        end

        function createMetadata(obj)

            % Loop over SCP lists and extract relevant devs
            for i = 1:obj.nList
                scp_list = obj.SCP_lists{i};
                dev_inds = strcmp(obj.DEV_lists,scp_list);
                devs = obj.DEVS(dev_inds);
                isBPMs = obj.isBPM(dev_inds);

                % Create PVs based on BPM/KLYS
                pv_list = [];
                for j = 1:numel(devs)
                    dev = devs{j};
                    if isBPMs(j)
                        devPVs = {[dev,':X'];[dev,':Y'];[dev,':TMIT'];[dev,':STAT']};
                    else
                        devPVs = {[dev,':PHAS'];[dev,':STAT']};
                    end
                    pv_list = [pv_list; devPVs];
                end

                obj.metadata.(scp_list).PVs = pv_list;
                obj.metadata.(scp_list).Desc = pv_list;

            end
        end

        function createData(obj)

            % Loop over SCP lists and use metadata to make data structs
            for i = 1:obj.nList
                list = obj.SCP_lists{i};
                obj.data.(list) = struct();
                PVs = obj.metadata.(list).PVs;
                for j=1:numel(PVs)
                    pv = PVs{j};
                    obj.data.(list).(remove_dots(pv)) = [];
                end
            end

            obj.data.steps = [];
            obj.data.pids = [];

        end

        function rm_text_files(obj)

            rm_cmd = 'rm -rf step*.txt clean_step*.txt';
            cmd_stat = system(rm_cmd);

        end


        function delete(obj)

           % Restore table variable name warning status
            warning(obj.warnStruct);

        end
        

    end
    
end