function [X_norm, mu, sigma] = featureNormalize(X, mu, sigma)
%FEATURENORMALIZE Normalizes the features in X 
%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. This is often a good preprocessing step to do when
%   working with learning algorithms.

if nargin < 2
	mu = zeros(1, size(X, 2));
	sigma = zeros(1, size(X, 2));

	mu = mean(X);
	sigma = std(X);
end

X_norm = X;
t = bsxfun(@minus, X, mu);
X_norm = bsxfun(@rdivide, t, sigma);

end
