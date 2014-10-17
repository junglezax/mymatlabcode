% translate matlab matrix to libsvm format
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function fn = tolibsvm(X, y, fn)
nfeat = size(X, 2);

fmt='';
for i=1:nfeat
	fmt = strcat(fmt, sprintf('%d', i), ':%f\t');
end

fmt = strcat('%d\t', fmt, '\n');

X1 = [y X]';

sprintf(fmt, X1);

fid = fopen(fn, 'w');
fwrite(fid, sprintf(fmt, X1));
fclose(fid);
