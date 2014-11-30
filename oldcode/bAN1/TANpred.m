function pred = TANpred(bnet, newdata)
% classify(predict the class label of) new samples with TAN (tree augmented naive bayes)
% parameter:
%   bnet: a Bayesian network object (see mk_bnet.m of BNT, https://code.google.com/p/bnt)
%   newdata: samples to classify, nfeat by m matrix, where m=number of samples, nfeat=number of features
%     assumptions: 
%       each of the features is continuous and belongs to gaussian distribution.
%       class variable is discrete.
% return:
%   pred: classification results
%
% author: nullspace(jxhchina at gmail.com)
% last updated: 17:31 2013/11/12

nfeat = size(newdata, 1);
m = size(newdata, 2);
n = nfeat+1;

engine = jtree_inf_engine(bnet);

pred = zeros(1, m);
for i=1:m
	x = newdata(:, i);
	cx = mat2cell(x, ones(length(x), 1));
	cx{n}=[];
	[engine1, loglik] = enter_evidence(engine, cx);
	mg = marginal_nodes(engine1, n);
	idx = find(mg.T == max(mg.T));
	pred(i) = idx(1);
end
