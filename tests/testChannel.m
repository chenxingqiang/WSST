function tests = testChannel
    tests = functiontests(localfunctions);
end

function testGenerateUEChannels(testCase)
    M = 100;
    K = 10;
    Beta_UE = ones(M, K);
    h_UE = generateUEChannels(M, K, Beta_UE);
    
    testCase.verifySize(h_UE, [M, K]);
    testCase.verifyTrue(isa(h_UE, 'double') && ~isreal(h_UE));
    
    expectedPower = mean(Beta_UE(:));
    actualPower = mean(abs(h_UE(:)).^2);
    testCase.verifyEqual(actualPower, expectedPower, 'RelTol', 0.1);
end

function testGenerateEDChannel(testCase)
    M = 100;
    Beta_ED = 1;
    g_ED = generateEDChannel(M, Beta_ED);
    
    testCase.verifySize(g_ED, [M, 1]);
    testCase.verifyTrue(isa(g_ED, 'double') && ~isreal(g_ED));
    
    expectedPower = Beta_ED;
    actualPower = mean(abs(g_ED(:)).^2);
    testCase.verifyEqual(actualPower, expectedPower, 'RelTol', 0.1);
end

function testCalculatePathLoss(testCase)
    M = 100;
    K = 10;
    x_BS = 0; y_BS = 0;
    x_UE = rand(K, 1) * 1000; y_UE = rand(K, 1) * 1000;
    x_ED = 500; y_ED = 500;
    
    [Beta_UE, Beta_ED] = calculatePathLoss(M, K, x_BS, y_BS, x_UE, y_UE, x_ED, y_ED);
    
    testCase.verifySize(Beta_UE, [M, K]);
    testCase.verifySize(Beta_ED, [1, 1]);
    testCase.verifyGreaterThan(Beta_UE, 0);
    testCase.verifyGreaterThan(Beta_ED, 0);
    testCase.verifyLessThan(Beta_UE, 1);
    testCase.verifyLessThan(Beta_ED, 1);
end