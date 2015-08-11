function [ c_map ] = colorcon( I, fmt, lvls )
%COLORCON Calculate the color contrast in L*A*B* color space. 
% There are many definitions for color contrast within an image. Since contrast is the
% ability to resolve two juxaposed objects according to some perceptual
% dimension, how that dimension is defined and the distance over which these
% comparisons are made, spatially, is important. We perform analysis on LAB
% space since it is perceptually uniform, treating each dimension (L*, a*,
% and b*) separately. L* is widely believed to be the most salient
% dimension, and is therefore weighted as 50% of the overal contrast, with
% tha* and b* each 25%. (N.B. this would not be valid for those with color
% vision deficiencies.)
%
% Contrast is calculated on the original image, and then on a series of
% gaussian-blurred, size-reduced images. This provides contrast analysis on
% multiple spatial levels, since human perception is not confined to
% adjacent pixels, but rather, it scans the image for salient features and
% pre-processing determined object recognition. Number of levels, including
% the original image, is defined by 'lvls'.
%
% This procedure is highlighted by: 

% I = imread('X:\#5 - Data\# Clinical Data - Neurosurg\Clinical FGR Probe Data\1006_FGR2014_11_05\Zeiss\2014-11-05 07-01-42 wyman\Images\wyman_2014-11-05_09-43-47_I.JPG');

if nargin == 1
    fmt = 'xyz';
    lvls = 5;
elseif nargin == 2
    lvls = 5;
end

% if srgb then expand to xyz 
if strcmpi(fmt, 'srgb')
    I_xyz = applycform( I, makecform('srgb2xyz') );
elseif strcmpi(fmt, 'xyz')
    I_xyz = I;
end

% I_lab = double( xyz2lab*
I_lab = double( applycform( I_xyz, makecform('xyz2lab') ) );% ./ 65536;

I_blur = I_lab;
h = fspecial('gaussian',[15 15], 2);
for i = 1:lvls
     
    if i ~= 1
        [X, Y, C] = size(I_blur_old);  
        I_blur = imresize(imfilter( I_blur_old, h), [X / 2 Y / 2]);
    end
    
    [X, Y, C] = size(I_blur);
    for j = 3:X-2
        for k = 3:Y-2
            l = ( abs( log( I_blur(j,k,1) ) - log( I_blur(j-2:j+2,k-2:k+2,1) ) ));
            a = ( abs( I_blur(j,k,2) - I_blur(j-2:j+2,k-2:k+2,2) ) );
            b = ( abs( I_blur(j,k,3) - I_blur(j-2:j+2,k-2:k+2,3) ) );
            c(j,k) = mean( l(:) );
%             counter = counter + 1;
        end
    end
    
    disp(['Image ' int2str(i) ' of 5.']);
    c_map{i} = c;
    C(i) = mean(mean(c));
    I_blur_old = I_blur;
    
    clear c l a b I_blur;
end




