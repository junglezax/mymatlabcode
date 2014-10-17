function feat = extractFeatures(opttheta, hiddenSize, visibleSize, data, useAE)
	%%======================================================================
	%% Extract Features from the Supervised Dataset
	if useAE
		feat = feedForwardAutoencoder(opttheta, hiddenSize, visibleSize, data);
	else % not use AE
		disp('not use AE in extractFeatures');
		feat = data;
	end

end