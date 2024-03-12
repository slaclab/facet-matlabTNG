% F2_ModelReceiver
% @author: Zack Buschmann <zack@slac.stanford.edu>

% interface class to provide live lucretia model data to FACET physics apps
% this object monitors R matricies & twiss parameter PVs provided by the live model
% and reshapes them back into lucretia-like data structures

% ================================================================================

classdef F2_ModelReceiver < handle

properties
    SimulationSource string {mustBeMember(SimulationSource, ["Lucretia"])} = "Lucretia"
    ModelType string {mustBeMember(ModelType, ["FACET2E"])} = "FACET2E"
    ModelSource string {mustBeMember(ModelSource, ["Live", "Design"])} = "Live"

    pva % py.p4p PVA context

    ControlNames  % control system names
    ModelNames    % MAD/Lucretia model names

    istart uint16 % index of first BEAMLINE element
    iend uint16   % index of last BEAMLINE element
    
    f double       % e- beam repetition rate Hz
    Q_bunch double % (live?) bunch charge
    
    Z double      % linac Z
    P double      % beam momentum profile
    Brho double   % magnetic rigidity 
    BDES double   % kG.m^(N-1)
    BDES_Z double % Z coordinates of all magnetic elements
    BDES_L double % effective length of all magnetic elements
    KDES double   % magnet strength parameter
end

properties(Constant, Access = private)
    PV_temp_twiss = '%s:SYS0:1:%s:%s:TWISS'
    PV_temp_rmat = '%s:SYS0:1:%s:%s:RMAT'   % Rmat table for composite maps
    PV_temp_urmat = '%s:SYS0:1:%s:%s:URMAT' % Rmat table for single elements

    q_elec = 1.602e-19 % electron charge in C
end

% model PVs are determined by SimulationSource, ModelType & ModelSource
properties (Dependent)
    PV_TWISS string
    PV_RMAT string
    PV_URMAT string
end

methods
    function obj = set.SimulationSource(obj, val)
        obj.SimulationSource = val;
        obj.fetch_lattice();
    end

    function obj = set.ModelType(obj, val)
        obj.ModelType = val;
        obj.fetch_lattice();
    end

    function obj = set.ModelSource(obj, val)
        obj.ModelSource = val;
        obj.fetch_lattice();
    end


    function PV_TWISS = get.PV_TWISS(obj)
        PV_TWISS = sprintf(obj.PV_temp_twiss, ...
            upper(obj.SimulationSource), upper(obj.ModelType), upper(obj.ModelSource));
    end

    function PV_RMAT = get.PV_RMAT(obj)
        PV_RMAT = sprintf(obj.PV_temp_rmat, ...
            upper(obj.SimulationSource), upper(obj.ModelType), upper(obj.ModelSource));
    end

    function PV_URMAT = get.PV_URMAT(obj)
        PV_URMAT = sprintf(obj.PV_temp_urmat, ...
            upper(obj.SimulationSource), upper(obj.ModelType), upper(obj.ModelSource));
    end
end


methods(Access = public)
    
    % constructor
    function obj = F2_ModelReceiver()
        disp('Connecting to PVA server ...')
        obj.pva = py.p4p.client.thread.Context('pva');
        obj.fetch_beam_params();
        obj.fetch_lattice();
    end
    
    % provide R matrices between elem1 and elem2
    % https://www.slac.stanford.edu/accel/ilc/codes/Lucretia/web/rmat.html#GetRmats
    function [stat, R] = GetRmats(obj, elem1, elem2)
        RMATS = obj.fetch_rmats(elem1, elem2, true);
        N = size(RMATS, 3);
        R(N) = struct();
        for i_R = 1:N
            R(i_R).RMAT = RMATS(:,:,i_R);
        end
        stat = {[1]};
    end

    % calculate linear transfer map from elem1 to elem2
    % https://www.slac.stanford.edu/accel/ilc/codes/Lucretia/web/rmat.html#GetRmats
    function [stat, R] = RmatAtoB(obj, elem1, elem2)

        % if elem1 == 1, can get directly from combined rmat table
        % othrwise grab rmats and compose them manually
        uncombined = true;
        if elem1 == 1
            uncombined = false;
            elem1 = elem2;
        end
        RMATS = obj.fetch_rmats(elem1, elem2, uncombined);

        % compose transfer maps if N > 1
        RMATS = flip(RMATS, 3);
        N = size(RMATS, 3);
        R = struct();
        R.RMAT = RMATS(:,:,1);
        for i = 2:N
            R.RMAT = RMATS(:,:,i) * R.RMAT;
        end
        R.RMAT = R.RMAT;
        stat = {[1]};

    end

    % propagate twiss parameters from elem1 to elem2 given intital TwissX0, TwissY0
    % https://www.slac.stanford.edu/accel/ilc/codes/Lucretia/web/twiss.html#GetTwiss
    function [stat, T] = GetTwiss(obj, elem1, elem2, TwissX0, TwissY0)
        stat = {[0]}; T = nan;
        % TO DO: implement twiss propagation either client-side with Rmats, or via ChannelRPC
    end

    % propagates twiss parameters from the start of the beamline to elem
    % using the current live or design initial parameters
    % wrapper for GetTwiss with elem1 = 1and TwissX0, TwissY0 are the design initial params
    function [stat, T] = GetTwissFromInitial(obj, elem)
        disp(elem);
        T = obj.fetch_twiss(1, elem);
        stat = {[1]};
    end
    
    % convenience routine to get beamline indices
    function i = GetIndex(obj, elem_name)
        i = find(obj.ModelNames == elem_name);
    end

end


methods(Access = private)

    % get e- beam bunch charge, momentum profile and rep rate from EPICS
    function fetch_beam_params(obj)
        disp('Updating beam parameters ...');
        obj.Q_bunch = obj.q_elec * lcaGet('BPMS:IN10:221:TMIT1H');
        obj.f = lcaGet('EVNT:SYS1:1:BEAMRATE');
    end

    % parse NTTable and populate names & Z locations
    function fetch_lattice(obj)
        disp('Updating lattice ...')
        table = obj.pva.get(obj.PV_TWISS).get('value');

        obj.ModelNames = string(cell(table.get('element')));
        obj.ControlNames = string(cell(table.get('device_name')));

        obj.istart = size(obj.ModelNames,1);
        obj.iend = size(obj.ModelNames,2);

        obj.Z = obj.load_ndarray(table.get('z'), obj.istart, obj.iend);
        obj.P = obj.load_ndarray(table.get('p0c'), obj.istart, obj.iend);
        obj.Brho = obj.Q_bunch ./ obj.P;
    end

    % parse NTTable and convert 36 1xN arrays into a 6x6xN  array
    function RMATS = fetch_rmats(obj, i1, i2, uncombined)
        assert((i1 <= i2), 'bad indices: must have elem1 <= elem2');
        N = i2-i1+1;

        PV_str = obj.PV_URMAT;
        if ~uncombined, PV_str = obj.PV_RMAT; end

        fprintf('Requesting %s from PVA server ...\n', PV_str);
        table = obj.pva.get(PV_str).get('value');

        % onvert the NTTable into an 6x6xN array
        % super inelegant - may be a better way to do this...
        % table.get('r<i><j>') returns 1xN arrays for each r11, r12 etc.
        RMATS = zeros(6, 6, N);
        for j = 1:6
            for i = 1:6
                RMATS(j,i,:) = obj.load_ndarray(table.get(sprintf('r%d%d', i, j)), i1, i2);
            end
        end
    end

    % construct twiss data structure from arr
    function TWISS = fetch_twiss(obj, i1, i2)
        assert((i1 <= i2), 'bad indices: must have elem1 <= elem2');
        N = i2-i1+1;
        TWISS = zeros(12, N);

        % some minor discrepancies in field names, returning the Lucretia convention
        fprintf('Requesting %s from PVA server ...\n', obj.PV_TWISS);
        table = obj.pva.get(obj.PV_TWISS).get('value');

        TWISS(1,:) = obj.load_ndarray(table.get('s'), i1, i2);
        TWISS(2,:) = obj.load_ndarray(table.get('p0c'), i1, i2);

        TWISS(3,:) = obj.load_ndarray(table.get('alpha_x'), i1, i2);
        TWISS(4,:) = obj.load_ndarray(table.get('beta_x'), i1, i2);
        TWISS(5,:) = obj.load_ndarray(table.get('eta_x'), i1, i2);
        TWISS(6,:) = obj.load_ndarray(table.get('etap_x'), i1, i2);
        TWISS(7,:) = obj.load_ndarray(table.get('psi_x'), i1, i2);

        TWISS(8,:) = obj.load_ndarray(table.get('alpha_y'), i1, i2);
        TWISS(9,:) = obj.load_ndarray(table.get('beta_y'), i1, i2);
        TWISS(10,:) = obj.load_ndarray(table.get('eta_y'), i1, i2);
        TWISS(11,:) = obj.load_ndarray(table.get('etap_y'), i1, i2);
        TWISS(12,:) = obj.load_ndarray(table.get('psi_y'), i1, i2);
    
    end

    % helper because direct casting doesn't work for py.memoryview
    function arr = load_ndarray(obj, py_arr, i1, i2)
        arr = cell2mat(py_arr.data.cell);
        arr = arr(i1:i2);
    end

end


end