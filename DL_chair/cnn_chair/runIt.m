% parameters
numpatches = 10000;
scaledSize = 487;
imageDim = scaledSize;
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

poolDim = 48;          % dimension of pooling region % imageDim - patchDim + 1 = 57

numClasses = 12;

% load images
%[images, labels, x, img_resized] = read_97chairs(scaledSize, false);

oldPwd = pwd;
cd ../
load_it
cd(oldPwd)

% sample train images to train patches for train AE
patches = sampleIMAGES_color(img_resized, patchDim, numpatches);

%displayColorNetwork(x(:, 1:9));
%displayColorNetwork(patches(:, 1:81));

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
save('../../../data/chair97LinearFeatures.mat', 'optTheta', 'ZCAWhite', 'meanPatch');
fprintf('Saved\n');

%load ../../../data/chair97LinearFeatures.mat

W = reshape(optTheta(1:visibleSize * hiddenSize), hiddenSize, visibleSize);
b = optTheta(2*hiddenSize*visibleSize+1:2*hiddenSize*visibleSize+hiddenSize);

%displayColorNetwork( (W*ZCAWhite)');

% load train images and test images 问题来了：这里的图像和train AE用的图像是一批吗？
labeledImages = img_resized; % use same image set with feature extracting

%trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
%testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

%[trainImages, trainLabels, testImages, testLabels] = sampleData4d(labeledImages, labels, trainSet, testSet);
[trainImages, trainLabels, testImages, testLabels, trainSet, testSet] = sampleData4d(labeledImages, labels);

numTrainImages = numel(trainSet);
numTestImages = numel(testSet);

% do convolution and pooling to train and test images, got pooled features
stepSize = 50;
assert(mod(hiddenSize, stepSize) == 0, 'stepSize should divide hiddenSize');

pooledFeaturesTrain = zeros(hiddenSize, numTrainImages, ...
    floor((imageDim - patchDim + 1) / poolDim), ...
    floor((imageDim - patchDim + 1) / poolDim) );
pooledFeaturesTest = zeros(hiddenSize, numTestImages, ...
    floor((imageDim - patchDim + 1) / poolDim), ...
    floor((imageDim - patchDim + 1) / poolDim) );

tic();

for convPart = 1:(hiddenSize / stepSize)
    
    featureStart = (convPart - 1) * stepSize + 1;
    featureEnd = convPart * stepSize;
    
    fprintf('Step %d: features %d to %d\n', convPart, featureStart, featureEnd);  
    Wt = W(featureStart:featureEnd, :);
    bt = b(featureStart:featureEnd);
    
    fprintf('Convolving and pooling train images\n');
    convolvedFeaturesThis = cnnConvolve(patchDim, stepSize, ...
        trainImages, Wt, bt, ZCAWhite, meanPatch);
    pooledFeaturesThis = cnnPool(poolDim, convolvedFeaturesThis);
    pooledFeaturesTrain(featureStart:featureEnd, :, :, :) = pooledFeaturesThis;   
    toc();
    clear convolvedFeaturesThis pooledFeaturesThis;
    
    fprintf('Convolving and pooling test images\n');
    convolvedFeaturesThis = cnnConvolve(patchDim, stepSize, ...
        testImages, Wt, bt, ZCAWhite, meanPatch);
    pooledFeaturesThis = cnnPool(poolDim, convolvedFeaturesThis);
    pooledFeaturesTest(featureStart:featureEnd, :, :, :) = pooledFeaturesThis;   
    toc();

    clear convolvedFeaturesThis pooledFeaturesThis;
end

save('../../../data/cnnPooledFeatures97chairs.mat', 'pooledFeaturesTrain', 'pooledFeaturesTest');
toc();

% train classifier using pooled features
addpath ../../UFLDL/softmax_exercise

% Setup parameters for softmax
softmaxLambda = 1e-4;

% Reshape the pooledFeatures to form an input vector for softmax
softmaxXtrain = permute(pooledFeaturesTrain, [1 3 4 2]);
softmaxXtrain = reshape(softmaxXtrain, numel(pooledFeaturesTrain) / numTrainImages,...
    numTrainImages);
softmaxYtrain = trainLabels;

options = struct;
options.maxIter = 200;
softmaxModel = softmaxTrain(numel(pooledFeaturesTrain) / numTrainImages,...
    numClasses, softmaxLambda, softmaxXtrain, softmaxYtrain, options);

% test classifier
softmaxXtest = permute(pooledFeaturesTest, [1 3 4 2]);
softmaxXtest = reshape(softmaxXtest, numel(pooledFeaturesTest) / numTestImages, numTestImages);
softmaxYtest = testLabels;

[pred] = softmaxPredict(softmaxModel, softmaxX);
acc = (pred(:) == softmaxY(:));
acc = sum(acc) / size(acc, 1);
fprintf('Accuracy: %2.3f%%\n', acc * 100);

% test on all examples
softmaxXall = [softmaxXtrain softmaxXtest];
softmaxYall = [trainLabels; testLabels];

[pred] = softmaxPredict(softmaxModel, softmaxXall);
acc = (pred(:) == softmaxYall(:));
acc = sum(acc) / size(acc, 1);
fprintf('Accuracy on all: %2.3f%%\n', acc * 100);


