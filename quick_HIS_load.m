function [I , wl] = quick_HIS_load( hisdir )
%QUICK_HIS_LOAD Summary of this function goes here
%   Detailed explanation goes here

files = dir(hisdir);
index = 1;

for i = 1:length(files)
    cn = files(i).name;
    if strcmpi( cn(1),'w' )
        
        j = str2num( cn(7:9) ) + 1;
        if j == 1;
            I1 = imread( [hisdir filesep cn], 'tiff' );
            [rows cols] = size( I1 );
            I = zeros(rows, cols, length(files));
            I(:,:,1) = I1;
        end
        wl(j) = str2num( cn(3:5) );
        I(:,:,j) = imread( [hisdir filesep cn], 'tiff' );
        
        index = index + 1;
    end
end

I = I(:,:,1:index - 1);


