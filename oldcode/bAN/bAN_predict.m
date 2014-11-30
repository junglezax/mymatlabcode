function [cls, prob, err] = bAN_predict(bAN, X, levels, y)
% classify new samples with bAN (boosted augmented naive bayes)
% parameter:
%   bAN:
%   X:
%     assumptions: 
%       each of the features is continuous and belongs to gaussian distribution.
%       class variable is discrete.
% return:
%   cls: classification results
%
% author: nullspace(jxhchina at gmail.com)
% last updated: 

m = size(X, 1);
nfeat = size(X, 2);
n = nfeat+1;
k = length(bAN.alpha);
nlevel = length(levels);

cls = zeros(m, 1);
probTotal = zeros(m, nlevel);
for i=1:k
	fprintf('bAN predicting ... learner #%d\n', i);
	bAN.bnets{i}
	X
	levels
	[cls, prob] = TAN_predict(bAN.bnets{i}, X, levels);
	%prob
	%bAN.bnets{i}
	probTotal = probTotal + bAN.alpha(i) .* prob;
end

%cls = bsxfun(@(m, v) find(m == v, 1), probTotal, max(probTotal, [], 2));

if nargout > 2
	err = mean(cls ~= y);
end;