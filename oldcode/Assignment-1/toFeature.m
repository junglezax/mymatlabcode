% word index to TF feature vector
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function f = toFeature(pos, len)
% t = tabulate(a), ok but
% http://stackoverflow.com/questions/2880933/how-can-i-count-the-number-of-elements-of-a-given-value-in-a-matrix
f = full(sparse(pos,1,1));
f = [f; zeros(len - length(f), 1)];

