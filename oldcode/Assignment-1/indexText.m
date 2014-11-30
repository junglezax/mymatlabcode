% word to index of bag
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function r = indexText(s, bag)
r = {};
n = length(s);
for i=1:n
	[tf, r{i}] = ismember(s{i}, bag);
end
