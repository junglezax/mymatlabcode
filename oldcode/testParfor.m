function testParfor

runtimes = 3;
dummy1   = 0;
dummy2   = 0;

%matlabpool local 4

CoreNum=2; %设定机器CPU核心数量，我的机器是双核，所以CoreNum=2
if matlabpool('size')<=0 %判断并行计算环境是否已然启动
	matlabpool('open','local',CoreNum); %若尚未启动，则启动并行环境
else
	disp('Already initialized'); %说明并行环境已经启动。
end

tic
%for x= 1:runtimes;
parfor x= 1:runtimes;
    dummy1 = dummy1 + x;  % dummy1 is a reduction variable
    dummy2 = 2 * x + 1;
end
toc

disp(dummy1)
disp(dummy2)

%matlabpool close