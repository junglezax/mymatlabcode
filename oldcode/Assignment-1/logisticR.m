% logistic regression training
% from ML.Ng mlclass-ex2
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [theta, cost] = logisticR(X, y, lambda)

if nargin < 3
	lambda = 0;
end

m = size(X, 1);
X = [ones(m, 1) X];
n = size(X, 2);
initial_theta = zeros(n, 1);
%[cost, grad] = logisticRcostFunction(initial_theta, X, y);

options = optimset('GradObj', 'on', 'MaxIter', 400, 'Display', 'off');
[theta, cost] = fminunc(@(t)(logisticRcostFunction(t, X, y, lambda)), initial_theta, options);