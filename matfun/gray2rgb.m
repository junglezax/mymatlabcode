function im1 = gray2rgb(im)
	sz = size(im);
	assert(numel(sz) == 2);
	im1 = uint8(zeros(sz(1), sz(2), 3));
	im1(:, :, 1) = im;
	im1(:, :, 2) = im;
	im1(:, :, 3) = im;
end
