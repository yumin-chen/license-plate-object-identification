% -------------------------------------------------------------------------
% ========================
% License Plate Object Identification
% ========================
%
% Copyright (C): Yumin Chen & Paul Sheehan
%
% Introduction
% ------------------------
% This project aims to find (and isolate by masking) the registration plate
% in an image. Algorithms will be demonstrated on a specific image but they
% are designed in a general way so they will work on similar images. All 
% designs aim to be as automated as possible. 
% -------------------------------------------------------------------------

% Clear and clean enviroment
clc;        % Clear command line
clear all;  % Clear all variables
close all;  % Close all sub-windows

% Read image
image = im2double(imread('Reg.jpg'));
gray = rgb2gray(image); 

% Strech contrast
gMin = min(gray(:));
gMax = max(gray(:));
gStd = std(gray(:));
gLowerBound = max(gMin, (gMax + gMin) / 2 - gStd * 3);
gUpperbound = min(gMax, (gMax + gMin) / 2 + gStd * 3);
contrastStretched = (gray - gLowerBound) / (gUpperbound - gLowerBound);

threshold = mean(contrastStretched(:));
blackWhite = double(contrastStretched > threshold);
seg = gray .* blackWhite;
colored = image;

% Adaptive thresholding
[height, width, depth] = size(image);
half = 3;
% Loop through the image to apply threshold to each pixel
for x = half + 1:width - half
    for y = half + 1: height - half
        area = contrastStretched(y-half:y+half, x-half:x+half);
        threshold = mean(area(:)) - 0.05;
        seg(y, x) = double(contrastStretched(y, x) > threshold);
        if contrastStretched(y, x) > threshold
            colored(y, x, :) = 1;
        end            
    end
end

% Show the results
figure, imshow(contrastStretched), title('Contrast Stretched');
figure, imshow(seg), title('Adaptive Thresholding');
figure, imshow(colored), title('Colored');



