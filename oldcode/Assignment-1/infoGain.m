% compute information gain ratio
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function r = infoGain(X, y, j)

if nargin < 3
	j = 0; % for all
end

isbool = strcmp(class(X), 'logical');

n = size(X, 2);
rng = 1:n;
if j ~= 0
	rng = j:j
end

ec = infoEntropy(y, false);
ucls = unique(y);
r = zeros(length(rng), 1);
m = length(y);
for i = rng
	Xi = X(:, i);
	uXi = unique(Xi);
	if isbool
		sxi = sum(Xi);
		cnt = [m-sxi; sxi];
	else
		cnt = histc(Xi, uXi);
	end
	
	p = cnt ./ m;
	% 这里用TRUE的时候结果会很奇怪，不知道为啥
	ev = arrayfun(@(v) infoEntropy(y(Xi == v), false), uXi);
	r(i) = ec - p' * ev;

	% gain ratio
	ei = infoEntropy(X(:, i), isbool);
	r(i) = r(i) ./ ei;
end
