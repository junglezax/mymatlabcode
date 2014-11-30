% boosted-TAN

% fitensemble 代码太复杂。。。还没看就知道复杂
% 还是自己写吧
% 模仿以前的那个简单boost, 再参考adabag的

% 1 固定结构boost参数学习
% 2 变结构，每个新结构参数学习一次
% 3 mixture，来个新结构，继续上次参数学习
%   参数学习完了就可以预测；学习过程中也需要进行精确度/误差率评估
% 参考：Yushi Jing, Boosted Bayesian network classifiers

% 函数调用结构
% test_boosted_TAN.m，调用一切
%	加载数据，预处理
% 	训练
%	分类
% bAN_train:
%	输入：X, y, maxiter
%	输出：bAN, cls, prob, err 即 bAN对象，训练样本分类结果，预测概率，误差率
%	bAN_genGfull生成G_full
%	learn_struct_tan生成G_tan
%	生成G1=naive bayes
%	G=G1
%	对G循环
%		以G为基础结构参数学习 bAN_learnParam
%		对训练样本预测 bAN_predict
%		错误率或步数达到要求退出循环
%		生成新 bAN_genNewG
%	对训练样本计算分类 bAN_predict
% bAN_trainMix()
% 	调用 bAN_learnStru()
%	调用 bAN_learnParam 学习参数
% 	调用 bAN_predict() 判断精度
% bAN_learnParam()
%	输入：G=dag, X, levels, y, maxiter
%	输出：bAN=带参数的bAN对象
%	计算错误率时要用到 TAN_predict
% TAN_predict()
%	输入: bnet, X, y
%	输出: cls, prob, err
%	或许应该返回各类的概率表
% bAN_predict()
%	输入：bAN, X, levels, y(可选)
%	输出：cls, prob, err(若有Y）
% bAN_genGfull
%	中间辅助函数，生成完全图，计算MI信息
%	输入：X, y
% bAN_genNewG()
%	中间辅助函数，生成新的图结构
%	输入：G, G_tan, G_full
%	输出：G

% 数据结构
% bAN类对象
% 一个结构体，成员如下
%	bnets: cell数组，每个元素是一个bnet，长度为k
%	alpha: 1xk向量，分类器参数

