function tests = testAttackSimulation
    tests = functiontests(localfunctions);
end

function testSimulatePSA(testCase)
    M = 100;
    K = 10;
    tau = 16;
    h_UE = (randn(M, K) + 1i * randn(M, K)) / sqrt(2);
    g_ED = (randn(M, 1) + 1i * randn(M, 1)) / sqrt(2);
    Phi = hadamard(tau);
    Phi = Phi(:, 1:K) / sqrt(tau);
    P_UE = 1;
    P_ED = 1;
    N = (randn(M, tau) + 1i * randn(M, tau)) / sqrt(2);
    indAttPres = 1;
    indAttUE = 1;
    
    Y = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED, N, indAttPres, indAttUE);
    
    testCase.verifySize(Y, [M, tau], 'Received signal size is incorrect');
    testCase.verifyTrue(~isreal(Y), 'Received signal should be complex');
    
    % Test no attack case
    Y_no_attack = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED, N, 0, indAttUE);
    testCase.verifyNotEqual(Y, Y_no_attack, 'Attack and no-attack cases should differ');
end

function testCalculatePPR(testCase)
    M = 100;
    K = 10;
    tau = 16;
    Beta_UE = ones(M, K);
    Phi = hadamard(tau);
    Phi = Phi(:, 1:K) / sqrt(tau);
    P_UE = 1;
    sigma_n_2 = 0.1;
    Y = (randn(M, tau) + 1i * randn(M, tau)) / sqrt(2);
    
    PPR = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
    
    testCase.verifySize(PPR, [1, K], 'PPR size is incorrect');
    testCase.verifyGreaterThan(PPR, 0, 'PPR values should be positive');
end