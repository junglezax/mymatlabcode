function patches = sampleIMAGES_color(IMAGES, patchsize, numpatches)
% sampleIMAGES
% IMAGES row*col*3*numImages, color images
% Returns numpatches patches for training
% patches r*c*3*numpatches for numpatches color images

if ~exist('patchsize', 'var') || isempty(patchsize)
    patchsize = 8;
end

if ~exist('numpatches', 'var') || isempty(numpatches)
    numpatches = 10000;
end

% Initialize patches with zeros.  Your code will fill in this matrix--one
% column per patch, 10000 columns. 
patches = zeros(patchsize*patchsize*3, numpatches);

imgN = size(IMAGES, 4);
imgX = size(IMAGES, 2);
imgY = size(IMAGES, 1);

i = 0;
epsilon = 0;
while i < numpatches
	idxi = randi(imgN, 1, 1);
	sx = randi(imgX - patchsize + 1, 1, 1);
	sy = randi(imgY - patchsize + 1, 1, 1);
	
	t = IMAGES(sx : sx + patchsize - 1, sy : sy + patchsize - 1, :, idxi);
	
	t1 = t(:);
	if (std(t1) <= epsilon)
		% skip pure color patches
		continue;
	end
	
	i = i + 1;
	
	%imagesc(t)
	patches(:, i) = t1;  % or reshape
end

%% ---------------------------------------------------------------
% For the autoencoder to work well we need to normalize the data
% Specifically, since the output of the network is bounded between [0,1]
% (due to the sigmoid activation function), we have to make sure 
% the range of pixel values is also bounded between [0,1]
patches = normalizeData(patches);

end


%% ---------------------------------------------------------------
function patches = normalizeData(patches)

% Squash data to [0.1, 0.9] since we use sigmoid as the activation
% function in the output layer

% Remove DC (mean of images). 
patches = bsxfun(@minus, patches, mean(patches));

% Truncate to +/-3 standard deviations and scale to -1 to 1
pstd = 3 * std(patches(:));
patches = max(min(patches, pstd), -pstd) / pstd;

% Rescale from [-1,1] to [0.1,0.9]
patches = (patches + 1) * 0.4 + 0.1;

end
