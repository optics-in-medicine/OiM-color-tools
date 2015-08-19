function [ cie_stats ] = map1931gamut( I, im_type, I_mask )
%MAP_GAMUT   This will plot the CIE 1931 xy chromaticity plot and the
%   distribution of colors represented in the input image, I.

switch nargin
    case 1
        I_mask = logical( ones(size(I)) );
        im_type = 'sRGB';
    case 2
        I_mask = logical( ones(size(I)) );
end

% GENERATE CIE 1931 xy MAP
[WL, xFcn, yFcn, zFcn] = colorMatchFcn('CIE_1931');

v=[0:.001:1]; 
[x,y]=meshgrid(v,v); 
y=flipud(y); 
z=(1-x-y);

rgb=applycform(cat(3,x,y,z),makecform('xyz2srgb'));

ciex=xFcn./sum([xFcn; yFcn; zFcn],1); 
ciey=yFcn./sum([xFcn; yFcn; zFcn]);

nciex=ciex * size(rgb,2); 
nciey=size(rgb,1) - ciey * size(rgb,1);

%mask=~any(rgb==0,3); mask=cat(3,mask,mask,mask);
mask=roipoly(rgb,nciex,nciey); 
mask=cat(3,mask,mask,mask);

% OUTLINE THE CONTOURS OF WHITE-LIGHT DISTRO.
rgb2 = I;
rgb3 = rgb2;
rgb3(~I_mask) = 0;

% mask rgb2 based on 2sd less than median of the fluorescence data.
if strcmpi(im_type, 'sRGB')
    xyz = applycform(rgb3, makecform('srgb2xyz'));
elseif strcmpi(im_type, 'xyz')
    xyz = rgb3;
end

xyl = applycform(xyz2double(xyz), makecform('xyz2xyl'));
    
X =  xyl(:,:,1); 
Y =  abs( xyl(:,:,2) - 1 );

[N,C] = hist3([X(:) Y(:)], {0:0.01:1 0:0.01:1});
[xg,yg] = meshgrid( 1000.*C{1}, 1000.*C{2}); %yg = flipud(yg);
    

% OUTLINE THE CONTOURS OF COLORMAP.
% cmap = uint8( handles.cmap );                                               % load a colorbar
% c_xyz = applycform(cmap, makecform('srgb2xyz'));
% c_xyl = applycform(xyz2double(c_xyz), makecform('xyz2xyl'));
% 
% cX =  c_xyl(:,1); cY =  abs( c_xyl(:,2) - 1 );

figure('color','white'); 
imshow(rgb .* mask +~ mask); 
hold on;

% plot sRGB triangle.
plot( [640 300 150 640],abs( [1000 1000 1000 1000] -[330 600 060 330]),'k--', 'LineWidth',1.5);

% plot contour of image gamut.
if ~strcmpi(type, 'traj')
    [C,H] = contour(yg,xg,N,5);
    set(H,'LineWidth',1.5);
    colormap([0.1:0.1:0.5; 0.1:0.1:0.5; 0.1:0.1:0.5]')
else                           % load a colorbar
    c_xyz = applycform(I, makecform('srgb2xyz'));
    c_xyl = applycform(xyz2double(c_xyz), makecform('xyz2xyl'));
    cX =  c_xyl(:,1); cY =  abs( c_xyl(:,2) - 1 );

    H = plot(1000.*cX(2:10:end),1000.*cY(2:10:end),'ko-', 'LineWidth',1.5, 'MarkerSize',5);
    set(H, 'LineWidth', 1,5)
end
legend('sRGB', 'image')

% label some monochromatic values.
[C,IA,IB]=intersect(WL,[400 460 470 480 490 520 540 560 580 600 620 700]);
text(nciex(IA),nciey(IA),num2str(WL(IA).'));

axis on;
set(gca,'XTickLabel',get(gca,'XTick')/(size(rgb,2)-1));
set(gca,'YTickLabel',1-get(gca,'YTick')/(size(rgb,1)-1));

title('CIE Chromaticity'); xlabel('x'); ylabel('y');

hold off
set(gcf, 'menubar', 'none');


% calculate stats.
% like, how much of gamut is within the sRGB space vs. outside of it.
cie_stats = [];


end
