function x = cnnComputeFeature_par(model, images, options)
	numImages = size(images, 4);
	
	% do convolution and pooling to and test images, got pooled features
	stepSize = options.stepSize;
	assert(mod(options.hiddenSize, stepSize) == 0, 'stepSize should divide hiddenSize');

	t = floor((options.imageDim - options.patchDim + 1) / options.poolDim);
    %t1 = numImages * t * t;
    t2 = (options.hiddenSize / stepSize);
	pooledFeatures = zeros(t2, stepSize, numImages, t, t);
	%pooledFeatures = zeros(options.hiddenSize * numImages * t * t);

	fprintf('convolving & pooling for features...numImages=%d\n', numImages);
	
	visibleSize = options.patchDim * options.patchDim * options.imageChannels;
	W = reshape(model.optTheta(1:visibleSize * options.hiddenSize), options.hiddenSize, visibleSize);
	b = model.optTheta(2*options.hiddenSize*visibleSize+1:2*options.hiddenSize*visibleSize+options.hiddenSize);

	parfor convPart = 1:t2
		featureStart = (convPart - 1) * stepSize + 1;
		featureEnd = convPart * stepSize;
		
		fprintf('Step %d: features %d to %d\n', convPart, featureStart, featureEnd); 
		Wt = W(featureStart:featureEnd, :);
		bt = b(featureStart:featureEnd);
		
		fprintf('Convolving and pooling images\n');
		convolvedFeaturesThis = cnnConvolve(options.patchDim, stepSize, images, Wt, bt, model.ZCAWhite, model.meanPatch);
		pooledFeaturesThis = cnnPool_par(options.poolDim, convolvedFeaturesThis);

		%pooledFeatures((featureStart*t1):(featureEnd*t1)) = pooledFeaturesThis(:);
        pooledFeatures(convPart, :, :, :, :) = pooledFeaturesThis;
		
		%clear convolvedFeaturesThis pooledFeaturesThis;
	end

	disp('convolving & pooling for features finished');
	
	% Reshape the pooledFeatures to form an input vector for softmax
    pooledFeatures = reshape(pooledFeatures, [options.hiddenSize, numImages, t, t]);
	x = permute(pooledFeatures, [1 3 4 2]);
	x = reshape(x, numel(pooledFeatures) / numImages, numImages);
end
