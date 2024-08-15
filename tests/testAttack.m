function tests = testAttack
    tests = functiontests(localfunctions);
end

function testSimulatePSA(testCase)
    M = 100; K = 10; tau = 16;
    h_UE = randn(M, K) + 1i * randn(M, K);
    g_ED = randn(M, 1) + 1i * randn(M, 1);
    Phi = generateTrainingSequence(tau, K);
    P_UE = 1; P_ED = 1;
    N = generateNoise(M, tau, 0.1);
    indAttPres = 1;
    indAttUE = 1;
    
    Y = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED, N, indAttPres, indAttUE);
    
    testCase.verifySize(Y, [M, tau]);
    testCase.verifyTrue(isa(Y, 'double') && ~isreal(Y));
end

function testCalculatePPR(testCase)
    K = 10; M = 100; tau = 16;
    P_UE = 1;
    Beta_UE = ones(M, K);
    Y = randn(M, tau) + 1i * randn(M, tau);
    Phi = generateTrainingSequence(tau, K);
    sigma_n_2 = 0.1;
    
    PPR = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
    
    testCase.verifySize(PPR, [1, K]);
    testCase.verifyGreaterThanOrEqual(PPR, 0);
end