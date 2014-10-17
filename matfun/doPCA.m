function [x1, xTilde, u, k, dg] = doPCA(x, ratio, method)
% x: n*m
% n: vector size
% m: number of examples
    if ~exist('method', 'var')
		method = 1;
	end
	
	if ~exist('ratio', 'var')
		ratio = 0.99;
	end

	avg = mean(x);
	x1 = x - repmat(avg, size(x, 1), 1);
		
    if method == 2
		% bad
        [u, SCORE, latent] = princomp(x');
        x0 = bsxfun(@minus,x,mean(x,2));
        y = u * x0;
        s = cov(y');
        s2 = y * y' / size(y, 2);
    else
		sigma = x1 * x1' / size(x1, 2);
		[u, s, v] = svd(sigma, 0);
        y = u' * x1;
        %s1 = cov(y'); % covz 
        %s2 = y * y' / size(y, 2);
    end

	dg = diag(s);
	sdg = sum(dg);
	for k=1:length(dg)
		if sum(dg(1:k))/sdg >= ratio
			break
		end
	end
	fprintf('k=%d ratio=%f\n', k, sum(dg(1:k))/sdg);

	xTilde = u(:, 1:k)' * x1;
end