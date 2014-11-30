% predict with GMM
% compute soft label(prob) and hard label(pred, if required)
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
function [prob, pred] = myGMMPredict(nb, X)
[m n] = size(X);

ncls = size(nb.mu, 1);
prob = zeros(ncls, m);
%floggauss = @(x, mu, sigma) -((x-mu) * pinv(sigma) * (x-mu)' + log(det(sigma)) + n .* log(2*pi))./2; % or pinv?

disp('GMM predicting...')
for j=1:ncls
	for i=1:m
		%fprintf('myGMMPredict: j=%d i=%d\n', j, i)

		x = X(i, :);

		%size(x)
		%size(nb.mu(j,:))
		%size(nb.sigma(:, :, j))
		%disp('nb.sigma(:, :, j)'); nb.sigma(:, :, j)
		%disp('det(nb.sigma(:, :, j))'); det(nb.sigma(:, :, j))

		logf = floggauss(x, nb.mu(j,:), nb.sigma(:, :, j));
		prob(j, i) = nb.p(j) .* exp(logf);
		
		if i==1041
			disp('1041----')
			disp('prob(j, i)')
			prob(j, i)
			disp('nb.p(j)')
			nb.p(j)
			logf
			%X(1041, :)大部分都是0
			% exp(-1.0027e+03)==0，确实为0
		end

		if isnan(prob(j, i)) | isinf(prob(j, i))
			fprintf('myGMMPredict prob NaN or Inf found: j=%d i=%d prob(j,i):\n', j, i)
			prob(j, i)
			disp('nb.sigma(1:10, 1:10, j)'); nb.sigma(1:10, 1:10, j)
			disp('det(nb.sigma(:, :, j))'); det(nb.sigma(:, :, j))
			error('NaN or Inf found')
		end
	end
end

sp = sum(prob);

%fprintf('myGMMPredict: prob:\n'); prob
probold = prob;
prob = bsxfun(@(v1, v2) v1./v2, prob, sp);
%fprintf('myGMMPredict: prob after divide:\n'); prob

		if any(isnan(prob(:))) | any(isinf(prob(:)))
			fprintf('myGMMPredict prob NaN or Inf found after divide\n')
			idx = find(sp==0);
			idx(1)
			probold(:, idx(1))
			error('NaN or Inf found')
		end

if nargout >= 2
	[C pred] = max(prob);
	pred = pred - 1;
end
