function sampleOut = sampleImageToTrain(labeledImages, labels)
	[trainImages, trainLabels, testImages, testLabels, trainSet, testSet] = sampleData4d(labeledImages, labels);
	
	sampleOut = struct;
	sampleOut.trainSet = trainSet;
	sampleOut.testSet = testSet;
	sampleOut.trainLabels = trainLabels;
	sampleOut.testLabels = testLabels;
	sampleOut.trainImages = trainImages;
	sampleOut.testImages = testImages;
end