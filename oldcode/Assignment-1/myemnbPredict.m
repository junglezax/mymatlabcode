% predict with Expectation Maximization for Naive Bayes (multi-variate Bernoulli model)
% compute soft label(prob) and hard label(pred, if required)
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [prob, pred] = myemnbPredict(nb, X)
[m n] = size(X);

ncls = size(nb.mu, 1);
prob = zeros(ncls, m);
for i=1:m
	x = X(i, :);
	for j=1:ncls
		prob(j, i) = nb.p(j) .* prod(x .* nb.mu(j, :) + (1 - x) .* (1 - nb.mu(j, :)));
	end
end

sp = sum(prob);
prob = bsxfun(@(v1, v2) v1./v2, prob, sp);

if nargout >= 2
	[C pred] = max(prob);
	pred = pred - 1;
end
