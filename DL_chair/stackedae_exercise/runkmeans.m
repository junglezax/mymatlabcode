function runkmeans(x, numCluser, fns)
	opts.MaxIter = 200;
	opts.Display = 'iter';
	[kmeans_IDX, kmeans_C] = kmeans(x', numCluser, 'Options', opts);
	
	save('../../../data/furniture_20000_64x64_sae_100_100_kmeans_result.mat', 'kmeans_IDX', 'kmeans_C');
	
	for i = 1:numCluser
		cluser = find(kmeans_IDX == i);
		sidx = randi(numel(cluser), 1, 10);
		
		fprintf('cluster #%d\n', i);
		for j = 1:numel(sidx)
			im = imread(fns{sidx(j)});
			imshow(im);
			pause
		end
	end
end
