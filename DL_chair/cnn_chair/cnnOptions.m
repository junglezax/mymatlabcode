function options = cnnOptions(useSAE)

if ~exist('useSAE', 'var')
	useSAE = false;
end

options.imageDim = 487;
options.patchDim = 8;
options.poolDim = 24;          % dimension of pooling region % (imageDim - patchDim + 1)/poolDim = int
options.imageChannels = 3;     % number of channels (rgb, so 3)
options.numPatches = 10000;   % number of patches
options.hiddenSize  = 20;           % number of hidden units 
options.stepSize = 10; % step size for cnnConvolve and pooling, hiddenSize / stepSize = int

options.sparsityParam = 0.035; % desired average activation of the hidden units.
options.lambda = 3e-3;         % weight decay parameter       
options.beta = 5;              % weight of sparsity penalty term

options.epsilon = 0.1;	       % epsilon for ZCA whitening
options.maxIter = 100;

options.softmaxIter = 100;
options.softmaxLambda = 1e-4;

options.labelLevel = 1;
options.save = false;
options.display = 'Off';

%imgDirs = {'png97', 'yes', 'msmp1', 'msmp2', 'msmp3', 'msmp4', 'msmp5', 'msmp6', 'msmp7', 'msmp8', 'msmp9', 'msmp10', 'msmp11', 'msmp12', 'msmp13', 'msmp14'};
options.imgDir = '../../../images/chairs'; % maybe not used
options.dataDir = '../../../data/';

options.classMethod = 'softmax'; % softmax/svm


if useSAE
options.sparsityParam = 0.1;
options.beta = 3;
options.softmaxIter = 100;

options.hiddenSizeL1 = 100;
options.hiddenSizeL2 = 100;
end

% for debug
if 0
%options.imgDir = '../../../images/nope';
options.imageDim = 15;
options.patchDim = 4;
options.poolDim = 4;          % dimension of pooling region % (imageDim - patchDim + 1)/poolDim = int
options.imageChannels = 3;     % number of channels (rgb, so 3)
options.numPatches = 10;   % number of patches
options.hiddenSize  = 4;           % number of hidden units 
options.stepSize = 2; % hiddenSize / stepSize = int
options.maxIter = 10;
options.softmaxIter = 5;
end

options.numClasses = code2label(options.labelLevel);

assert(mod(options.hiddenSize, options.stepSize) == 0, 'stepSize should divide hiddenSize');
assert(mod((options.imageDim - options.patchDim + 1), options.poolDim) == 0, 'poolDim should divide (imageDim - patchDim + 1)');

end
