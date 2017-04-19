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
% 3. Identification of the blue vertical band to the left of the plate
% 4. Edge detection
% 5. Morphological operation
% 6. Finding the license plate region
% -------------------------------------------------------------------------


% ------------------------
% Main
% ------------------------
function main
cleanEverything();

% Read the originial registration plate image
image = im2double(imread('reg.jpg'));

% Normalization
normalized = normalize(image);

% Edge Detection
edgeDetected = edge(rgb2gray(normalized), 'Canny');

% Color Segmentation
colorSegmented = colorSegment(normalized);

% Morphological operation 
output = morph(normalized, colorSegmented | edgeDetected);

% Show images
subplot(1,2,1), imshow(image), title('Original');
subplot(1,2,2), imshow(output), title('Output');
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
% Normalization (Contrast Stretching)
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
% Color Segmentation
% ------------------------
function output = colorSegment(image)
% Convert to HSV color space 
imageHsv = rgb2hsv(image);
h = imageHsv(:, :, 1);
s = imageHsv(:, :, 2);
v = imageHsv(:, :, 3);

% Segment blue color
roi = ((h > 0.5) & (h < 0.833)) & (s > 0.5) & (v > 0.5);

% Remove smaller components 
roi = bwareafilt(roi, 1, 'largest');

% Fill the enclosed area
output = imfill(roi, 'holes');
end


% ------------------------
% Morphological Operation
% ------------------------
function output = morph(image, roi)
% Filter out rubbish
roi = bwareafilt(roi, 1, 'largest');

% Fill the enclosed area
roi = imfill(roi, 'holes');

% Restore to RGB colored image
output = image;
for i = 1:3
    output(:, :, i) = roi .* image(:, :, i);
end
end

