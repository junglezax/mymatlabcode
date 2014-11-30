% Naive Bayes  (multi-variate Bernoulli model) learning
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function nb = mynaivebayes(X, y, smooth)
if nargin < 3
	smooth = 1;
end

ucls = unique(y);
ncls = length(ucls);
m = length(y);

% 类频率
if smooth
	p = (histc(y, ucls) + 1) ./ (m + ncls); % + for laplace smoothing, or regularization
else
	p = histc(y, ucls) ./ m;
end

% 每一类样本里面，每个可能取值（每个词）出现的次数
mu = [];
for j=1:ncls
	Xj = X(y == ucls(j), :);
	
	if smooth
		mu = [mu; (sum(Xj) + 1) ./ (size(Xj, 1) + 2)]; % for smoothing
	else
		mu = [mu; mean(Xj)]; % 因为是BOOL，可以用mean来算1的频率
	end
end

nb.p = p;
nb.mu = mu;
