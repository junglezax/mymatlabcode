% parameters
numpatches = 10000;
scaledSize = 512;
patchDim = 8;

imageChannels = 3;     % number of channels (rgb, so 3)

numPatches = 100000;   % number of patches

visibleSize = patchDim * patchDim * imageChannels;  % number of input units 
outputSize  = visibleSize;   % number of output units
hiddenSize  = 400;           % number of hidden units 

sparsityParam = 0.035; % desired average activation of the hidden units.
lambda = 3e-3;         % weight decay parameter       
beta = 5;              % weight of sparsity penalty term       

epsilon = 0.1;	       % epsilon for ZCA whitening

% load images
[images, allLabels, x, img_resized] = read_97chairs(scaledSize, false);

% sample train images to train patches for train AE
patches = sampleIMAGES_color(img_resized, patchDim, numpatches);

displayColorNetwork(x(:, 1:9));
displayColorNetwork(patches(:, 1:81));

% do ZCA
meanPatch = mean(patches, 2);
patches = bsxfun(@minus, patches, meanPatch);

% Apply ZCA whitening
sigma = patches * patches' / numPatches;
[u, s, v] = svd(sigma);
ZCAWhite = u * diag(1 ./ sqrt(diag(s) + epsilon)) * u';
patches = ZCAWhite * patches;

% train linear AE, got feature filter matrix
theta = initializeParameters(hiddenSize, visibleSize);

options = struct;
options.Method = 'lbfgs'; 
options.maxIter = 400;
options.display = 'on';

tic
[optTheta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
                                   visibleSize, hiddenSize, ...
                                   lambda, sparsityParam, ...
                                   beta, patches), ...
                              theta, options);
toc

fprintf('Saving\n');
save('../../../data/chair97LinearFeatures.mat', 'optTheta', 'ZCAWhite', 'meanPatch', 'patches', 'img_resized');
fprintf('Saved\n');

% load train images and test images 问题来了：这里的图像和train AE用的图像是一批吗？
% do convolution and pooling to train and test images, got pooled features
% train classifier using pooled features
% test classifier
