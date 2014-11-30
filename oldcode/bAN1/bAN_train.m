% bAN_train:
%	输入：X, y, maxiter
%	输出：bAN, cls, prob, err 即 bAN对象，训练样本分类结果，预测概率，误差率
%	结构学习 bAN_learnStru
%	参数学习 bAN_learnParam
%	对训练样本预测 bAN_predict

function [bAN, cls, prob, err] = bAN_train(X, y, maxiter)
% 参数处理
if nargin < 2
	 error('Requires at least 2 arguments.')
end;

if nargin < 3
	maxiter = 100;
end;

m = size(X, 1);
nfeat = size(X, 2);
n = nfeat+1;

levels = unique(y);
nlevel = length(levels);
 
node_sizes = [ones(1, nfeat) nlevel];

% 生成 完全图（计算MI信息）
G_full = zeros(n); %bAN_genGfull(X, y); % TODO

% 生成 TAN 结构
G_tan = learn_struct_tan([X double(y)]', n, 1, node_sizes, 'mutual_info');
maxiter = 3;%min(maxiter, cntSide(G_tan)); % TODO 不应超过边数

% G1 = naive bayes
% 邻接矩阵表示：行表示边的起始顶点，列表示终结顶点，比如8行1列为1，表示从顶点8到顶点1有条边
G1 = zeros(n);
G1(n, 1:n-1) = 1;

% 出现了一个神奇的事情：err=03, lasterr未定义，但err-lasterr一个1行41列的向量，
% 输入lasterr时提示Undefined function or variable 'lasserr'，输入size(lasterr)是1行41列的向量；
% 原来是个内部函数。。。 help lasterr: lasterr Last error message.

G = G_tan; % TODO
lastErr = 1;
eps = 1e-2;
iter = 1;
% 对G循环
while 1
	fprintf('bAN training iterator#%d\n', iter);
	
	bAN = bAN_learnParam(G, X, y, levels, 15); % TODO

	[cls, prob, err] = bAN_predict(bAN, X, levels, y);
	
	% TODO 这里收敛阈值的选择还要考虑样本数，假如只有50个样本，错分的如果不是0那么最少是1个，也许需要用错分样本数
	err = 1;
	if abs(err - lastErr) <= eps | iter >= maxiter
		break;
	end
	
	%G = bAN_genNewG(G, G_tan, G_full); % TODO 
	
	lastErr = err;
	iter = iter + 1;
end;

% 对训练样本分类
% 用最后一个bAN
if nargout > 1
	[cls, prob, err] = bAN_predict(bAN, X, levels, y);
end