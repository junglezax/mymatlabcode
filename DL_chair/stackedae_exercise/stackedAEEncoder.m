function [out] = stackedAEEncoder(theta, hiddenSize, numClasses, netconfig, data)
                                         
% stackedAEPredict: Takes a trained theta and a test data set,
% and returns the predicted labels for each example.
                                         
% theta: trained weights from the autoencoder
% hiddenSize:  the number of hidden units *at the 2nd layer*
% numClasses:  the number of categories
% data: Our matrix containing the training data as columns.  So, data(:,i) is the i-th training example. 

% We first extract the part which compute the softmax gradient
softmaxTheta = reshape(theta(1:hiddenSize*numClasses), numClasses, hiddenSize);

% Extract out the "stack"
stack = params2stack(theta(hiddenSize*numClasses+1:end), netconfig);

a1 = data;

z2 = stack{1}.w * a1 + repmat(stack{1}.b, 1, size(a1, 2));
a2 = sigmoid(z2);
										
z3 = stack{2}.w * a2 + repmat(stack{2}.b, 1, size(a2, 2));
out = sigmoid(z3);

end
