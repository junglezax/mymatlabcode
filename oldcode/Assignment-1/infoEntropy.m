% compute information entropy
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function e = infoEntropy(x, isbool)
m = length(x);

	if isbool
		sxi = sum(x);
		cnt = [m-sxi; sxi];
	else
		cnt = histc(x, unique(x));
	end
p = cnt ./ m;
e = -sum(p .* log2(p));