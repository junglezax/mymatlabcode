function [cls, prob, err] = bAN_predict(bAN, X, levels, y)

m = size(X, 1);
nfeat = size(X, 2);
n = nfeat+1;
k = length(bAN.alphas);
nlevel = length(levels);

cls = zeros(m, 1);
probTotal = zeros(m, nlevel);
for i=1:k
	fprintf('bAN predicting ... weak learner #%d\n', i);
%	w = bAN.weights{i};
%	w = mean(w)
%	w .* X
	%X
	%mu = bAN.mus{i}
	%sigma = bAN.sigmas{i}
	m = bAN.ms(i);
	X1 = featureNormalize(X)./m;
	cls = bAN.learners{i}.predict(X1);
	prob = zeros(m, nlevel);
	for t=1:m
		prob(t, cls(t)) = 1;
	end
	probTotal = probTotal + bAN.alphas(i) .* prob;
end

%bsxfun(@(m, v) find(m == v, 1), probTotal', mm'); % Invalid output dimensions
[mm, cls] = max(probTotal, [], 2);

prob = probTotal;

if nargout > 2
	err = mean(cls ~= y);
end;