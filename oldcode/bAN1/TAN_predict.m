function [cls, prob, err] = TAN_predict(bnet, X, levels, y)
% classify(predict the class label of) new samples with TAN (tree augmented naive bayes)
% parameter:
%   bnet: a Bayesian network object (see mk_bnet.m of BNT, https://code.google.com/p/bnt)
%   X:
%     assumptions: 
%       each of the features is continuous and belongs to gaussian distribution.
%       class variable is discrete.
% return:
%   cls: classification results
%
% author: nullspace(jxhchina at gmail.com)
% last updated: 

m = size(X, 1);
nfeat = size(X, 2);
n = nfeat+1;
nlevel = length(levels);

engine = jtree_inf_engine(bnet);

cls = zeros(m, 1);
prob = zeros(m, nlevel);
%bnet
for i=1:m
	x = X(i, :)';
	cx = mat2cell(x, ones(length(x), 1));
	cx{n}=[];
	[engine1, loglik] = enter_evidence(engine, cx);
	mg = marginal_nodes(engine1, n);
	%size(prob(i, :))
	%size(mg.T)
	%disp(mg.T')
	%disp(sum(mg.T)) % 正常全是1
	%size(mg.T) %4x1的可以赋值给1x4的，长见识了
	%size(prob(i, :))
	
	%get_field(bnet.CPD{8}, 'cpt')
		%draw_graph(bnet.dag)
		for fker = 1:length(bnet.CPD)-1
			%disp(get_field(bnet.CPD{fker}, 'mean'))
		end
	if all(mg.T == 0)
		%cx
		%i
		error('you are fucked!')
	end
	%pause
	prob(i, :) = mg.T;
	%prob
	idx = find(mg.T == max(mg.T));
	cls(i) = idx(1);
end

if nargout > 2
	err = mean(cls ~= y);
end;