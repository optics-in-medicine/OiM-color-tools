function [ I_c, R ] = rotate_card( I )
%ROTATE_CARD  Rotates the hyperspectral image stack of a colorchecker card.
%   User inputs the image stack, I, a line which stretches from top left to 
% bottom right of card. It outputs the rotated stack, as well as the
% reflectance spectra, which is sampled from a 20 x 20 pixel ROI of each
% square.
%
% Jonathan T. Elliott, PhD <jte@dartmouth.edu>
%

I_bar = mean(I, 3);                                                         % mean across all wavelengths.
    
[rows cols nwl] = size(I);                                                  % get the dims of I
X_shift = fix(cols / 2);                                                    % find center, which will be rotational axis.
Y_shift = fix(rows / 2);

figure('color','white');                                                    % get user input for part of image containing squares.
h1 =imagesc(I_bar); axis image; colormap gray
h = imline;
pts = h.getPosition;                                                        % get the two points connected by the line.
close(gcf);
 
delY = pts(2,2) - pts(1,2);                                                 % rise
delX = pts(2,1) - pts(1,1);                                                 % run

ang = atan2(delY, delX) * (180 / pi() );                                    % rotational angle to line up with x,y axis of figure.

B = imrotate(I_bar, ang - 33.7, 'nearest', 'crop');                         % rotate the image, and don't add whitespace around it.
                                                                            % FYI, 33.7 degrees is the angle of the diagonal stretching across the colorcard since it is 4 x 6 aspect ratio.
Q = [cosd(ang - 33.7) -sind(ang - 33.7);                                    % create a rotational matrix to move the "diagonal line" to its new place.
     sind(ang - 33.7)  cosd(ang - 33.7) ];
 
pts_r = [(pts(1,:) - [X_shift Y_shift]) * Q; ...                            % move the diagonal line so that it properly defines the limits of the cropped image.
         (pts(2,:) - [X_shift Y_shift]) * Q]+ ...
         [X_shift Y_shift; X_shift Y_shift];

delY_r = pts_r(2,2) - pts_r(1,2);                                           % find new width and hight of cropped image.
delX_r = pts_r(2,1) - pts_r(1,1);
 
B_c = imcrop(B,[pts_r(1,1) pts_r(1,2) delX_r delY_r]);                      % crop image based on new diagonal line.
[r c] = size(B_c);


I_c = zeros(r, c, nwl);                                                     % initialize spectra matrix
for i = 1:nwl                                                               % repeat rotate, crop procedure for all wavelengths in the hyper stack.
    B_t = imrotate(I(:,:,i), ang - 33.7, 'nearest', 'crop');                
    I_c(:,:,i) = imcrop(B_t,[pts_r(1,1) pts_r(1,2) delX_r delY_r]);
end
% 
% figure;
% imagesc(B_c); axis image

[r c] = size(B_c);                                                          % dims of new image.

sq = mean([ (c / 6) (r / 4) ]);                                             % whats the size of each colorchecker square.

counter = 1;    
r = 10;                                                                     % defines 
R = zeros(nwl, 24);                                                         % initialize matrix.
for i = 1:6
    for j = 1:4
        cc = [fix( sq/2 + sq*(j-1) ), fix( sq/2 + sq*(i-1) )];              % isolate the ROI for this square.
        R(:,counter) = squeeze( mean( mean( I_c( cc(1)-r : cc(1)+r, ...     % take average to get reflectance spectra.
            cc(2)-r : cc(2)+r, :)) ));
        counter = counter + 1;                                              % increment counter.
    end
end


end                                                                         % return I_c and R
