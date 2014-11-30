% feature selection for hotel
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11

selfea = idxf(1:nSel)';
X = Xorigin(:, selfea);
%bag(selfea)
%  '不错'    '差'    '恶劣'    '一流'    '答应'    '结算'    '上当'    '冷冰冰'    '笑'    '折腾'    '奉劝'    '旅馆'    '烂'...
%ig1(1:nSel)

Xtr = X(istrain, :);
ytr = y(istrain);
Xte = X(istest, :);
yte = y(istest);

if feanorm
	disp('feature normalizing...');
	[X, normal_mu, normal_sigma] = featureNormalize(X);
	[Xtr, normal_tr_mu, normal_tr_sigma] = featureNormalize(Xtr);
	Xte = featureNormalize(Xte, normal_tr_mu, normal_tr_sigma);
end
