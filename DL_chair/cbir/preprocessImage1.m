function d = preprocessImage1(imgData, imageDim)
	%imgData = rgb2gray(imgData);
	d = imresize(imgData, [imageDim, imageDim]);
end
