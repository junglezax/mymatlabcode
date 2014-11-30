% GMM - Gaussian Mixture Model
% by X.H. Jiang (jxhchina at gmail.com)
% 10:28 2013/12/13
function nb = myGMM(X, maxiter, smooth, nb)
if nargin < 2
	maxiter = 100;
end

if nargin < 3
	smooth = 0; % not used
end

ncls = 2;
[m n] = size(X);

if nargin < 4
% initial parameter
	nb = myGMMinit(ncls, n);
end

%prob = zeros(ncls, m); % soft labels

for t = 1:maxiter
	fprintf('myGMM: iteration #%d\n', t);
	
	% E-step
	tic; prob = myGMMPredict(nb, X); toc
	
			if any(isnan(prob(:))) | any(isinf(prob(:)))
				fprintf('NaN or Inf found in prob before computing pi t=%d\n', t);
				error('NaN or Inf found')
			end

			%fprintf('myGMM: iteration #%d after predict \n', t);
	%prob
	
	% M-step
	% update pi
	disp('updating pi...')
	
	sp = sum(prob, 2);
	sp
	
	%sp
	%sum(sp)
	%assert(sum(sp) == m);
	
	nb.p = sp ./ m;
	
			if any(isnan(nb.p)) | any(isinf(nb.p))
				fprintf('NaN or Inf found when computing pi t=%d\n', t);
				nb.p
				sp

				save prob.txt -ASCII prob

				error('NaN or Inf found')
			end
	%disp('size(nb.p)'); size(nb.p)
	%disp('nb.p'); nb.p
	
	% update mu
	disp('updating mu...')
	
	t = prob * X;
	st = sum(t, 2);
	nb.mu = bsxfun(@(v1, v2) v1./v2, t, st);
	
			if any(isnan(nb.mu(:))) | any(isinf(nb.mu(:)))
				fprintf('NaN or Inf found when computing mu t=%d\n', t);
				error('NaN or Inf found')
			end
	%disp('nb.mu'); nb.mu
	%disp('prob'); prob
	%disp('X'); X
	%disp('t'); t
	%disp('st'); st
	
	% update sigma
	disp('updating sigma...')
	
	for j = 1:ncls
		nb.sigma(:, :, j) = zeros(n, n);
		for i = 1:m
			%fprintf('i=%d j=%d', i, j)
			
			Xi = X(i, :);
			tt = (Xi - nb.mu(j, :));
			
			%disp('Xi'); Xi
			%disp('nb.mu(j)'); nb.mu(j, :)
			%disp('nb.mu'); nb.mu
			%disp('tt * tt'); (tt' * tt)
			%disp('prob(j, i)'); prob(j, i)
			
			nb.sigma(:, :, j) = nb.sigma(:, :, j) + prob(j, i) .* (tt' * tt);
			
			ss = nb.sigma(:, :, j);
			if any(isnan(ss(:))) | any(isinf(ss(:)))
				fprintf('NaN or Inf found when computing sigma, r=%d, j=%d, i=%d\n', t, j, i);
				error('NaN or Inf found')
			end
		end
		
		%disp('nb.sigma(:, :, j)'); nb.sigma(:, :, j)
		%disp('st'); st
		
		nb.sigma(:, :, j) = nb.sigma(:, :, j) ./ st(j);

		%disp('nb.sigma(:, :, j) after divide'); nb.sigma(:, :, j)
	end
end
disp('EM finished...')