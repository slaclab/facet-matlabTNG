% Function that outputs a single struct containing custom color maps.

% Sebastien Corde
% Create: June 2, 2013
% Last edit: May 26, 2016

% Convention: name of the color map is the ordered list of the colors
% contained in the color map, e.g.: wbgyr for "white -> blue -> green ->
% yellow -> red"

function cmap = custom_cmap()


% "white -> blue -> green -> yellow -> red"
D = [1 1 1;
     0 0 1;
     0 1 0;
     1 1 0;
     1 0 0;];
F = [0 0.25 0.5 0.75 1];
G = linspace(0, 1, 256);
cmap.wbgyr = interp1(F,D,G);


% "blue -> white -> red"
D=[0 0 1;
   1 1 1;
   1 0 0;];
F=[0 0.5 1];
G=linspace(0,1,256);
cmap.bwr=interp1(F,D,G);


% modified jet with white at low values
D = [1 1 1;
     0 0 1;
     0 1 1;
     1 1 0;
     1 0 0;
     0.5 0 0;];
F = [0 0.20 0.35 0.50 0.80 1];
G = linspace(0, 1, 256);
cmap.mjet = interp1(F,D,G);


% "black -> green -> bright green"
D = [0 0 0;
     0 1 0;
     0.5 1 0.5;];
F = [0 0.5 1];
G = linspace(0, 1, 256);
cmap.bg = interp1(F,D,G);


% "white -> green -> bright green"
D = [1 1 1;
     0 1 0;
     0.5 1 0.5;];
F = [0 0.5 1];
G = linspace(0, 1, 256);
cmap.wg = interp1(F,D,G);


% "white -> red -> dark red"
D = [1 1 1;
     1 0.2 0.2;
     0.75 0 0;];
F = [0 0.5 1];
G = linspace(0, 1, 256);
cmap.wr = interp1(F,D,G);


% "white -> blue ->  yellow -> red"
D = [1 1 1;
     0 0 1;
     1 1 0;
     1 0 0;];
F = [0 0.333 0.666 1];
G = linspace(0, 1, 256);
cmap.wbyr = interp1(F,D,G);


% "white -> blue -> green -> yellow"
D = [1 1 1;
     0 0 1;
     0 1 0;
     1 1 0;];
F = [0 0.333 0.666 1];
G = linspace(0, 1, 256);
cmap.wbgy = interp1(F,D,G);


end