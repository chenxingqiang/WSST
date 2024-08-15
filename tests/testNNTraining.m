function tests = testNNTraining
    tests = functiontests(localfunctions);
end

function testTrainAndSaveNNModels(testCase)
    % Generate dummy data
    numSamples = 1000;
    numFeaturesPPR = 8;
    numFeaturesEig = 7;
    numPED = 7;
    X_feature_PPR = rand(numSamples, numFeaturesPPR, numPED);
    X_feature_Eig = rand(numSamples, numFeaturesEig, numPED);
    y_label = randi([0, 1], numSamples, numPED);
    
    % Run the function
    trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label);
    
    % Verify that model files are created
    testCase.verifyTrue(isfile('trainedNet_PPR.mat'), 'PPR model file not created');
    testCase.verifyTrue(isfile('trainedNet_Eig.mat'), 'Eig model file not created');
    
    % Load and check the saved models
    load('trainedNet_PPR.mat', 'trainedNet_PPR');
    load('trainedNet_Eig.mat', 'trainedNet_Eig');
    
    testCase.verifyClass(trainedNet_PPR, 'SeriesNetwork', 'PPR model is not a SeriesNetwork');
    testCase.verifyClass(trainedNet_Eig, 'SeriesNetwork', 'Eig model is not a SeriesNetwork');
end