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

poolDim = 19;          % dimension of pooling region

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

%load ../../../data/chair97LinearFeatures.mat

W = reshape(optTheta(1:visibleSize * hiddenSize), hiddenSize, visibleSize);
b = optTheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);

displayColorNetwork( (W*ZCAWhite)');

% load train images and test images 问题来了：这里的图像和train AE用的图像是一批吗？
labeldImages = img_resized; % use same image set with feature extracting

trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

[trainData, trainLabels, testData, testLabels] = sampleData4d(labeldImages, allLabels, trainSet, testSet);

% do convolution and pooling to train and test images, got pooled features

% train classifier using pooled features
% test classifier
