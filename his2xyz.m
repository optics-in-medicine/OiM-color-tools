function [XYZ, sRGB] = his2xyz(I, wl, CAL)
%HIS2XYZ Converts a stack of hyperspectral images
%   Detailed explanation goes here

if nargin == 2
    % later, add try catch, and have ones matrix as W and B
    load('default_cal.mat');
                                                                            % CAL.W is bright field kernel (fliped and offset).
end                                                                         % CAL.kk is source field
                                                                            % CAL.B is dark field.
% get dimensions.                                                           % Cal.wl is wavelength range of kk.
[X, Y, Z] = size(I);

% subtract darkfield image and apply light field kernel.
I_corr = ( I - repmat( CAL.B, [1 1 Z] ) ) .* repmat( CAL.W, [1 1 Z] );

% Load observer functions and interpolate to wl of measured data
CIE_obs = observer;
x_bar = interp1(CIE_obs(:,1), CIE_obs(:,2), wl, 'pchip')';
y_bar = interp1(CIE_obs(:,1), CIE_obs(:,3), wl, 'pchip')';
z_bar = interp1(CIE_obs(:,1), CIE_obs(:,4), wl, 'pchip')';


% define region of spectral integration so that we avoid areas of low light. 
w1 = 445;  %<- modify if needed.
w2 = 695;  %<- modify if needed.

w1_i = find(wl > w1, 1, 'first'); w2_i = find(wl <= w2, 1, 'last');

del_wl = mean( wl(2:end)-wl(1:end-1) );
K = 100 ./ ( sum( y_bar(w1_i:w2_i) .* del_wl));

% initialize X, Y, and Z matrices.
XX = zeros(X, Y); 
YY = XX; 
ZZ = XX;

% interpolate kk in case it is different.
kk_i = interp1( CAL.wl, CAL.kk, wl, 'pchip' )';

% run through each pixel.
for i = 1:X
    for j = 1:Y
        
        % convolve with each observer function, but divide reflectance
        % spectra by spectralon-measured source first (CAL.kk).
        XX(i,j) = K .* sum( squeeze( I_corr(i,j,w1_i:w2_i)) ./ kk_i(w1_i:w2_i) .* x_bar(w1_i:w2_i) ) ;
        YY(i,j) = K .* sum( squeeze( I_corr(i,j,w1_i:w2_i)) ./ kk_i(w1_i:w2_i) .* y_bar(w1_i:w2_i) ) ;
        ZZ(i,j) = K .* sum( squeeze( I_corr(i,j,w1_i:w2_i)) ./ kk_i(w1_i:w2_i) .* z_bar(w1_i:w2_i) ) ;

    end
end

% concatenate for XYZ.
XYZ = cat(3, XX, YY, ZZ) ./ 100 ;

% also calculate sRGB - probably want to replace with an actual
% transformation.
sRGB = applycform( XYZ , makecform('xyz2srgb') );

end
