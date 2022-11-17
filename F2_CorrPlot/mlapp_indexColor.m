function colList = gui_indexColor(indexName)
%GUI_INDEXCOLOR
%  GUI_INDEXCOLOR(INDEXNAME) returns background color for selected facility
%  names INDEXNAME.

% Input arguments:
%    INDEXNAME: Name(s) of facilities (LCLS, FACET, NLCTA, LCLSII)

% Output arguments:
%    COLLIST: List of color triplets [Nx3]

% Compatibility: Version 7 and higher
% Called functions: none

% Author: Henrik Loos, SLAC
% Refurnished for App Designer by Jake Rudolph - 11/11/22

% --------------------------------------------------------------------

% Get default background color.
col0=get(0,'DefaultuicontrolBackgroundColor');

% Make adjustment for 2020a+ default color
col0 = col0 * 0.72/0.94;

% Define color hues for index names.
colList={ ...
    'LCLS'   [ 0   0   0]; ... % LCLS
    'LCLS2'   [ 0   1   0]; ... % LCLS2
    'FACET'  [ 1  .4 -.2]; ... % FACET
    'F2_ELEC'  [ 1  .4 -.2]; ... % FACET
    'CU_SXR'  [ 1  -.7   -.7]; ... % 
    'CU_HXR'  [ -.5   .2  1]; ... % 
    'SC_SXR'  [ 1  -.7   -.7]; ... % 
    'SC_HXR'  [ -.5   .2  1]; ... % 
    'NLCTA'  [-1   0   1]; ... % NLCTA
    'SPEAR'  [ 1   0  -1]; ... % SPEAR
    'XTA'    [-1   1   0]; ... % X Test facility
    'ASTA'   [ 0  -1   1]; ... % ASTA
    ''       [ 0   0   0]; ... % Default
};

% Rescale colors as small offsets from default.
colList(:,2)=num2cell(min(.09*vertcat(colList{:,2})+repmat(col0,size(colList,1),1),1),2);

% Match names.
[is,id]=ismember(indexName,colList(:,1));

% Use default color if not found.
id(~is)=1;

% Return colors for selected facilities.
colList=vertcat(colList{id,2});