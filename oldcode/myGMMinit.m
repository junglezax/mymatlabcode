function nb = myGMMinit(ncls, n)
nb.p = rand(ncls, 1);
nb.p = nb.p ./ sum(nb.p);
nb.mu = rand(ncls, n); 
nb.mu = bsxfun(@(v1, v2) v1./v2, nb.mu, sum(nb.mu)); 
%disp('init nb.mu'); nb.mu
nb.sigma = zeros(n, n, ncls);
for j=1:ncls
	rn = rand(n, n);
	nb.sigma(:, :, j) = rn * rn; % must be positive
end
