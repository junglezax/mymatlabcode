% k-fold cross validation
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [err, errs] = crossvalid(f, X, y, k, cp)

if nargin < 4
	k = 5;
end

if nargin < 5
	cp = cvpartition(y, 'k', k);
end

k = cp.NumTestSets; % when cp given, ignore k

errs = zeros(k, 1);

for i=1:k
	tr = training(cp, i);
	te = test(cp, i);
	
	errs(i) = mean(f(X(tr, :), y(tr), X(te, :)) ~= y(te));
end
err = mean(errs);


