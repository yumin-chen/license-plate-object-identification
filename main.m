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

% Normalization
normalized = normalize(image);

% Global Thresholding
gThreshed = globalThreshold(normalized, mean(image(:)));

% Adaptive Thresholding
aThreshed = adaptiveThreshold(normalized);

% Edge Detection
edgeDetected = edgeDetect(aThreshed);

% Color Segmentation
colorSegmented = colorSegment(normalized);

roi = colorSegmented | edgeDetected;
roi = bwareafilt(roi, 1, 'largest');
% Fill the enclosed area
roi = imfill(roi, 'holes');

% Restore to RGB colored image
output = image;
for i = 1:3
    output(:, :, i) = roi .* image(:, :, i);
end

% Show images
figure, imshow(normalized), title('Contrast Stretched');
figure, imshow(gThreshed), title('Global Thresholding');
figure, imshow(aThreshed), title('Adaptive Thresholding');
figure, imshow(edgeDetected), title('Edge Detection');
figure, imshow(colorSegmented), title('Color Segmentation');
figure, imshow(roi), title('roi');
figure, imshow(output), title('output');
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
% Global Thresholding
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
% Adaptive Thresholding
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
gradientX = conv2(blurredGray, sobelX, 'same');
gradientY = conv2(blurredGray, sobelY, 'same');

% Get the gradient magnitude of the image using use Pythagorus Thoerem
magnitude = sqrt(gradientX.^2 + gradientY.^2);
allGradientValues = (magnitude - min(magnitude(:)))/max(magnitude(:)) - min(magnitude(:));

% Using the threshold of 0.2 to seperate lines of high 
% (after adaptive thresholding)
highGradientOnly = allGradientValues > 0.2;

% After we apply the sobel filter on the X and Y axis:
    % A Canny operation is used to find the desired edges
    % of the rectangular lience plate

% Inverse tan of X and Y gradients will give us the dirrection
    % of an edge at each pixel in the image
angle = atan(gradientX./gradientY);
% First, Canny will thin every edge to one pixel in width
canny = edge(highGradientOnly,'Canny');

% Hysteresis thresholding will connect any broken lines in the image,
% which has yet to be implemented if we are using Canny edge detection
canny_angles = ones(size(image));
canny_angles(canny) = angle(canny);

angle_tolerance = 30/180*pi; % This is a threshold for more precise angles
target_angle = 0;   % Target angle will find all edges at a specified angle

% If you print the object (below code) by ".*ones(size(image))"
    % it will print a broken image of the licence plate
    % The licence plate will be rotated at a very strange angle
A_target_angle = canny_angles >= target_angle*pi/180 - angle_tolerance & ...
    canny_angles<= target_angle*pi/180 + angle_tolerance;
% The output is our thinned image before hysteris or edge detection
output = canny;
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
% roi = bwareaopen(roi, floor((width/20) * (height/20)));
roi = bwareafilt(roi, 1, 'largest');

% Fill the enclosed area
output = imfill(roi, 'holes');
end
