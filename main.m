function main()
% MAIN - Main script for Pilot Spoofing Attack (PSA) simulation and analysis
%
% This script runs a comprehensive simulation of a massive MIMO system
% with potential pilot spoofing attacks. It generates data, trains neural
% network models, performs attack detection and localization, and
% visualizes the results using the Wireless Security Simulation Toolkit (WSST).
%
% The script progresses through the following steps:
% 1. Set up simulation parameters
% 2. Generate dataset
% 3. Train neural network models
% 4. Perform attack detection (both overall system and per-user detection)
% 5. Perform attacker localization
% 6. Calculate and visualize performance metrics
%
% Note: Ensure all required functions are in the MATLAB path before running.

    % Simulation Parameters
    M = 100;         % Number of base station antennas
    K = 8;           % Number of legitimate users
    tau = 16;        % Length of pilot sequence
    gridSize = 400;  % Simulation area size (m x m)
    nbLoc = 50;      % Number of different location realizations
    nbChanReal = 100;% Number of channel realizations per location
    P_ED_dBm = 0:5:30; % Eavesdropper power range (dBm)
    P_ED = 1e-3 * 10.^(P_ED_dBm/10); % Convert eavesdropper power to Watts
    n_attackers = 3; % Number of attackers for multiple attacker scenario

    % Generate Dataset
    disp('Generating dataset...');
    [X_feature_PPR, X_feature_Eig, y_label] = generateDataset(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED);

    % Print dataset sizes for debugging
    disp(['X_feature_PPR size: ', num2str(size(X_feature_PPR))]);
    disp(['X_feature_Eig size: ', num2str(size(X_feature_Eig))]);
    disp(['y_label size: ', num2str(size(y_label))]);

    % Remove extremely low variance features
    [X_feature_PPR, X_feature_Eig] = removeExtremelyLowVarianceFeatures(X_feature_PPR, X_feature_Eig);

    % Train Neural Network Models
    disp('Training neural network models...');
    tic;
    trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label);
    timeTrain = toc;
    disp(['Training time: ', num2str(timeTrain), ' seconds']);

    % Perform Attack Detection
    disp('Performing attack detection...');
    tic;
    [detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN, predictions_PPR_NN, predictions_Eig_NN, y_true] = ...
        detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal);
    timeDetect = toc;
    disp(['Detection time: ', num2str(timeDetect), ' seconds']);

    % Perform Single Attacker Localization
    disp('Performing single attacker localization...');
    tic;
    attackerTarget = locateSingleAttacker(X_feature_PPR, K, P_ED, nbLoc, nbChanReal);
    timeLocateSingle = toc;
    disp(['Single attacker localization time: ', num2str(timeLocateSingle), ' seconds']);

    % Perform Multiple Attacker Localization
    disp('Performing multiple attacker localization...');
    tic;
    attackerTargets = locateMultipleAttackers(X_feature_PPR, n_attackers, K, P_ED, nbLoc, nbChanReal);
    timeLocateMultiple = toc;
    disp(['Multiple attacker localization time: ', num2str(timeLocateMultiple), ' seconds']);

    % Visualize Execution Times
    executionTimes = [timeTrain, timeDetect, timeLocateSingle, timeLocateMultiple];
    plotExecutionTime(executionTimes);

    % Calculate Error Rates
    disp('Calculating error rates...');
    numPED = length(P_ED_dBm);
    [FPR_PPR_NN, FNR_PPR_NN] = calculateErrorRates(predictions_PPR_NN, y_true, numPED);
    [FPR_Eig_NN, FNR_Eig_NN] = calculateErrorRates(predictions_Eig_NN, y_true, numPED);
    
    % Visualize Results
    disp('Generating visualization plots...');

    % Plot Error Rates vs. Eavesdropper Power
    plotErrorRates(P_ED_dBm, FPR_PPR_NN, FNR_PPR_NN, FPR_Eig_NN, FNR_Eig_NN);

    % Plot Detection Accuracy
    plotDetectionAccuracy(P_ED_dBm, detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);

    % Plot Localization Accuracy
    plotLocalizationAccuracy(attackerTargets, attackerTarget, n_attackers);

    % Plot Accuracy vs Complexity
    complexityLevels = [50, 100, 150, 200];  % Assumed antenna numbers for complexity
    accuracyLevels = [mean(detAcc_PPR), mean(detAcc_MDL), mean(detAcc_PPR_NN), mean(detAcc_Eig_NN)];
    plotAccuracyVsComplexity(complexityLevels, accuracyLevels);
    
    % Plot Execution Times
    executionTimes = [timeTrain, timeDetect, timeLocateSingle, timeLocateMultiple];
    plotExecutionTime(executionTimes);

    % Select best algorithm and plot results
    bestAlgoIdx = selectBestAlgorithm(detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);
    plotBestAlgorithm(P_ED_dBm, bestAlgoIdx);

    % Plot MDL Histogram
    MDLValues = calculateMDL(X_feature_PPR); % Assuming X_feature_PPR contains the necessary data
    plotMDLHistogram(MDLValues);

    % Plot Received Signal
    h_UE = randn(M, K);  % Generate random channel matrix for legitimate users
    g_ED = randn(M, 1);  % Generate random channel vector for eavesdropper
    Phi = randn(tau, K); % Generate random training sequence matrix
    P_UE = 1;  % Set transmit power of user equipment
    N = randn(M, tau);  % Generate random noise matrix
    indAttPres = randi([0, 1]);  % Randomly set the indicator of attack presence
    indAttUE = randi(K);  % Randomly set the index of the attacked user
    P_ED_single = P_ED(1);  % Use the first element of P_ED as a scalar
    Y = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED_single, N, indAttPres, indAttUE);
    plotReceivedSignal(Y, N);

    % Visualize Network Topology
    x_BS = 0; y_BS = 0;  % Coordinates of the Base Station
    x_UE = rand(1, K) * gridSize; y_UE = rand(1, K) * gridSize;  % Coordinates of the User Equipment
    x_ED = rand * gridSize; y_ED = rand * gridSize;  % Coordinates of the Eavesdropper
    visualizeNetworkTopology(x_BS, y_BS, x_UE, y_UE, x_ED, y_ED, gridSize);
    
    % Visualize PPR Distribution
    % Extract necessary parameters from X_feature_PPR
    [numSamples, numFeatures, numPowerLevels] = size(X_feature_PPR);
    PPRValues = zeros(numSamples, K);
    for i = 1:numSamples
        % Generate placeholder received signal Y
        Y = randn(M, tau);  % Placeholder received signal with appropriate dimensions
        Phi = randn(tau, K);  % Generate random training sequence matrix
        sigma_n_2 = 1;  % Set noise variance
        Beta_UE = ones(M, K);  % Assume equal path loss for all users
        PPRValues(i, :) = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
    end
    PPR_threshold = 0.5;  % Set a threshold value for PPR detection
    visualizePPRDistribution(PPRValues(:), PPR_threshold);

   % Generate and plot heatmap
    [numRows, numCols] = size(detAcc_PPR_NN);
    if numCols ~= K
        warning('Number of columns in detAcc_PPR_NN does not match K. Adjusting heatmap size.');
        K_heatmap = numCols;
    else
        K_heatmap = K;
    end
    heatmapData = reshape(detAcc_PPR_NN, [], K_heatmap);
    plotHeatmap(heatmapData);

    % Select best algorithm and plot results
    bestAlgoIdx = selectBestAlgorithm(detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);
    plotBestAlgorithm(P_ED_dBm, bestAlgoIdx);

    % Perform Attacked User Detection Simulation
    disp('Performing attacked user detection simulation...');
    tic;
    
    % Define attack scenarios
    attackScenarios = struct();
    attackScenarios(1).name = 'Single User Attack';
    attackScenarios(1).numAttacked = 1;
    attackScenarios(1).fixedUsers = 3; % User 3 is always attacked
    
    attackScenarios(2).name = 'Two User Attack';
    attackScenarios(2).numAttacked = 2;
    attackScenarios(2).fixedUsers = [2, 6]; % Users 2 and 6 are always attacked
    
    attackScenarios(3).name = 'Multiple User Attack';
    attackScenarios(3).numAttacked = min(K, 3);
    attackScenarios(3).fixedUsers = [1, 3, 5]; % First 3 users attacked (or less if K < 3)
    
    % Run the attacked user detection simulation
    [detectionResults, userAccuracy] = simulateAttackedUserDetection(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, attackScenarios);
    timeUserDetection = toc;
    disp(['Attacked user detection time: ', num2str(timeUserDetection), ' seconds']);
    
    % Run a test case for visualization
    disp('Running attacked user detection test case for visualization...');
    tic;
    testResults = testDetectAttackedUsers();
    timeTestUserDetection = toc;
    disp(['Test case execution time: ', num2str(timeTestUserDetection), ' seconds']);
    
    % Create a single visualization for the best test case
    bestTestCase = 2; % Multiple user attack case typically shows best results
    caseResult = testResults.caseResults{bestTestCase};
    
    % Visualize the attacked user detection results
    visualizeAttackedUsers(caseResult.detectedAttackedUsers, caseResult.detectionMetrics, K, ...
        ['Attacked User Detection: ' caseResult.description]);
    
    % Update execution times to include new functions
    executionTimes = [timeTrain, timeDetect, timeLocateSingle, timeLocateMultiple, timeUserDetection, timeTestUserDetection];
    plotExecutionTime(executionTimes, {'Training', 'Attack Detection', 'Single Attacker Localization', ...
                                      'Multiple Attacker Localization', 'User-specific Detection', 'Detection Test Cases'});
    
    % Display summary
    disp('Simulation complete. Results summary:');
    disp(['Average PPR-NN Detection Accuracy: ', num2str(mean(detAcc_PPR_NN))]);
    disp(['Average Eig-NN Detection Accuracy: ', num2str(mean(detAcc_Eig_NN))]);
    disp(['PPR-NN False Positive Rate: ', num2str(mean(FPR_PPR_NN))]);
    disp(['PPR-NN False Negative Rate: ', num2str(mean(FNR_PPR_NN))]);
    disp(['Eig-NN False Positive Rate: ', num2str(mean(FPR_Eig_NN))]);
    disp(['Eig-NN False Negative Rate: ', num2str(mean(FNR_Eig_NN))]);
    
    % Display attacked user detection results
    disp('Attacked User Detection Results:');
    for i = 1:length(attackScenarios)
        disp(['  Scenario: ', attackScenarios(i).name]);
        disp(['    Average Precision: ', num2str(mean(detectionResults.precision(i,:)))]);
        disp(['    Average Recall: ', num2str(mean(detectionResults.recall(i,:)))]);
        disp(['    Average F1 Score: ', num2str(mean(detectionResults.f1Score(i,:)))]);
    end
    
    disp(['Total Execution Time: ', num2str(sum(executionTimes)), ' seconds']);
    disp('All results have been plotted and saved.');
end