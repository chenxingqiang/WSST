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
% 4. Perform attack detection
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
    receivedSignal = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED_single, N, indAttPres, indAttUE);
    plotReceivedSignal(receivedSignal);

    % Visualize Network Topology
    positions = generatePositions(gridSize, K); % Assuming generatePositions returns user positions
    visualizeNetworkTopology(positions);

    % Visualize PPR Distribution
    PPRValues = calculatePPR(X_feature_PPR); % Assuming X_feature_PPR contains the necessary data
    visualizePPRDistribution(PPRValues);

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

    % Display summary
    disp('Simulation complete. Results summary:');
    disp(['Average PPR-NN Detection Accuracy: ', num2str(mean(detAcc_PPR_NN))]);
    disp(['Average Eig-NN Detection Accuracy: ', num2str(mean(detAcc_Eig_NN))]);
    disp(['PPR-NN False Positive Rate: ', num2str(mean(FPR_PPR_NN))]);
    disp(['PPR-NN False Negative Rate: ', num2str(mean(FNR_PPR_NN))]);
    disp(['Eig-NN False Positive Rate: ', num2str(mean(FPR_Eig_NN))]);
    disp(['Eig-NN False Negative Rate: ', num2str(mean(FNR_Eig_NN))]);
    disp(['Total Execution Time: ', num2str(sum(executionTimes)), ' seconds']);

    disp('All results have been plotted and saved.');
end