function [ cost, grad ] = stackedAECost(theta, inputSize, hiddenSize, ...
                                              numClasses, netconfig, ...
                                              lambda, data, labels)
                                         
% stackedAECost: Takes a trained softmaxTheta and a training data set with labels,
% and returns cost and gradient using a stacked autoencoder model. Used for
% finetuning.
                                         
% theta: trained weights from the autoencoder
% visibleSize: the number of input units
% hiddenSize:  the number of hidden units *at the 2nd layer*
% numClasses:  the number of categories
% netconfig:   the network configuration of the stack
% lambda:      the weight regularization penalty
% data: Our matrix containing the training data as columns.  So, data(:,i) is the i-th training example. 
% labels: A vector containing labels, where labels(i) is the label for the
% i-th training example


%% Unroll softmaxTheta parameter

% We first extract the part which compute the softmax gradient
softmaxTheta = reshape(theta(1:hiddenSize*numClasses), numClasses, hiddenSize);

% Extract out the "stack"
stack = params2stack(theta(hiddenSize*numClasses+1:end), netconfig);

stackgrad = cell(size(stack));
for d = 1:numel(stack)
    stackgrad{d}.w = zeros(size(stack{d}.w));
    stackgrad{d}.b = zeros(size(stack{d}.b));
end

% You might find these variables useful
m = size(data, 2);
groundTruth = full(sparse(labels, 1:m, 1));
maxLabel = max(labels); %may be some labels not used
groundTruth(maxLabel+1:numClasses, :) = 0;

%% -------------------
% forward

a1 = data;

z2 = stack{1}.w * a1 + repmat(stack{1}.b, 1, size(a1, 2));
a2 = sigmoid(z2);
										
z3 = stack{2}.w * a2 + repmat(stack{2}.b, 1, size(a2, 2));
a3 = sigmoid(z3);

% softmax layer
M = softmaxTheta * a3;
M = bsxfun(@minus, M, max(M, [], 1));
eM = exp(M);
eM = bsxfun(@rdivide, eM, sum(eM));

%% -------------------
% backward

t = (groundTruth - eM);

softmaxThetaGrad = -1/numClasses * t * a3' + lambda * softmaxTheta; % why?

%cost = sum(sum(t.^2, 2)) ./ (2 * m) + (sum(sum(stack{1}.w.^2)) + sum(sum(stack{2}.w.^2))) .* lambda ./ 2;
cost = -1/numClasses * groundTruth(:)' * log(eM(:)) + lambda/2 * sum(softmaxTheta(:) .^ 2); % why?

delta3 = -(softmaxTheta' * t) .* a3 .* (1 - a3); % why?

stackgrad{2}.w = delta3 * a2';
stackgrad{2}.b = sum(delta3, 2);

delta2 = stack{2}.w' * delta3 .* sigmoidGradient(z2);
	
stackgrad{1}.w = delta2 * a1';
stackgrad{1}.b = sum(delta2, 2);

stackgrad{1}.w = stackgrad{1}.w ./ numClasses; % + stack{1}.w .* lambda;
stackgrad{2}.w = stackgrad{2}.w ./ numClasses; % + stack{2}.w .* lambda;
stackgrad{1}.b = stackgrad{1}.b ./ numClasses;
stackgrad{2}.b = stackgrad{2}.b ./ numClasses;

% -------------------------------------------------------------------------

%% Roll gradient vector
grad = [softmaxThetaGrad(:) ; stack2params(stackgrad)];

end


% You might find this useful
function sigm = sigmoid(x)
    sigm = 1 ./ (1 + exp(-x));
end
