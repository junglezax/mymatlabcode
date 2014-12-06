function [accTest, predTest] = testSoftmax(softmaxModel, testFeatures, testLabels)
	[predTest] = softmaxPredict(softmaxModel, testFeatures);
	accTest = (predTest(:) == testLabels(:));
	accTest = sum(accTest) / size(accTest, 1);
	fprintf('Accuracy: %2.3f%%\n', accTest * 100);
end
