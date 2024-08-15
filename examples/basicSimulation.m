% Basic Simulation Example for WSST
%
% This script demonstrates a basic usage of the Wireless Security
% Simulation Toolkit (WSST) for simulating and detecting Pilot Spoofing
% Attacks in a massive MIMO system.

% Add WSST to MATLAB path (if not already done)
addpath(genpath('../'));

% Set simulation parameters
M = 100;         % Number of base station antennas
K = 8;           % Number of legitimate users
tau = 16;        % Length of pilot sequence
gridSize = 500;  % Simulation area size (m x m)
nbLoc = 50;      % Number of different location realizations
nbChanReal = 100;% Number of channel realizations per location
P_ED_dBm = 0:5:30; % Eavesdropper power range (dBm)
P_ED = 1e-3 * 10.^(P_ED_dBm/10); % Convert eavesdropper power to Watts

% Generate dataset
disp('Generating dataset...');
[X_feature_PPR, X_feature_Eig, y_label] = generateDataset(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED);

% Train neural network models
disp('Training neural network models...');
trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label);

% Perform attack detection
disp('Performing attack detection...');
[detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN, predictions_PPR_NN, predictions_Eig_NN, y_true] = ...
    detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal);

% Calculate error rates
disp('Calculating error rates...');
[FPR_PPR_NN, FNR_PPR_NN] = calculateErrorRates(predictions_PPR_NN, y_true);
[FPR_Eig_NN, FNR_Eig_NN] = calculateErrorRates(predictions_Eig_NN, y_true);

% Visualize results
disp('Generating visualization plots...');
plotDetectionAccuracy(P_ED_dBm, detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);
plotErrorRates(P_ED_dBm, FPR_PPR_NN, FNR_PPR_NN, FPR_Eig_NN, FNR_Eig_NN);

% Display summary
disp('Simulation complete. Results summary:');
disp(['Average PPR-NN Detection Accuracy: ', num2str(mean(detAcc_PPR_NN))]);
disp(['Average Eig-NN Detection Accuracy: ', num2str(mean(detAcc_Eig_NN))]);
disp(['PPR-NN False Positive Rate: ', num2str(FPR_PPR_NN)]);
disp(['PPR-NN False Negative Rate: ', num2str(FNR_PPR_NN)]);
disp(['Eig-NN False Positive Rate: ', num2str(FPR_Eig_NN)]);
disp(['Eig-NN False Negative Rate: ', num2str(FNR_Eig_NN)]);