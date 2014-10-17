function imgIdxs = L1(numOfReturnedImages, queryImageFeatureVector, dataset)
	% input:
	%   numOfReturnedImages : num of images returned by query
	%   queryImageFeatureVector: query image in the form of a feature vector
	%   dataset: the whole dataset of images transformed in a matrix of
	%   features
	% 
	% output: 
	%	idexes of returned images

	% compute manhattan distance
	manhattan = zeros(size(dataset, 2), 1);
	for k = 1:size(dataset, 2)
	%     manhattan(k) = sum( abs(dataset(k, :) - queryImageFeatureVector) );
		% ralative manhattan distance
		manhattan(k) = sum( abs(dataset(:, k) - queryImageFeatureVector) ./ ( 1 + dataset(:, k) + queryImageFeatureVector ) );
	end

	% sort them according to smallest distance
	[sortedDist imgIdxs] = sortrows(manhattan);
	
	if numOfReturnedImages > numel(imgIdxs)
		numOfReturnedImages = numel(imgIdxs);
	end
	imgIdxs = imgIdxs(1:numOfReturnedImages);
end
