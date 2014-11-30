Theta11(:,1) = 0;
Theta12(:,1) = 0; % 应该用Theta21的，但是写了Theta12了，后面还是Theta21相当于Theta2的第1列没去掉；
% 关键是，Theta12不存在，我也可以直接对它的第1列赋值，实际上结果是得到了1x1的矩阵，就是0，matlab并不报错
% 如果这样写x(1)=0，x(2)=3....x不存在时不报错是合理的
% 但是x(:, 1)=0，这种写法，似乎没有意义，应该报错
% 如果x是一个存在的标量，当成1x1矩阵，这样写当然是合理的x(:,1)，虽然没有意义，但了为了程序的通用性也允许这么写
% 害我写那么多代码检查了n久才检查出来，当然错在我的手误
% 早知道，我先检查参与计算的每个变量的size了
% 还有一个不合理，sum(scalar)应该提示警告，当然为了程序的通用性，也允许这么做
r = (sum(sum(Theta11.^2)) + sum(sum(Theta21.^2))) .* lambda ./ (2*m)

Theta11 = Theta1;
Theta21 = Theta2;
%Theta11(1,:) = 0;
%Theta12(1,:) = 0;
Theta11(:,1) = 0;
Theta21(:,1) = 0;  % 哪来的这个？？？
%Theta11(:,end) = 0;
%Theta21(:,end) = 0;
size(Theta1)
size(Theta2)
lambda
m
r = (sum(sum(Theta11.^2)) + sum(sum(Theta21.^2))) .* lambda ./ (2*m)
J = J + r;

t1=sum(Theta1.^2);
t2=sum(Theta2.^2);
r0 = (sum(sum(Theta1.^2)) + sum(sum(Theta2.^2)))
r = r0 .* lambda ./ (2*m)
t3=(sum(t1)+sum(t2))./(2*m)
t4=(t1(1)+t2(1))./(2*m)
t3-t4
r-t4


r01 = (sum(sum(Theta11.^2)) + sum(sum(Theta21.^2)))
r10 = sum(sum(Theta1.^2))
r20 = sum(sum(Theta2.^2))
r10+r20
(r10+r20)./(2*m)-t4
r11 = sum(sum(Theta11.^2))
r21 = sum(sum(Theta21.^2))
r10-r11
t1(1)
r20-r21
