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


% ------------------------
% Main
% ------------------------
function main
cleanEverything();

% Read the originial registration plate image
image = im2double(imread('Reg.jpg'));

% Normalize
normalized = normalize(image);

% Global Thresholding
gThreshed = globalThreshold(normalized, mean(image(:)));

% Adaptive Thresholding
aThreshed = adaptiveThreshold(normalized);

% Edge Detect
edgeDetected = edgeDetect(aThreshed);


% Show images
figure, imshow(normalized), title('Contrast Stretched');
figure, imshow(gThreshed), title('Global Thresholding');
figure, imshow(aThreshed), title('Adaptive Thresholding');
figure, imshow(edgeDetected), title('Edge Detection');
end


% ------------------------
% Clean everything
% ------------------------
function cleanEverything
% Clear and clean enviroment
clc;        % Clear command line
clear all;  % Clear all variables
close all;  % Close all sub-windows
end


% ------------------------
% Normalize (Stretch contrast)
% ------------------------
function output = normalize(image)
gray = rgb2gray(image); 
gMin = min(gray(:));
gMax = max(gray(:));
gStd = std(gray(:));
% Apply statistics three-sigma rule to bound to 99.73% of data
gLowerBound = max(gMin, (gMax + gMin) / 2 - gStd * 3);
gUpperbound = min(gMax, (gMax + gMin) / 2 + gStd * 3);
output = (image - gLowerBound) / (gUpperbound - gLowerBound);
end


% ------------------------
% Global thresholding
% ------------------------
function output = globalThreshold(image, threshold)
output = image;
[height, width, ~] = size(image);
% Loop through each pixel for global thresholding
for x = 1:width
    for y = 1: height
        if mean(image(y, x, :)) > threshold
            % Wipe out the pixel if larger than threshold
            output(y, x, :) = 1;
        end            
    end
end
end


% ------------------------
% Adaptive thresholding
% ------------------------
function output = adaptiveThreshold(image)
output = image;
[height, width, ~] = size(image);
half = 3;
% Loop through the image to apply threshold to each pixel
for x = half + 1:width - half
    for y = half + 1: height - half
        area = image(y-half:y+half, x-half:x+half, :);
        threshold = mean(area(:)) - 0.05;
        if mean(image(y, x, :)) > threshold
            % Wipe out the pixel if larger than threshold
            output(y, x, :) = 1;
        end
    end
end
end


% ------------------------
% Edge Detection
% ------------------------
function output = edgeDetect(image)
% Apply gausian filter to the thresholded image
blurred = imgaussfilt(image, 2);

% This is the sobel filter kernal
sobelX = [-1 0 1;
         -2 0 1;
         -1 0 1]/4;
     
sobelY = [-1 -2 -1;
         0 0 0;
         1 2 1]/4;

% convert blurred image to greyscale
blurredGray = rgb2gray(blurred);

%Apply sobel filter to emphasize lines on the X and Y axis
edgeDetectionX = conv2(blurredGray, sobelX);
edgeDetectionY = conv2(blurredGray, sobelY);

% Get the gradient magnitude of the image using use Pythagorus Thoerem
magnitude = sqrt(edgeDetectionX.^2 + edgeDetectionY.^2);
edgeDetection = (magnitude - min(magnitude(:)))/max(magnitude(:)) - min(magnitude(:));

% Using the threshold of 0.2 to seperate lines of high 
% (after adaptive thresholding)
edgeDetection = edgeDetection > 0.2;
output = ~edgeDetection;
end
