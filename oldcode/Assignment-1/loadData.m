% load hotel data for sentiment analysis
% by X.H. Jiang (jxhchina at gmail.com)
% 17:17 2013/12/11
clc; clear; close all;

positive = readText('dataset\positive');
negative = readText('dataset\negative');

t = [positive, negative];
lens = cellfun(@length, t);
sum(lens)

% 词袋（词汇表）
bag = genBag(t);

% 索引
posidx = indexText(positive, bag);
negidx = indexText(negative, bag);

% 转成词频向量
posfea = toFeatures(posidx, length(bag));
negfea = toFeatures(negidx, length(bag));

npos = size(posfea, 1);
nneg = size(negfea, 1);
XoriginTF = [posfea; negfea];
nfea = size(XoriginTF, 2);
m = size(XoriginTF, 1);
y = [ones(npos, 1); zeros(nneg, 1)];
ucls = unique(y);

% 转成BOOL
XoriginBOOL = (XoriginTF>0);

% 计算IDF
allidx = [posidx negidx];
lenD = length(allidx);
IDF = log(lenD ./ (1+sum(XoriginBOOL)));
XoriginTFIDF = bsxfun(@(v1, v2) v1.*v2, XoriginBOOL, IDF);

