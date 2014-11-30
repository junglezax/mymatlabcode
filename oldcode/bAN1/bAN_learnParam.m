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
%w = ones(m, 1); %./ m;
w = ones(m, 1)./ m;

maxerror = 0.5;
eac = 0.001;

%	循环
iter = 1;
learners = {};
mus = {};
ms = zeros(maxiter, 1);
sigmas = {};
%weights = {};
bAN.alphas = zeros(maxiter, 1);
X1 = X;
while iter <= maxiter
	%fprintf('learning parameters, iteration #%d\n', iter);
	%X1
	[X1, mu, sigma] = featureNormalize(X1);
	%mu
	%sigma
	X1 = bsxfun(@gmultiply, X1', w')';
	%m
	%w
	mus{iter} = mu;
	ms(iter) = m;
	sigmas{iter} = sigma;
	
	%sum(sum(X1))
	%XX = [X1 double(y)];
	%XX1 = bsxfun(@gmultiply, X', w')';
	%w'

	%		用X1学习参数
	%disp('use uniform prior and kernel...');
	nb = NaiveBayes.fit(X1, y); %, 'Prior', 'uniform', 'Distribution', 'kernel'

	%weights{iter} = w;
	learners{iter} = nb;

	%		对训练样本（or 测试样本?）分类
	cls = nb.predict(X1);
	
	%		计算加权误差率
	Icls = (cls ~= y);
	fprintf('err=%f\n', mean(cls ~= y));
	%err = sum(w.*Icls)./sum(w);
	%fprintf('after normalize err=%.32f sum(w.*Icls)=%f sum(w)=%f\n', err*1e190, sum(w.*Icls), sum(w));
	
	% 计算 F1 score
	f1 = f1_score(y, cls);
	fprintf('f1=%f\n', f1);
	err = 1 - f1;
	
	% 计算分类器权
	alpha = log((1-err)/err)/2;
	
	% 更新样本权w并归一化
	w = (w .* exp(-alpha * Icls));
	%w = w .* m ./ sum(w);
	w = w ./ sum(w);
	%disp('sum(w)='); disp(sum(w))
	
	% 特殊情况处理，避免出现Inf, NaN
	% 参考adabag.boosting.R
    if  err >= maxerror
        w = ones(m, 1)./ m;
        maxerror = maxerror - eac;
        alpha = log((1 - maxerror)/maxerror);
    end
	
    if err == 0
        w = ones(m, 1)./ m;
        alpha = log((1 - eac)/eac);
	end

	bAN.alphas(iter) = alpha;
	%fprintf('alpha=%f\n', alpha);

	iter = iter + 1;
end;
fprintf('parameter learning finished\n');

%bAN.weights = weights;
bAN.mus = mus;
bAN.ms = ms;
bAN.sigmas = sigmas;
bAN.learners = learners;
%use only the last one
%bAN.learners = cell(1);
%bAN.learners{1} = learners{iter-1};
%bAN.alphas = bAN.alphas(iter-1);

