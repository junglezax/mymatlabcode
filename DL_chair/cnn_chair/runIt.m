function [accTest, predTest, accAll, predAll, options, model, out, data] = runIt(dataFrom, data)
% dataFrom: read, load, none
% example: [accTest, predTest, accAll, predAll, options, model, out, data] = runIt();
%          [accTest, predTest, accAll, predAll, options, model, out, data] = runIt('load');
%          [accTest, predTest, accAll, predAll, options, model, out] = runIt('none', data);
%          tic; [accTest, predTest, accAll, predAll, options, model, out, data] = runIt(); usetime = toc

if ~exist('dataFrom', 'var')
	dataFrom = 'read';
end

out = struct;
model = struct;

% parameters
options = cnnOptions();
visibleSize = options.patchDim * options.patchDim * options.imageChannels;  % number of input units, also is outputSize

tic;
% load images
if ~strcmp(dataFrom, 'none')
	disp('loading images');
	data = load_it(options.imgDir, options, true);
	disp('finish loading images');
	toc;
end

% sample train images to train patches for train AE
disp('sampling patches from images...');
patches = sampleIMAGES_color(data.img_resized, options.patchDim, options.numPatches);
disp('sampling patches from images finished');
toc;

%displayColorNetwork(data.x(:, 1:9));
%displayColorNetwork(patches(:, 1:81));

% do ZCA
disp('doing ZCA...');

meanPatch = mean(patches, 2);
patches = bsxfun(@minus, patches, meanPatch);

% Apply ZCA whitening
sigma = patches * patches' / options.numPatches;
[u, s, v] = svd(sigma);
ZCAWhite = u * diag(1 ./ sqrt(diag(s) + options.epsilon)) * u';
patches = ZCAWhite * patches;

disp('finish doing ZCA...');
toc;

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
toc;

model.optTheta = optTheta;
model.ZCAWhite = ZCAWhite;
model.meanPatch = meanPatch;

if options.save
	fprintf('Saving LAE model\n');
	save([options.dataDir '/chairLinearFeatures.mat'], 'model');
	fprintf('Saved\n');
	toc;
end

%load ../../../data/chair97LinearFeatures.mat

W = reshape(optTheta(1:visibleSize * options.hiddenSize), options.hiddenSize, visibleSize);
b = optTheta(2*options.hiddenSize*visibleSize+1:2*options.hiddenSize*visibleSize+options.hiddenSize);

%displayColorNetwork( (W*ZCAWhite)');

% load train images and test images
labeledImages = data.img_resized; % use same image set with feature extracting

%trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
%testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

%[trainData, trainLabels, testData, testLabels] = sampleData4d(labeledImages, data.labels, trainSet, testSet);

disp('sampling for train...');
out.sampleOut = sampleData4d(labeledImages, data.labels);
disp('finish sampling for train...');
toc;

disp('computing train features...');
out.trainFeatures = cnnComputeFeature(model, out.sampleOut.trainData, options);
disp('finish computing train features...');
toc;

disp('training softmax...');
model.softmaxModel = trainSoftmax(out.trainFeatures, out.sampleOut.trainLabels, options);
disp('training softmax finished');
toc;

if options.save
    disp('saving out')
    save([runOption.dataDir '/cnnPooledFeaturesChairs.mat'], 'out');
	disp('finish saving out');
	toc;
end

% test classifier
disp('computing features for test data')
out.testFeatures = cnnComputeFeature(model, out.sampleOut.testData, options);
disp('finish computing features for test data');
toc;


disp('predicting for test data')
[accTest, predTest] = testSoftmax(model.softmaxModel, out.testFeatures, out.sampleOut.testLabels);
disp('finish predicting for test data')
toc;

% test on all examples
disp('predicting for all data')
allFeatures = [out.trainFeatures out.testFeatures];
allLabels = [out.sampleOut.trainLabels; out.sampleOut.testLabels];

[accAll, predAll] = testSoftmax(model.softmaxModel, allFeatures, allLabels);
disp('finish predicting for all data')
toc;

disp('show key params:');
fprintf('imgdir: %s\n', options.imgDir);
fprintf('imgCnt: %d\n', numel(data.fns));
fprintf('badCnt: %d\n', data.badCnt);
fprintf('imageDim=%d, patchDim=%d, poolDim=%d, hiddenSize=%d, numClasses=%d, numPatches=%d\n', options.imageDim, options.patchDim, options.poolDim, options.hiddenSize, options.numClasses, options.numPatches);

end
