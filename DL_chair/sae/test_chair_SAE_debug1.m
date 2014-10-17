%function test_chair_SAE_debug
addpath(genpath('D:\source\matlablib\DeepLearnToolbox-master'));
%global imgsize
imgsize = 20;

read_chairs_debug1;

test_x = train_x;
test_y = train_y;

%disp('train_x=');
%disp(train_x);

%disp('train_y=')
%disp(train_y);

train_x = double(train_x)/255;
test_x  = double(test_x)/255;
train_y = double(train_y);
test_y  = double(test_y);

%%  ex1 train a 100 hidden unit SDAE and use it to initialize a FFNN
%  Setup and train a stacked denoising autoencoder (SDAE)
rand('state',0)
sae = saesetup([imgsize*imgsize 3]);
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 1;
sae.ae{1}.inputZeroMaskedFraction   = 0; % not use denoising %0.5;
opts.numepochs =   2;
opts.batchsize = 2;

%-------------for test
%{
i=1
sae.ae{i} = nntrain(sae.ae{1}, train_x, train_x, opts);
sae.ae{i}.L

t = sae.ae{i}.a{1}(:, 2:401) - sae.ae{i}.a{3};
sum(sum(t.*t))
%}
%-----------------------

sae = saetrain(sae, train_x, opts);
%visualize(sae.ae{1}.W{1}(:,2:end)')

% Use the SDAE to initialize a FFNN
nn = nnsetup([imgsize*imgsize 3 2]);
nn.activation_function              = 'sigm';
nn.learningRate                     = 1;
nn.W{1} = sae.ae{1}.W{1};

% Train the FFNN
opts.numepochs =   1;
opts.batchsize = 2;
nn = nntrain(nn, train_x, train_y, opts);
[er, bad] = nntest(nn, test_x, test_y);
disp('nn.L=')
disp(nn.L)
disp('er')
disp(er)
assert(er < 0.16, 'Too big error');
