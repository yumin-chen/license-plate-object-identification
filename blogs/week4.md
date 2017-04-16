**Color Segmentation**
========================
<sup>*This is a blog entry from [License Plate Object Identification Blogs](./README.md).*</sup>

This week, color segmentation is introduced in this project to separate the blue vertical band to the left of the license plate containing the 12 stars of the Flag of Europe.


```matlab
% Convert to HSV color space 
imageHsv = rgb2hsv(image);
h = imageHsv(:, :, 1);
s = imageHsv(:, :, 2);
v = imageHsv(:, :, 3);

% Segment using color
roi = ((h > 0.5) & (h < 0.833)) & (s > 0.5) & (v > 0.5);

% Restore to RGB colored image
output = image;
for i = 1:3
    output(:, :, i) = roi .* image(:, :, i);
end
```
         


References
------------------------
* [Sobel Edge Detector by R Fisher et al, Edinburgh University][1]  

[1]: http://homepages.inf.ed.ac.uk/rbf/HIPR2/sobel.htm "Sobel Edge Detector"
<br>

------------------------
Previous: [Week 3: Edge Detection](./week3.md)  
Next: [Week 5: ...s](./week5.md)