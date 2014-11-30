% Expectation Maximization for Naive Bayes (multi-variate Bernoulli model)
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function nb = myemnb(X, maxiter, smooth)
if nargin < 2
	maxiter = 100;
end

if nargin < 3
	smooth = 0; % not used
end

ncls = 2;
[m n] = size(X);

% initial parameter
% mean not work
%nb.p = ones(ncls, 1) ./ ncls;
%nb.mu = ones(ncls, n) ./ 2; 
% symmetry breaking
nb.p = rand(ncls, 1);
nb.p = nb.p ./ sum(nb.p);
nb.mu = rand(ncls, n); 
nb.mu = bsxfun(@(v1, v2) v1./v2, nb.mu, sum(nb.mu)); 

prob = zeros(ncls, m);
for t = 1:maxiter
	%fprintf('iteration #%d\n', t);
	
	% E-step
	prob = myemnbPredict(nb, X);
	
	% M-step
	sp = sum(prob, 2);
	%assert(sum(sp) == m);
	nb.p = sp ./ m;
	%size(nb.p)
	
	t = prob * X;
	st = sum(t, 2);
	nb.mu = bsxfun(@(v1, v2) v1./v2, t, st);
end
