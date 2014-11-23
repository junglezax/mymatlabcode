function plotQueryImage(queryImage)
	% clear axes
	arrayfun(@cla, findall(0, 'type', 'axes'));

	% display query image
	subplot(3, 7, 1);
	imshow(queryImage, []);
	title('Query Image', 'Color', [1 0 0]);
end
