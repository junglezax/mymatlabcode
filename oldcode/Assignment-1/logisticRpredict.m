% classification with logistic regression
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [p err] = logisticRpredict(theta, X, y)
[m, n] = size(X);
X = [ones(m, 1) X];
p = (X * theta >= 0);

if nargin > 2
	err = mean(p == y);
end

end
