% classification with adaboost
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [p, prob, err] = boostPredict(boostModel, fte, levels, X, y)
[m n] = size(X);
k = length(boostModel.alphas);

p = zeros(m, 1);
nlevel = length(levels);
probTotal = zeros(m, nlevel);

isbool = strcmp(class(X), 'logical');
if isbool
	X1 = X;
else
	X1 = featureNormalize(X)./m;
end

for i=1:k
	fprintf('boostModel predicting ... weak learner #%d\n', i);
	p = fte(boostModel.learners{i}, X1);
	prob = zeros(m, nlevel);
	for t=1:m
		prob(t, p(t)+1) = 1;
	end
	%prob
	probTotal = probTotal + boostModel.alphas(i) .* prob;
end

[mm, p] = max(probTotal, [], 2);
p = p - 1;

prob = probTotal;

if nargout > 2
	err = mean(p ~= y);
end;
