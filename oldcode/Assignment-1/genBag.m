% generate word-bag for text classification
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function bag = genBag(s)
n = length(s);
allw = {};
for i=1:n
	allw = [allw s{i}];
end

bag = unique(allw);