function tests = testChannelGeneration
    tests = functiontests(localfunctions);
end

function testGenerateUEChannels(testCase)
    M = 100;
    K = 10;
    Beta_UE = ones(M, K);
    h_UE = generateUEChannels(M, K, Beta_UE);
    
    testCase.verifySize(h_UE, [M, K], 'Channel matrix size is incorrect');
    testCase.verifyEqual(mean(abs(h_UE(:)).^2), 1, 'RelTol', 0.1, 'Average channel power is not close to 1');
    testCase.verifyTrue(~isreal(h_UE), 'Channel coefficients are not complex');
end

function testCalculatePathLoss(testCase)
    M = 100;
    K = 10;
    x_BS = 0; y_BS = 0;
    x_UE = rand(K, 1) * 1000; y_UE = rand(K, 1) * 1000;
    x_ED = 500; y_ED = 500;
    
    [Beta_UE, Beta_ED] = calculatePathLoss(M, K, x_BS, y_BS, x_UE, y_UE, x_ED, y_ED);
    
    testCase.verifySize(Beta_UE, [M, K], 'UE path loss matrix size is incorrect');
    testCase.verifySize(Beta_ED, [1, 1], 'ED path loss should be a scalar');
    testCase.verifyGreaterThan(Beta_UE, 0, 'Path loss values should be positive');
    testCase.verifyLessThan(Beta_UE, 1, 'Path loss values should be less than 1');
    testCase.verifyGreaterThan(Beta_ED, 0, 'ED path loss should be positive');
    testCase.verifyLessThan(Beta_ED, 1, 'ED path loss should be less than 1');
end