%first run test_chair_SAE
nn = nnsetup([512*512 10 2]);
nn.activation_function              = 'sigm';
nn.learningRate                     = 0.1;

% Train the FFNN
opts.numepochs =   200;

m = size(train_x, 1);
sel = 1:m;
%sel = 20:22;
%sel = 19:21;
train_x1 = train_x(sel, :);
train_y1 = train_y(sel, :);

opts.batchsize = size(train_x1, 1);

nn = nntrain(nn, train_x1, train_y1, opts);
nn.L
nn.a{3}

[dummy, labels] = max(nn.a{3}, [], 2);
[dummy, expected] = max(train_y1,[],2);
bad = find(labels ~= expected);
er = numel(bad) / m