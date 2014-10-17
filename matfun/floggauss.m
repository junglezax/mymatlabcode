% log of multi-variate gaussian distribution
function r = floggauss(x, mu, sigma)
sigma(isnan(sigma)) = 0;
sigma(isinf(sigma)) = 1;
d = det(sigma);
n = length(x);
r = -((x-mu) * pinv(sigma) * (x-mu)' + iif(d == 0, 0, log(d)) + n .* log(2*pi))./2;