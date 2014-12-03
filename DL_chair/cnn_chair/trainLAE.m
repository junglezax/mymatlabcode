function model = trainLAE(images, options)

visibleSize = options.patchDim * options.patchDim * options.imageChannels;  % number of input units, also is outputSize

% sample train images to train patches for train AE
disp('sampling patches from images...');
patches = sampleIMAGES_color(images, options.patchDim, options.numPatches);
disp('sampling patches from images finished');

% do ZCA
meanPatch = mean(patches, 2);
patches = bsxfun(@minus, patches, meanPatch);

% Apply ZCA whitening
sigma = patches * patches' / options.numPatches;
[u, s, v] = svd(sigma);
ZCAWhite = u * diag(1 ./ sqrt(diag(s) + options.epsilon)) * u';
patches = ZCAWhite * patches;

% train linear AE, got feature filter matrix
theta = initializeParameters(options.hiddenSize, visibleSize);

aeOptions = struct;
aeOptions.Method = 'lbfgs'; 
aeOptions.maxIter = options.maxIter;
aeOptions.display = options.display;

disp('training linear encoder...');
[optTheta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
                                   visibleSize, options.hiddenSize, ...
                                   options.lambda, options.sparsityParam, ...
                                   options.beta, patches), ...
                              theta, aeOptions);
disp('training linear encoder finished');

model = struct;
model.optTheta = optTheta;
model.ZCAWhite = ZCAWhite;
model.meanPatch = meanPatch;

end
