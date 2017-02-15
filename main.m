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
[height, width, depth] = size(image);


% ------------------------
% Stretch contrast
% ------------------------
gMin = min(gray(:));
gMax = max(gray(:));
gStd = std(gray(:));
% Apply statistics three-sigma rule to bound to 99.73% of data
gLowerBound = max(gMin, (gMax + gMin) / 2 - gStd * 3);
gUpperbound = min(gMax, (gMax + gMin) / 2 + gStd * 3);
contrastStretched = (image - gLowerBound) / (gUpperbound - gLowerBound);
% Show contrast streched image
figure, imshow(contrastStretched), title('Contrast Stretched');


% ------------------------
% Global thresholding
% ------------------------
threshold = mean(contrastStretched(:));
globalThresholding = image;
% Loop through each pixel for global thresholding
for x = 1:width
    for y = 1: height
        if mean(contrastStretched(y, x, :)) > threshold
            % Wipe out the pixel if larger than threshold
            globalThresholding(y, x, :) = 1;
        end            
    end
end
% Show global thresholding reconstructed image
figure, imshow(globalThresholding), title('Global Thresholding');


% ------------------------
% Adaptive thresholding
% ------------------------
adaptiveThresholding = image;
half = 3;
% Loop through the image to apply threshold to each pixel
for x = half + 1:width - half
    for y = half + 1: height - half
        area = contrastStretched(y-half:y+half, x-half:x+half, :);
        threshold = mean(area(:)) - 0.05;
        if mean(contrastStretched(y, x, :)) > threshold
            % Wipe out the pixel if larger than threshold
            adaptiveThresholding(y, x, :) = 1;
        end            
    end
end
% Show adaptive thresholding reconstructed image
figure, imshow(adaptiveThresholding), title('Adaptive Thresholding');



