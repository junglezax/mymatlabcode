scaledSize = 64;
[images1, img_resized1, x1, labels1, fns1] = read_labeled_chairs('../../images/chair_labeled_97_png/', scaledSize, true, 2);
size(x1)
[images2, img_resized2, x2, labels2, fns2] = read_labeled_chairs('../../images/yes/', scaledSize, true, 2);
size(x2)
[images, img_resized, x, labels, fns] = merge_chairs_data(images1, img_resized1, x1, labels1, fns1, images2, img_resized2, x2, labels2, fns2);
size(x);
[images3, img_resized3, x3, labels3, fns3] = read_labeled_chairs('../../images/msmp2/', scaledSize, true, 2);
[images, img_resized, x, labels, fns] = merge_chairs_data(images, img_resized, x, labels, fns, images3, img_resized3, x3, labels3, fns3);

[images3, img_resized3, x3, labels3, fns3] = read_labeled_chairs('../../images/msmp3/', scaledSize, true, 2);
[images, img_resized, x, labels, fns] = merge_chairs_data(images, img_resized, x, labels, fns, images3, img_resized3, x3, labels3, fns3);
