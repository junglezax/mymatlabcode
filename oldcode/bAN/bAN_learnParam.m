% bAN参数学习
% 输入：G, X, levels, y, maxiter
% 输出：
% 步骤
%	初始权 w(i) = 1/m
%	循环
%		X1 = w * X
%		用X1学习参数
%		对训练样本分类（？）
%		计算加权误差率
%		计算分类器权
%		更新样本权w并归一化

function bAN = bAN_learnParam(G, X, y, levels, maxiter)
bAN = [];

% 参数处理
if nargin < 3
	 error('Requires at least 3 arguments.')
end;

if nargin < 4
	levels = unique(y);
end;

if nargin < 5
	maxiter = 100;
end;

m = size(X, 1);
nfeat = size(X, 2);
n = nfeat+1;

nlevel = length(levels);
 
node_sizes = [ones(1, nfeat) nlevel];
discrete = n;

%	初始权 w(i) = 1/m
w = ones(m, 1) ./ m;

%	循环
iter = 1;
bnets = {};
alpha = zeros(maxiter, 1);
X1 = X;
while iter <= maxiter
	fprintf('learning parameters, iteration #%d\n', iter);
	
	X1 = bsxfun(@gmultiply, X1', w')';
	%sum(sum(X1))
	%XX = [X1 double(y)];
	%XX1 = bsxfun(@gmultiply, X', w')';

	%		用X1学习参数
	bnet = mk_bnet(G, node_sizes, discrete);

	for i=1:nfeat
		bnet.CPD{i} = gaussian_CPD(bnet, i); % random g_CPD
	end
	t = ones(1, nlevel)/nlevel;
	bnet.CPD{n} = tabular_CPD(bnet, n, t);

	bnet = learn_params(bnet, [X1 double(y)]'); %XX1
	
	bnets{iter} = bnet;

	%		对训练样本（or 测试样本?）分类
	[cls, prob, err] = TAN_predict(bnet, X1, levels, y);
	err
	
	%		计算加权误差率
	Icls = (cls ~= y);
	err = sum(w.*Icls)./sum(w);
	%disp('sum(w)='); disp(sum(w))
	
	%		计算分类器权
	alpha(iter) = log((1-err)/err)/2;
	
	%		更新样本权w并归一化
	w = (w .* exp(-alpha(iter) * Icls));
	w = w./sum(w);
	%disp('sum(w)='); disp(sum(w))
	
	iter = iter + 1;
end;
fprintf('parameter learning finished\n');

%bAN.bnets = bnets;
%bAN.alpha = alpha;
% use only the last one
bAN.bnets = cell(1);
bAN.bnets{1} = bnets{iter-1};
bAN.alpha = alpha(iter-1);

disp('here0')
[cls, prob, err] = TAN_predict(bnets{iter-1}, X1, levels, y);
disp('here1')
disp(err)
