function tests = testChannel
    tests = functiontests(localfunctions);
end

function testGenerateUEChannels(testCase)
    M = 100;
    K = 10;
    Beta_UE = ones(M, K);
    h_UE = generateUEChannels(M, K, Beta_UE);
    
    % Check output dimensions
    testCase.verifySize(h_UE, [M, K]);
    
    % Check if output is complex
    testCase.verifyTrue(isa(h_UE, 'double') && ~isreal(h_UE));
    
    % Check channel power
    expectedPower = mean(Beta_UE(:));
    actualPower = mean(abs(h_UE(:)).^2);
    testCase.verifyEqual(actualPower, expectedPower, 'RelTol', 0.1);
end