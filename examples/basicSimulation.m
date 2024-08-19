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

% Remove extremely low variance features
[X_feature_PPR, X_feature_Eig] = removeExtremelyLowVarianceFeatures(X_feature_PPR, X_feature_Eig);

% Train neural network models
disp('Training neural network models...');
trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label);

% Perform attack detection
disp('Performing attack detection...');
[detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN, predictions_PPR_NN, predictions_Eig_NN, y_true] = ...
    detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal);

% Calculate error rates
disp('Calculating error rates...');
numPED = length(P_ED_dBm);
[FPR_PPR_NN, FNR_PPR_NN] = calculateErrorRates(predictions_PPR_NN, y_true, numPED);
[FPR_Eig_NN, FNR_Eig_NN] = calculateErrorRates(predictions_Eig_NN, y_true, numPED);

% Visualize results
disp('Generating visualization plots...');
plotDetectionAccuracy(P_ED_dBm, detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);
plotErrorRates(P_ED_dBm, FPR_PPR_NN, FNR_PPR_NN, FPR_Eig_NN, FNR_Eig_NN);

% Plot MDL Histogram
MDLValues = calculateMDL(X_feature_PPR); % Assuming X_feature_PPR contains the necessary data
threshold = 0.5; % Set the desired threshold value
plotMDLHistogram(MDLValues, threshold);

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

% Display summary
disp('Simulation complete. Results summary:');
disp(['Average PPR-NN Detection Accuracy: ', num2str(mean(detAcc_PPR_NN))]);
disp(['Average Eig-NN Detection Accuracy: ', num2str(mean(detAcc_Eig_NN))]);
disp(['PPR-NN False Positive Rate: ', num2str(mean(FPR_PPR_NN))]);
disp(['PPR-NN False Negative Rate: ', num2str(mean(FNR_PPR_NN))]);
disp(['Eig-NN False Positive Rate: ', num2str(mean(FPR_Eig_NN))]);
disp(['Eig-NN False Negative Rate: ', num2str(mean(FNR_Eig_NN))]);