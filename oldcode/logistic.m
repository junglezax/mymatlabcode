% logistic regression

% sigmoid function
sig = @(x) 1./(1+exp(-x));
tx = -10:0.1:10;
ty = sig(tx);
%plot(tx, ty)

%global X;
%{
X = [
1 1
2 3
3 2
y = [1; 1; 0];
];
%}

% generate data
m1 = 100;
mu1 = [14 8];
sigma1 = [1 .5; .5 2]; R = chol(sigma1);
X1 = repmat(mu1, m1, 1) + randn(m1, 2) * R;

m2 = 100;
mu2 = [3 3];
sigma2 = [1 0.1; .5 2]; R = chol(sigma2);
X2 = repmat(mu2, m2, 1) + randn(m2, 2) * R;
y = [ones(m1, 1); zeros(m2, 1)];

X = [X1; X2];

m = size(X, 1);
% add bias
X = [ones(m, 1) X];

plot(X1(:,1), X1(:,2), 'ro', X2(:,1), X2(:,2), 'bo')
pause

theta0 = [1; 1; 1];

% hypothesis
h = @(theta, X) sig(X * theta);
% h(theta0, X(1, :))
% h(theta0, X)

% surface h(X) for fixed theta, means not much
tx = -10:0.1:10;
tlen = length(tx);
[mx my] = meshgrid(tx, tx);

t = h(theta0, [ones(tlen*tlen, 1) mx(:) my(:)]);
mz = reshape(t, tlen, tlen); % reshape 和 (:) 应该是互为反运算

%{
% scaler version
mz = zeros(tlen, tlen);
for i=1:tlen
	for j=1:tlen
		mz(i, j) = h(theta, [1 mx(i,j), my(i,j)]);
	end
end
%}

%surf(mx, my, mz)

% cost function for one theta^T * x
% cost is negative of likelihood
% curve of -J(h) where h=h(theta, x)
%{
Jcost = @(th, y) -y .* log(th) - (1-y) .* log(1-th)
th = 0:0.01:1;
plot(th, Jcost(th, 1), 'r', th, Jcost(th, 0), 'b')
legend('y=1', 'y=0')
xlabel('h: probability of y=1'); ylabel('cost');
%}

% likelihood function
%J = @(theta, X, y) sum(y.*log(h(theta, X)) + (1-y).*log(1-h(theta, X)))
% or 
J = @(theta, X, y) y' * log(h(theta, X)) + (1-y)' * log(1-h(theta, X))./m
%J(theta, X, y)

% train (optimize)
options = optimset('GradObj','on', 'MaxIter', 100);
Jh = @(theta) logistic_cost_function(theta, X, y, h);
[optTheta, fval, exitflag] = fminunc(Jh, theta0, options)

% classify (predict)
prob = h(optTheta, X)
cls = (prob > 0.5)
% error
sum(cls ~= y) / length(y)

% draw classification boundary
minmaxx = [min(X(:,2)), max(X(:,2))]
minmaxy = -(optTheta(1) + optTheta(2) .* minmaxx)./optTheta(3);
hold on;
plot(minmaxx, minmaxy)
% seems wrong!

% draw clissifcation mesh
tx = minmaxx(1):0.5:minmaxx(2);
tminy = min(min(X(:,3)), min(minmaxy));
tmaxy = max(max(X(:,3)), max(minmaxy));
ty = tminy:0.5:tmaxy;

[mx, my] = meshgrid(tx, ty);
mx = mx(:); my = my(:);
prob1 = h(optTheta, [ones(length(mx), 1) mx my]);
cls1 = (prob1 > 0.5);
gscatter(mx, my, cls1, 'gc','so')
hold off;

% de the fking bug
%{
tx = [1 12 10];
tx * optTheta
h(optTheta, tx)
sig(tx * optTheta)
sig(0)
%}
