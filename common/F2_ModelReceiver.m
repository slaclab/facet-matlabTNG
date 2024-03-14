% F2_ModelReceiver
% -------------------------------------------------------------------------------
% interface class to provide live lucretia model data to FACET physics apps
% this object receives model data from the live model server and
% reshapes NTTables into more familiar/useful data structures
% author: Zack Buschmann <zack@slac.stanford.edu>

% ================================================================================

classdef F2_ModelReceiver < handle

properties
    SimulationSource string {mustBeMember(SimulationSource, ["Lucretia"])} = "Lucretia"
    ModelType string {mustBeMember(ModelType, ["FACET2E"])} = "FACET2E"
    ModelSource string {mustBeMember(ModelSource, ["Live", "Design"])} = "Live"

    LatticeFile = F2_common.LucretiaLattice;

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

    twiss_names =  [ ...
        "s", "p0c", ...
        "alpha_x", "beta_x", "eta_x", "etap_x", "psi_x", ...
        "alpha_y", "beta_y", "eta_y", "etap_y", "psi_y" ...
        ];
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

    function obj = F2_ModelReceiver()
        disp('Connecting to PVA server ...')
        obj.pva = py.p4p.client.thread.Context('pva');
        obj.fetch_beam_params();
        obj.fetch_lattice();
    end


    % primary interface
    % ============================================================

    function R = getRmats(obj, elem1, elem2)
    % get single-element R matrices between elem1 and elem2
        i1 = getIndex(elem1); i2 = getIndex(elem2);
        R = obj.fetch_rmats(i1, i2, true)
    end

    function R = getCombinedRmats(obj, elem1, elem2)
    % get successive composite transfer maps from elem1 to elem2
    % i.e. the map at elemN is the R matrix from elem1 to elemN
        i1 = getIndex(elem1); i2 = getIndex(elem2);
        R = obj.fetch_rmats(i1, i2, false)
    end

    function R = transferMap(obj, elem1, elem2)
    % return the composite R matrix between elem1 to elem2
        i1 = getIndex(elem1); i2 = getIndex(elem2);
        R = obj.compose_rmats(i1, i2);
    end

    function [Tx, Ty] = getTwiss(obj, elem1, elem2)
    % get the live/design twiss parameters from elem1 to elem2
    end

    function [Tx, Ty] = propagateTwiss(obj, elem1, elem2, Tx0, Ty0)
    % propagate Twiss parameters Tx0, Ty0 from elem1 to elem2
    end

    function idx = getIndex(obj, elem)
    % get the beamline index for 'elem'

        idx = double.empty;

        % if elem if already an in-bound index, just return that!
        if isa(elem, 'numeric') && (obj.istart <= elem) && (elem <= obj.iend)
            idx = elem;
        
        % otherwise, check if it exists in ModelNames or ControlNames
        else
            idx = find(obj.ModelNames == elem);
            if isempty(idx), idx = find(obj.ControlNames == elem); end;
        end
    end
    

    % Lucretia-like interface
    % ============================================================

    function [stat, R] = GetRmats(obj, i1, i2)
    % provide R matrices between elements i1 and i2
    % NOTE: this is a wrapper function with a Lucretia-like interface
    %       using transferMap(i1, i2) is recommended
    % https://www.slac.stanford.edu/accel/ilc/codes/Lucretia/web/rmat.html#GetRmats

        RMATS = obj.fetch_rmats(i1, i2, true);
        N = size(RMATS, 3);
        R(N) = struct();
        for i_R = 1:N
            R(i_R).RMAT = RMATS(:,:,i_R);
        end
        stat = {[1]};
    end

    function [stat, R] = RmatAtoB(obj, i1, i2)
    % calculate linear transfer map from elements i1 to i2
    % NOTE: this is a wrapper function with a Lucretia-like interface
    %       using transferMap(i1, i2) is recommended
    % https://www.slac.stanford.edu/accel/ilc/codes/Lucretia/web/rmat.html#GetRmats

        R = struct();
        R.RMAT = obj.compose_rmats(i1, i2);
        stat = {[1]};
    end

    function [stat, T] = GetTwiss(obj, i1, i2, TwissX0, TwissY0)
    % propagate twiss parameters from elements i1 to i2 given intital TwissX0, TwissY0
    % NOTE: this is a wrapper function with a Lucretia-like interface
    %       using propagateTwiss(i1, i2, Tx, Ty) is recommended
    % https://www.slac.stanford.edu/accel/ilc/codes/Lucretia/web/twiss.html#GetTwiss

        stat = {[0]}; T = nan;
        % TO DO: implement twiss propagation either client-side with Rmats, or via ChannelRPC
    end

    function [stat, T] = GetTwissFromInitial(obj, i)
    % propagates twiss parameters from the start of the beamline to element i
    % using the current live or design initial parameters
    % NOTE: this is a wrapper function with a Lucretia-like interface
    %       using getTwiss(i1, i2) is recommended
    % wrapper for GetTwiss with i1 = 1and TwissX0, TwissY0 are the design initial params

        TWISS = obj.fetch_twiss(1, i);
        T = struct;
        for j = 1:12
            T.(obj.twiss_names(j)) = TWISS(j,:);
        end
        stat = {[1]};
    end

end


methods(Access = private)

    function fetch_beam_params(obj)
        disp('Updating beam parameters ...');
        obj.Q_bunch = obj.q_elec * lcaGet('BPMS:IN10:221:TMIT1H');
        obj.f = lcaGet('EVNT:SYS1:1:INJECTRATE')
    end

    function fetch_lattice(obj)
    % parse NTTable and populate names & Z locations

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


    % Internal processing of NTTable -> matlab arrays
    % ============================================================

    function RMATS = fetch_rmats(obj, i1, i2, uncombined)
    % parse Rmat table and convert 36 1xN arrays of unrolled Rmats into a 6x6xN array

        assert((i1 <= i2), 'bad indices: must have elem1 <= elem2');
        N = i2-i1+1;

        PV_str = obj.PV_URMAT;
        if ~uncombined, PV_str = obj.PV_RMAT; end

        fprintf('Requesting %s from PVA server ...\n', PV_str);
        tab_r = obj.pva.get(PV_str).get('value');

        % convert the NTTable into an 6x6xN array
        % super inelegant - may be a better way to do this...
        % tr.get('r<i><j>') returns 1xN arrays for each r11, r12 etc.
        RMATS = zeros(6, 6, N);
        for j = 1:6
            for i = 1:6
                RMATS(j,i,:) = obj.load_ndarray(tab_r.get(sprintf('r%d%d', i, j)), i1, i2);
            end
        end
    end

    function RMAT = compose_rmats(obj, i1, i2)
    % compose the linear transfer maps of elements between i1 and i2

        assert((i1 <= i2), 'bad indices: must have elem1 <= elem2');
        uncombined = true;
        if i1 == 1
            uncombined = false;
            i1 = i2;
        end
        RMATS = obj.fetch_rmats(i1, i2, uncombined);

        % multiplies rmats if N > 1, if N == 1, nothing happens
        RMATS = flip(RMATS, 3);
        N = size(RMATS, 3);
        RMAT = RMATS(:,:,1);
        for i = 2:N
            RMAT = RMATS(:,:,i) * RMAT;
        end
    end

    function TWISS = fetch_twiss(obj, i1, i2)
    % parse twiss parameter table and shape into a 12xN array 

        assert((i1 <= i2), 'bad indices: must have elem1 <= elem2');
        N = i2-i1+1;
        TWISS = zeros(12, N);

        fprintf('Requesting %s from PVA server ...\n', obj.PV_TWISS);
        tab_twiss = obj.pva.get(obj.PV_TWISS).get('value');
        for j = 1:12
            TWISS(j,:) = obj.load_ndarray(tab_twiss.get(obj.twiss_names(j)), i1, i2);
        end
    end

    function arr = load_ndarray(obj, py_arr, i1, i2)
    % helper because direct casting doesn't work for py.memoryview
        arr = cell2mat(py_arr.data.cell);
        arr = arr(i1:i2);
    end

end

end