% compute cost and gradient for logistic regression
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [J, grad] = logisticRcostFunction(theta, X, y, lambda)

if nargin < 4
	lambda = 0;
end

m = length(y);
n = length(theta);
J = 0;
grad = zeros(size(theta));

h = @(theta, X) sigmoid(X * theta);

J = -(y' * log(h(theta, X)) + (1-y)' * log(1-h(theta, X)))./m + lambda * sum(theta(2:n).^2) / (2 * m);
grad = X' * (h(theta, X) - y)./m;
t = grad(1);
grad = grad + lambda.*theta/m;
grad(1) = t;
end
