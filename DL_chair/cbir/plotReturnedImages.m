function plotReturnedImages(queryImage, images, idxs, cls_idxs, fns)
	if ~exist('fns', 'var')
		showFn = false;
	else
		showFn = true;
	end

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
		
		if showFn
			tt = fns(idxs(m));
			tt = tt{1};
			
			% shorten
			sepIdx = find(tt == '/' | tt == '\');
			if numel(sepIdx) > 1
				sepIdx = sepIdx(end-1);
				tt = tt(sepIdx+1:end);
			end
			
			title(tt, 'Color', [0 0 1]);
		end
	end
end
