function tests = testSignal
    tests = functiontests(localfunctions);
end

function testGenerateNoise(testCase)
    M = 100;
    tau = 16;
    sigma_n_2 = 0.1;
    N = generateNoise(M, tau, sigma_n_2);
    
    testCase.verifySize(N, [M, tau]);
    testCase.verifyTrue(isa(N, 'double') && ~isreal(N));
    
    expectedPower = sigma_n_2;
    actualPower = mean(abs(N(:)).^2);
    testCase.verifyEqual(actualPower, expectedPower, 'RelTol', 0.1);
end

function testGenerateTrainingSequence(testCase)
    tau = 16;
    K = 10;
    Phi = generateTrainingSequence(tau, K);
    
    testCase.verifySize(Phi, [tau, K]);
    testCase.verifyEqual(sum(abs(Phi).^2, 1), ones(1, K), 'AbsTol', 1e-10);
    testCase.verifyEqual(Phi' * Phi, eye(K), 'AbsTol', 1e-10);
end