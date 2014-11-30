% word index to TF vectors
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function r = toFeatures(idxs, len)
n = length(idxs);
r = zeros(n, len);
for i=1:n
	r(i, :) = toFeature(idxs{i}, len);
end