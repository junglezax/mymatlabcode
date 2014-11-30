% classification with Naive Bayes (multi-variate Bernoulli model)
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [p err] = mynaivebayesPredict(nb, X, y)
[m n] = size(X);
ncls = size(nb.mu, 1);
prob = zeros(m, ncls);
for i=1:m
	x = X(i, :);
	for j=1:ncls
		prob(i, j) = nb.p(j) .* prod(x .* nb.mu(j, :) + (1 - x) .* (1 - nb.mu(j, :)));
	end
end

[C p] = max(prob, [], 2);

p = p - 1;

if (nargin > 2)
	err = mean(p ~= y);
end

