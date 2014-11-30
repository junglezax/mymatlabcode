% read text from raw data file
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function out = readText(fn)
s = textread(fn, '%s');
n = length(s);
out = {};
t = {};
k = 1;
for i=1:n
	w = s{i};
	if strcmp(w, '<text>')
		j = 1;
		t = {};
	else if strcmp(w, '</text>')
		out{k} = t;
		k = k + 1;
	else
		t{j} = w;
		j = j + 1;
	end
end

end;



