function d = preprocessImage(imgData, u, k, patchSize)
	imgData = rgb2gray(imgData);
	imgData = imresize(imgData, [patchSize, patchSize]);

	imgData = imgData(:);
	imgData = imgData - mean(imgData);
	
	%class(imgData)
	d = u(:, 1:k)' * double(imgData);
end
