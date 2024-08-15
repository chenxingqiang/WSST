function tests = testDataGeneration
    tests = functiontests(localfunctions);
end

function testGenerateDataset(testCase)
    M = 100;
    K = 8;
    tau = 16;
    gridSize = 400;
    nbLoc = 50;
    nbChanReal = 100;
    P_ED_dBm = 0:5:30;
    P_ED = 1e-3 * 10.^(P_ED_dBm/10);
    
    [X_feature_PPR, X_feature_Eig, y_label] = generateDataset(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED);
    
    numSamples = nbLoc * nbChanReal;
    numPED = length(P_ED);
    
    testCase.verifySize(X_feature_PPR, [numSamples, K, numPED], 'X_feature_PPR size is incorrect');
    testCase.verifySize(X_feature_Eig, [numSamples, M, numPED], 'X_feature_Eig size is incorrect');
    testCase.verifySize(y_label, [numSamples, numPED], 'y_label size is incorrect');
    
    testCase.verifyGreaterThanOrEqual(X_feature_PPR, 0, 'PPR features should be non-negative');
    testCase.verifyLessThanOrEqual(X_feature_PPR, 1, 'PPR features should be less than or equal to 1');
    testCase.verifyGreaterThanOrEqual(X_feature_Eig, 0, 'Eigenvalue features should be non-negative');
    testCase.verifyTrue(all(y_label(:) == 0 | y_label(:) == 1), 'Labels should be binary');
end