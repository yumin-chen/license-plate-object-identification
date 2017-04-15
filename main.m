% -------------------------------------------------------------------------
% ========================
% License Plate Object Identification
% ========================
%
% Copyright (C): Yumin Chen & Paul Sheehan
%
% ------------------------
% Introduction
% ------------------------
% This project aims to find (and isolate by masking) the registration plate
% in an image. Algorithms will be demonstrated on a specific image but they
% are designed in a general way so they will work on similar images. All 
% designs aim to be as automated as possible. 
%
% ------------------------
% Algorithm
% ------------------------
% The basic method for extracting the license plate region can be described
% by the following steps.
% 1. Input of the original image
% 2. Normalization (Contrast Stretching)
% 3. Conversion to HSV color space
% 4. Identification of the blue vertical band to the left of the plate
% 5. Edge detection
% 6. Morphological operation
% 7. Finding the license plate region
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
% figure, imshow(contrastStretched), title('Contrast Stretched');


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
% figure, imshow(globalThresholding), title('Global Thresholding');


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
% figure, imshow(adaptiveThresholding), title('Adaptive Thresholding');

% Apply gausian filter to the thresholded image
adaptiveThresholding = imgaussfilt(adaptiveThresholding, 2);

% This is the sobel filter kernal
sobelX = [-1 0 1;
         -2 0 1;
         -1 0 1]/4;
     
sobelY = [-1 -2 -1;
         0 0 0;
         1 2 1]/4;

% convert our thresholding image to greyscale
adaptiveThresholdingGray = rgb2gray(adaptiveThresholding);

%Apply sobel filter to emphasize lines on the X and Y axis
edgeDetectionX = conv2(adaptiveThresholdingGray, sobelX);
edgeDetectionY = conv2(adaptiveThresholdingGray, sobelY);

% Get the gradient magnitude of the image using use Pythagorus Thoerem
magnitude = sqrt(edgeDetectionX.^2 + edgeDetectionY.^2);
edgeDetection = (magnitude - min(magnitude(:)))/max(magnitude(:)) - min(magnitude(:));

% Using the threshold of 0.2 to seperate lines of high 
% (after adaptive thresholding)
edgeDetection = edgeDetection > 0.2;
edgeDetection = ~edgeDetection;

imshow(edgeDetection);
