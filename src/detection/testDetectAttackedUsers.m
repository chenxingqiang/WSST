function testResults = testDetectAttackedUsers()
% TESTDETECTATTACKEDUSERS Test function for detectAttackedUsers
%
% This test function validates the detectAttackedUsers function by creating
% a controlled simulation environment with known attacked users and verifying
% the detection accuracy.
%
% Outputs:
%   testResults - Structure containing test results and metrics

    % Test parameters
    M = 100;         % Number of base station antennas
    K = 8;           % Number of legitimate users
    tau = 16;        % Length of pilot sequence
    P_UE = 1;        % Transmit power of legitimate users
    P_ED = 2;        % Attacker power (greater than legitimate user for visibility)
    sigma_n_2 = 0.1; % Noise variance
    
    % Test cases with different attack scenarios
    testCases = struct();
    
    % Test case 1: Single user under attack
    testCases(1).description = 'Single user attack';
    testCases(1).attackedUserIndices = 3; % User 3 is under attack
    
    % Test case 2: Multiple users under attack
    testCases(2).description = 'Multiple user attack';
    testCases(2).attackedUserIndices = [2, 5, 7]; % Users 2, 5, and 7 under attack
    
    % Test case 3: No attack
    testCases(3).description = 'No attack';
    testCases(3).attackedUserIndices = []; % No users under attack
    
    % Initialize test results structure
    testResults = struct();
    testResults.numCases = length(testCases);
    testResults.caseResults = cell(1, testResults.numCases);
    testResults.overallAccuracy = 0;
    
    % Run each test case
    for i = 1:length(testCases)
        disp(['Running test case ', num2str(i), ': ', testCases(i).description]);
        
        % Generate random channel matrices
        h_UE = sqrt(0.5) * (randn(M, K) + 1j * randn(M, K)); % Channel matrix for legitimate users
        g_ED = sqrt(0.5) * (randn(M, 1) + 1j * randn(M, 1)); % Channel vector for attacker
        
        % Generate random pilot sequences
        Phi = sqrt(0.5) * (randn(tau, K) + 1j * randn(tau, K));
        
        % Normalize pilot sequences (orthogonal)
        for k = 1:K
            Phi(:, k) = Phi(:, k) / norm(Phi(:, k));
        end
        
        % Generate random noise
        N = sqrt(sigma_n_2/2) * (randn(M, tau) + 1j * randn(M, tau));
        
        % Initialize received signal as only legitimate users
        Y = zeros(M, tau);
        for k = 1:K
            Y = Y + sqrt(P_UE) * h_UE(:, k) * Phi(:, k)';
        end
        
        % Add attack signal if this test case has attacked users
        for j = 1:length(testCases(i).attackedUserIndices)
            attackedIdx = testCases(i).attackedUserIndices(j);
            if ~isempty(attackedIdx)
                Y = Y + sqrt(P_ED) * g_ED * Phi(:, attackedIdx)';
            end
        end
        
        % Add noise
        Y = Y + N;
        
        % Set path loss coefficients (assumed equal for simplicity)
        Beta_UE = ones(M, K);
        
        % Run the detection function
        [detectedIndices, detectionMetrics] = detectAttackedUsers(Y, Phi, K, M, tau, P_UE, Beta_UE, sigma_n_2);
        
        % Calculate detection performance
        truePositives = length(intersect(detectedIndices, testCases(i).attackedUserIndices));
        falsePositives = length(setdiff(detectedIndices, testCases(i).attackedUserIndices));
        falseNegatives = length(setdiff(testCases(i).attackedUserIndices, detectedIndices));
        
        precision = truePositives / max(1, truePositives + falsePositives);
        recall = truePositives / max(1, truePositives + falseNegatives);
        f1Score = 2 * precision * recall / max(1e-10, precision + recall);
        
        % Store results for this case
        testResults.caseResults{i} = struct(...
            'description', testCases(i).description, ...
            'trueAttackedUsers', testCases(i).attackedUserIndices, ...
            'detectedAttackedUsers', detectedIndices, ...
            'detectionMetrics', detectionMetrics, ...
            'precision', precision, ...
            'recall', recall, ...
            'f1Score', f1Score);
        
        disp(['  Precision: ', num2str(precision)]);
        disp(['  Recall: ', num2str(recall)]);
        disp(['  F1 Score: ', num2str(f1Score)]);
    end
    
    % Calculate overall accuracy
    precisions = zeros(1, testResults.numCases);
    recalls = zeros(1, testResults.numCases);
    f1Scores = zeros(1, testResults.numCases);
    
    for i = 1:testResults.numCases
        precisions(i) = testResults.caseResults{i}.precision;
        recalls(i) = testResults.caseResults{i}.recall;
        f1Scores(i) = testResults.caseResults{i}.f1Score;
    end
    
    testResults.overallPrecision = mean(precisions);
    testResults.overallRecall = mean(recalls);
    testResults.overallF1Score = mean(f1Scores);
    
    disp('Test summary:');
    disp(['Overall Precision: ', num2str(testResults.overallPrecision)]);
    disp(['Overall Recall: ', num2str(testResults.overallRecall)]);
    disp(['Overall F1 Score: ', num2str(testResults.overallF1Score)]);
end
