%function test_chair_SAE
addpath(genpath('E:\jiang\lib\DeepLearnToolbox-master'));

read_chairs;

train_x = double(train_x)/255;
test_x  = double(test_x)/255;
train_y = double(train_y);
test_y  = double(test_y);

%%  ex1 train a 100 hidden unit SDAE and use it to initialize a FFNN
%  Setup and train a stacked denoising autoencoder (SDAE)
rand('state',0)
sae = saesetup([512*512 100]);
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 1;
sae.ae{1}.inputZeroMaskedFraction   = 0;
opts.numepochs =   300;
opts.batchsize = 95;
sae = saetrain(sae, train_x, opts);
visualize(sae.ae{1}.W{1}(:,2:end)')

% Use the SDAE to initialize a FFNN
nn = nnsetup([512*512 100 2]);
nn.activation_function              = 'sigm';
nn.learningRate                     = 0.1;
nn.W{1} = sae.ae{1}.W{1};

% Train the FFNN
opts.numepochs =   50;
%opts.batchsize = 1;

sel = 20:22;
train_x1 = train_x(sel, :);
train_y1 = train_y(sel, :);

opts.batchsize = size(train_x1, 1);

nn = nntrain(nn, train_x1, train_y1, opts);
nn.L
[er, bad] = nntest(nn, test_x, test_y);
er
nn.L
assert(er < 0.16, 'Too big error');
