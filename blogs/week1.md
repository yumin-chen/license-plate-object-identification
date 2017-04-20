**Contrast Stretching**
========================
<sup>*This is a blog entry from [License Plate Object Identification Blogs](http://chenyumin.com/p/license-plate-object-detection-1-contrast-stretching).*</sup>

In this week, simple contrast stretching is implemented as a image enhancement technique to improve the contrast of the image. The target image for this project actually already has pretty good contrast, but for better automation, proper normalization is needed to better generalize this solution.  

To preserve the colors, the actual stretching operation is performed using the original color image, but for statistics analyzation, all the data, including minimum, maximum, and standard deviation, is collected based on the grayscale image.  

```matlab
gMin = min(gray(:));
gMax = max(gray(:));
gStd = std(gray(:));
% Apply statistics three-sigma rule to bound to 99.73% of data
gLowerBound = max(gMin, (gMax + gMin) / 2 - gStd * 3);
gUpperbound = min(gMax, (gMax + gMin) / 2 + gStd * 3);
contrastStretched = (image - gLowerBound) / (gUpperbound - gLowerBound);
```

The distribution of the colors in the target image is assumed to follow the normal distribution. Thus, the statistics [three-sigma rule][1] is used in the contrast stretching process to bound to 99.73% of data, and discard 0.27% of the original data. After the stretching, there might be approximately 0.27% of the data going out of bounds (>1 or <0). This is to further improve the normalization effect.  

Results:

| Original | Contrast Stretched |
| :---: |:---:|
| ![Original](./img/week1-original.jpg) | ![Contrast Stretched](./img/week1-contrast-streching.jpg) |
| ![Original Histgram](./img/week1-original-histgram.jpg) | ![Contrast Stretched Histgram](./img/week1-contrast-streching-histgram.jpg) |

From the results we can see that there isn't a noticeable change in these two images before and after the contrast streching. But because this project aims to develop a general algorithm that would work on other similar images as well. Contrast stretching, or normalization, is neccessary to help make this program more automated.


References
------------------------
* [Wikipedia: 68–95–99.7 rule][1]  

[1]: https://en.wikipedia.org/wiki/68%E2%80%9395%E2%80%9399.7_rule "68–95–99.7 rule"
<br>

------------------------
Next: [Week 2: Thresholding](./week2.md)