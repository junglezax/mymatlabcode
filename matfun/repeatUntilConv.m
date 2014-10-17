% 重复运行一个带有随机性的函数，直到收敛
% 即它的返回值的平均几乎不再变化
% 重复运行n次，求平均，和n-1次时的均值相比较，如果相差还比较大，继续增加运行次数，直到连续k次变化很小，返回均值及其标准差
function [m, s, n, rs] = repeatUntilConv(f, minn, maxn)
if nargin < 2
	minn = 100;
end

if nargin < 3
	maxn = 1000000;
end

eps = 1e-4;
k = 10;
rs = zeros(1, maxn);
ms = zeros(1, maxn);
n = 1;

rs(1:minn) = arrayfun(f, 1:minn);
ms(1:minn) = arrayfun(@(t) mean(rs(1:t)), 1:minn);
n = minn;
while 1
	ms1 = ms(n-k:n);
	ms2 = ms(n-k-1:n-1);
	msa = abs(ms1 - ms2);
	if all(msa <= eps)
		disp('covergence reached');
		break;
	else
		disp(mean(msa));
	end
	
	n = n + 1;
	rs(n) = f();
	ms(n) = mean(rs(1:n));
	
	if n >= maxn
		disp('maxn reached');
		break;
	end
end

m = ms(n);
s = std(rs(1:n));
rs = rs(1:n);
