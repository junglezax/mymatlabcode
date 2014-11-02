function [images, img_resized, x, labels, fns] = merge_chairs_data(images1, img_resized1, x1, labels1, fns1, images2, img_resized2, x2, labels2, fns2)
	images = [images1 images2];
	img_resized = cat(numel(size(img_resized1)), img_resized1, img_resized2);
	x = [x1 x2];
	labels = [labels1 labels2];
	fns = [fns1 fns2];
end
