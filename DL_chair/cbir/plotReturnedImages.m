function plotReturnedImages(queryImage, images, idxs, cls_idxs)
%   plot: plot images returned by query

	% clear axes
	arrayfun(@cla, findall(0, 'type', 'axes'));

	% display query image
	subplot(3, 7, 1);
	imshow(queryImage, []);
	title('Query Image', 'Color', [1 0 0]);

	% dispaly images returned by query
	for m = 1:length(idxs)
		returnedImage = images{cls_idxs(idxs(m))}; %images(:, :, idxs(m));
		subplot(3, 7, m+1);
		imshow(returnedImage, []);
		%title(fns(idxs(m)), 'Color', [0 0 1]);
	end
end
