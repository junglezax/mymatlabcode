function options = cnnOptions()

options.imageDim = 487;
options.patchDim = 8;
options.poolDim = 24;          % dimension of pooling region % (imageDim - patchDim + 1)/poolDim = int
options.imageChannels = 3;     % number of channels (rgb, so 3)
options.numPatches = 100000;   % number of patches
options.hiddenSize  = 400;           % number of hidden units 
options.stepSize = 10; % step size for cnnConvolve and pooling, hiddenSize / stepSize = int
options.sparsityParam = 0.035; % desired average activation of the hidden units.
options.lambda = 3e-3;         % weight decay parameter       
options.beta = 5;              % weight of sparsity penalty term       
options.epsilon = 0.1;	       % epsilon for ZCA whitening
options.maxIter = 400;
options.softmaxIter = 200;
options.labelLevel = 1;
options.softmaxLambda = 1e-4;
options.save = false;

%imgDirs = {'png97', 'yes', 'msmp1', 'msmp2', 'msmp3', 'msmp4', 'msmp5', 'msmp6', 'msmp7', 'msmp8', 'msmp9', 'msmp10', 'msmp11', 'msmp12', 'msmp13', 'msmp14'};
options.imgDir = '../../../images/chairs';
options.dataDir = '../../../data';

% for debug
if 1
options.imgDir = '../../../images/nope';
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