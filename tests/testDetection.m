function tests = testDetection
    tests = functiontests(localfunctions);
end

function testDetectMultipleAttackers(testCase)
    % Generate dummy data
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
    
    testCase.verifyGreaterThanOrEqual(detAcc_PPR, 0, 'PPR detection accuracy should be non-negative');
    testCase.verifyLessThanOrEqual(detAcc_PPR, 1, 'PPR detection accuracy should be less than or equal to 1');
    testCase.verifyGreaterThanOrEqual(detAcc_MDL, 0, 'MDL detection accuracy should be non-negative');
    testCase.verifyLessThanOrEqual(detAcc_MDL, 1, 'MDL detection accuracy should be less than or equal to 1');
    testCase.verifyGreaterThanOrEqual(detAcc_PPR_NN, 0, 'PPR-NN detection accuracy should be non-negative');
    testCase.verifyLessThanOrEqual(detAcc_PPR_NN, 1, 'PPR-NN detection accuracy should be less than or equal to 1');
    testCase.verifyGreaterThanOrEqual(detAcc_Eig_NN, 0, 'Eig-NN detection accuracy should be non-negative');
    testCase.verifyLessThanOrEqual(detAcc_Eig_NN, 1, 'Eig-NN detection accuracy should be less than or equal to 1');
end