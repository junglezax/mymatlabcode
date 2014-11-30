% adaboost classification training
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function boostModel = boostTrain(ftr, fte, X, y, maxiter)
% boostModel: structur of alphas, models
% 步骤
%	初始权 w(i) = 1/m
%	循环
%		X1 = w * X
%		用X1学习参数
%		对训练样本分类
%		计算加权误差率
%		计算分类器权
%		更新样本权w并归一化

if nargin < 4
	 error('Requires at least 3 arguments.')
end;

if nargin < 5
	levels = unique(y);
end;

if nargin < 5
	maxiter = 10;
end;

[m n] = size(X);
 
%	初始权
w = ones(m, 1)./ m;

maxerror = 0.5;
eac = 0.001;

%	循环
learners = {};
boostModel.alphas = zeros(maxiter, 1);
X1 = X;
isbool = strcmp(class(X), 'logical');
for iter = 1:maxiter
	fprintf('boost learning, iteration #%d\n', iter);

	if isbool
		X1 = bsxfun(@gmultiply, X1, w);
		X1 = (X1 >= 1/m);
		if iter == 1
			assert(all(all(X1 == X)));
		end
	else
		[X1, mu, sigma] = featureNormalize(X1);
		X1 = bsxfun(@gmultiply, X1, w);
	end
	
	%		用X1学习参数
	learner = ftr(X1, y);

	%		对训练样本（or 测试样本?）分类
	cls = fte(learner, X1);
	
	%		计算加权误差率
	Icls = (cls ~= y);
	%terr = mean(Icls) % for test
	err = sum(w.*Icls)./sum(w);
	%tw = w([1:5 601:605])'
	
	%		计算分类器权
	alpha = log((1-err)/err); % Breiman ./2
	
	%		更新样本权w并归一化
	w = (w .* exp(-alpha * Icls));
	w = w ./ sum(w);
	
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
	
	boostModel.learners{iter} = learner;
	boostModel.alphas(iter) = alpha;
end;
fprintf('boost learning finished\n');
boostModel.alphas = boostModel.alphas ./ sum(boostModel.alphas);
