function UVVisData = UVVisFunc(x,minLambda,maxLambda)

% Returns UVVis data
% Sets minimum/maximum wavelengths and accounts for optics

if nargin == 1
    minLambda = 185e-9; % change to some other default value
    maxLambda = 1000e-9; % change to some other default value
end

lambda = linspace(185e-9,1050e-9,2048);
[~,highcutoffind] = min(abs(lambda - maxLambda));
[~,lowcutoffind] = min(abs(lambda - minLambda));
lambda = lambda(lowcutoffind:highcutoffind);

% Accounting for optics
addpath('/home/fphysics/rafimah/DAQ');
load('light_attenuation_data.mat','interplambda','totVUVfac_interp')
optics_inv = 1./totVUVfac_interp;
% Gets which interplambda index is closest for all points
[~,minlambdainds] = min(abs(lambda - interplambda'));
optics_inv_fac = optics_inv(minlambdainds);
% Sets the indices for the edges to 1
optics_inv_fac(minlambdainds == length(lambda)) = 1;
optics_inv_fac(minlambdainds == 1) = 1;
optics_inv_fac(isnan(optics_inv_fac)) = 0;

% Reshape data to be [2040,numShot] and change data type
UVVisdata = squeeze(double(x));
% Cuts the UV Vis data
UVVisdata = UVVisdata(lowcutoffind:highcutoffind,:);
% Inverts the effect of optics
UVVisdata = UVVisdata.*optics_inv_fac';

% Sums data
UVVisData = sum(UVVisdata,1);

end