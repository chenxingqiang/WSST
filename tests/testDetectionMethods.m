function tests = testDetectionMethods
    tests = functiontests(localfunctions);
end

function testDetectPSA_PPR(testCase)
    numSamples = 1000;
    numFeatures = 8;
    X_feature_PPR = rand(numSamples, numFeatures);
    
    [detection, PPR_values, threshold] = detectPSA_PPR(X_feature_PPR);
    
    testCase.verifySize(detection, [numSamples, 1], 'Detection result size is incorrect');
    testCase.verifyClass(detection, 'logical', 'Detection result should be logical');
    testCase.verifySize(PPR_values, [numSamples, 1], 'PPR values size is incorrect');
    testCase.verifyTrue(isscalar(threshold), 'Threshold should be a scalar');
end

function testDetectPSA_MDL(testCase)
    numSamples = 1000;
    numFeatures = 7;
    X_feature_Eig = rand(numSamples, numFeatures);
    
    [detection, MDL_values, threshold] = detectPSA_MDL(X_feature_Eig);
    
    testCase.verifySize(detection, [numSamples, 1], 'Detection result size is incorrect');
    testCase.verifyClass(detection, 'logical', 'Detection result should be logical');
    testCase.verifySize(MDL_values, [numSamples, 1], 'MDL values size is incorrect');
    testCase.verifyTrue(isscalar(threshold), 'Threshold should be a scalar');
end

function testDetectMultipleAttackers(testCase)
    numSamples = 1000;
    numFeaturesPPR = 8;
    numFeaturesEig = 7;
    numPED = 7;
    X_feature_PPR = rand(numSamples, numFeaturesPPR, numPED);
    X_feature_Eig = rand(numSamples, numFeaturesEig, numPED);
    y_label = randi([0, 1], numSamples, numPED);
    P_ED = 0:5:30;
    P_ED_dBm = P_ED;
    nbLoc = 50;
    nbChanReal = 20;
    
    [detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN, predictions_PPR_NN, predictions_Eig_NN, y_true] = ...
        detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal);
    
    testCase.verifySize(detAcc_PPR, [1, numPED], 'PPR detection accuracy size is incorrect');
    testCase.verifySize(detAcc_MDL, [1, numPED], 'MDL detection accuracy size is incorrect');
    testCase.verifySize(detAcc_PPR_NN, [1, numPED], 'PPR-NN detection accuracy size is incorrect');
    testCase.verifySize(detAcc_Eig_NN, [1, numPED], 'Eig-NN detection accuracy size is incorrect');
    testCase.verifySize(predictions_PPR_NN, [numSamples * numPED, 1], 'PPR-NN predictions size is incorrect');
    testCase.verifySize(predictions_Eig_NN, [numSamples * numPED, 1], 'Eig-NN predictions size is incorrect');
    testCase.verifySize(y_true, [numSamples * numPED, 1], 'True labels size is incorrect');
end