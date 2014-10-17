function kl = kldiverge(b, a)
%a 1x1
%b nx1
%size(a)
%size(b)
kl = a * (log(a) - log(b)) + (1 - a) * (log(1 - a) - log(1 - b));

end