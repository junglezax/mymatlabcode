function [accTest, predTest, accAll, predAll, runOptions, out, data] = runIt(dataFrom, data)
% dataFrom: read, load, none
% example: [accTest, predTest, accAll, predAll, runOptions, out, data] = runIt();
%          [accTest, predTest, accAll, predAll, runOptions, out, data] = runIt('load');
%          [accTest, predTest, accAll, predAll, runOptions, out] = runIt('none', data);
%          tic; [accTest, predTest, accAll, predAll, runOptions, out, data] = runIt(); usetime = toc

if ~exist('dataFrom', 'var')
	dataFrom = 'read';
end

% parameters
runOptions = cnnOptions();
visibleSize = runOptions.patchDim * runOptions.patchDim * runOptions.imageChannels;  % number of input units, also is outputSize

% load images
if ~strcmp(dataFrom, 'none')
	data = load_it(runOptions);
end

% sample train images to train patches for train AE
disp('sampling patches from images...');
patches = sampleIMAGES_color(data.img_resized, runOptions.patchDim, runOptions.numPatches);
disp('sampling patches from images finished');

%displayColorNetwork(data.x(:, 1:9));
%displayColorNetwork(patches(:, 1:81));

% do ZCA
meanPatch = mean(patches, 2);
patches = bsxfun(@minus, patches, meanPatch);

% Apply ZCA whitening
sigma = patches * patches' / runOptions.numPatches;
[u, s, v] = svd(sigma);
ZCAWhite = u * diag(1 ./ sqrt(diag(s) + runOptions.epsilon)) * u';
patches = ZCAWhite * patches;

% train linear AE, got feature filter matrix
theta = initializeParameters(runOptions.hiddenSize, visibleSize);

options = struct;
options.Method = 'lbfgs'; 
options.maxIter = runOptions.maxIter;
options.display = 'on';

disp('training linear encoder...');
[optTheta, cost] = minFunc( @(p) sparseAutoencoderLinearCost(p, ...
                                   visibleSize, runOptions.hiddenSize, ...
                                   runOptions.lambda, runOptions.sparsityParam, ...
                                   runOptions.beta, patches), ...
                              theta, options);
disp('training linear encoder finished');

out = struct;
out.optTheta = optTheta;
out.ZCAWhite = ZCAWhite;
out.meanPatch = meanPatch;

fprintf('Saving\n');
save('../../../data/chairLinearFeatures.mat', 'optTheta', 'ZCAWhite', 'meanPatch');
fprintf('Saved\n');

%load ../../../data/chair97LinearFeatures.mat

W = reshape(optTheta(1:visibleSize * runOptions.hiddenSize), runOptions.hiddenSize, visibleSize);
b = optTheta(2*runOptions.hiddenSize*visibleSize+1:2*runOptions.hiddenSize*visibleSize+runOptions.hiddenSize);

%displayColorNetwork( (W*ZCAWhite)');

% load train images and test images 问题来了：这里的图像和train AE用的图像是一批吗�?
labeledImages = data.img_resized; % use same image set with feature extracting

%trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
%testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

%[trainImages, trainLabels, testImages, testLabels] = sampleData4d(labeledImages, data.labels, trainSet, testSet);
[trainImages, trainLabels, testImages, testLabels, trainSet, testSet] = sampleData4d(labeledImages, data.labels);

numTrainImages = numel(trainSet);
numTestImages = numel(testSet);

% do convolution and pooling to train and test images, got pooled features
pooledFeaturesTrain = zeros(runOptions.hiddenSize, numTrainImages, ...
    floor((runOptions.imageDim - runOptions.patchDim + 1) / runOptions.poolDim), ...
    floor((runOptions.imageDim - runOptions.patchDim + 1) / runOptions.poolDim) );
pooledFeaturesTest = zeros(runOptions.hiddenSize, numTestImages, ...
    floor((runOptions.imageDim - runOptions.patchDim + 1) / runOptions.poolDim), ...
    floor((runOptions.imageDim - runOptions.patchDim + 1) / runOptions.poolDim) );

%tic();

disp('convolving & pooling for features...');

for convPart = 1:(runOptions.hiddenSize / runOptions.stepSize)
    
    featureStart = (convPart - 1) * runOptions.stepSize + 1;
    featureEnd = convPart * runOptions.stepSize;
    
    fprintf('Step %d: features %d to %d\n', convPart, featureStart, featureEnd);  
    Wt = W(featureStart:featureEnd, :);
    bt = b(featureStart:featureEnd);
    
    fprintf('Convolving and pooling train images\n');
    convolvedFeaturesThis = cnnConvolve(runOptions.patchDim, runOptions.stepSize, ...
        trainImages, Wt, bt, ZCAWhite, meanPatch);
    pooledFeaturesThis = cnnPool(runOptions.poolDim, convolvedFeaturesThis);
    pooledFeaturesTrain(featureStart:featureEnd, :, :, :) = pooledFeaturesThis;   
    %toc();
    clear convolvedFeaturesThis pooledFeaturesThis;
    
    fprintf('Convolving and pooling test images\n');
    convolvedFeaturesThis = cnnConvolve(runOptions.patchDim, runOptions.stepSize, ...
        testImages, Wt, bt, ZCAWhite, meanPatch);
    pooledFeaturesThis = cnnPool(runOptions.poolDim, convolvedFeaturesThis);
    pooledFeaturesTest(featureStart:featureEnd, :, :, :) = pooledFeaturesThis;   
    %toc();

    clear convolvedFeaturesThis pooledFeaturesThis;
end

disp('convolving & pooling for features finished');

out.pooledFeaturesTrain = pooledFeaturesTrain;
out.pooledFeaturesTest = pooledFeaturesTest;

disp('saving')
save('../../../data/cnnPooledFeaturesChairs.mat', 'pooledFeaturesTrain', 'pooledFeaturesTest');

% train classifier using pooled features
addpath ../../UFLDL/softmax_exercise

% Reshape the pooledFeatures to form an input vector for softmax
softmaxXtrain = permute(pooledFeaturesTrain, [1 3 4 2]);
softmaxXtrain = reshape(softmaxXtrain, numel(pooledFeaturesTrain) / numTrainImages,...
    numTrainImages);
softmaxYtrain = trainLabels;

options = struct;
options.maxIter = runOptions.softmaxIter;


disp('training softmax...');
softmaxModel = softmaxTrain(numel(pooledFeaturesTrain) / numTrainImages,...
    runOptions.numClasses, runOptions.softmaxLambda, softmaxXtrain, softmaxYtrain, options);
disp('training softmax finished');

% show key params
sprintf('imgdir: %s\n', runOptions.imgDir);
sprintf('imgCnt: %d\n', numel(data.fns));
sprintf('badCnt: %s\n', data.badCnt);
sprintf('imageDim=%d, patchDim=%d, poolDim=%d, hiddenSize=%d, numClasses=%d, numPatches=\n', runOptions.imageDim, runOptions.poolDim, runOptions.patchDim, runOptions.hiddenSize, runOptions.numClasses, runOptions.numPatches);

% test classifier
disp('predicting for test data')
softmaxXtest = permute(pooledFeaturesTest, [1 3 4 2]);
softmaxXtest = reshape(softmaxXtest, numel(pooledFeaturesTest) / numTestImages, numTestImages);
softmaxYtest = testLabels;

[predTest] = softmaxPredict(softmaxModel, softmaxXtest);
accTest = (predTest(:) == softmaxYtest(:));
accTest = sum(accTest) / size(accTest, 1);
fprintf('Accuracy: %2.3f%%\n', accTest * 100);

% test on all examples
disp('predicting for all data')
softmaxXall = [softmaxXtrain softmaxXtest];
softmaxYall = [trainLabels; testLabels];

[predAll] = softmaxPredict(softmaxModel, softmaxXall);
accAll = (predAll(:) == softmaxYall(:));
accAll = sum(accAll) / size(accAll, 1);
fprintf('Accuracy on all: %2.3f%%\n', accAll * 100);

end
