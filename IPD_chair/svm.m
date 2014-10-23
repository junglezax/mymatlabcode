%% ======================================================================
% load images
scaledSize = 64;
[images, img_gray, x, allLabels, fns] = read_chairs2(scaledSize);

%%======================================================================
% feature extraction
labeledData = x;

%%======================================================================
% sampling
trainSet = [8, 6, 3, 2, 5, 64, 10, 16, 15, 12, 11, 18, 19, 25, 28, 22, 23, 33, 29, 31, 24, 43, 35, 38, 36, 48, 46, 34, 45, 39, 49, 50, 53, 52, 56, 70, 68, 61, 57, 67, 62, 63, 59, 73, 75, 71, 72, 78, 81, 79, 77, 90, 83, 95, 88, 91, 92, 85, 89];
testSet = [1, 4, 7, 9, 13, 14, 17, 20, 21, 26, 27, 30, 32, 37, 40, 41, 42, 44, 47, 51, 54, 55, 58, 60, 65, 66, 69, 74, 76, 80, 82, 84, 86, 87, 93, 94];

[trainData, trainLabels, testData, testLabels] = sampleData(labeledData, allLabels, trainSet, testSet);

%%======================================================================
% training svm
[multiSVMmodels, usedLabels] = multisvm_train(trainData', trainLabels);

%%======================================================================
% test
[pred] = multisvm_test(multiSVMmodels, testData', usedLabels);

acc = mean(testLabels(:) == pred(:));
fprintf('Before Finetuning Test Accuracy: %0.3f%%\n', acc * 100);

%% -----------------------------------------------------
% test all examples
[pred1] = multisvm_test(multiSVMmodels, labeledData', usedLabels);

pp = sum(pred1(:) == allLabels(:));
tt = numel(allLabels);
fprintf('Test Accuracy on all examples: %d/%d = %f%%\n', pp, tt, 100*pp/tt);

pr1 = pred1(:);
lb1 = allLabels(:);

levels = unique(lb1);
for i = 1:numel(levels)
	pp = sum(pr1 == lb1 & lb1 == levels(i));
	tt = sum(lb1 == levels(i));
	fprintf('Test Accuracy of class #%d: %d/%d = %f%%\n', levels(i), pp, tt, 100 * pp./ tt);
end

[F1, prec, rec] = f1_score(lb1, pr1);
fprintf('F1 score: %f%%\n', 100 * F1);
