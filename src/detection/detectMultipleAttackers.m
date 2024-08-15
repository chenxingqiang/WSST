function [detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN, predictions_PPR_NN, predictions_Eig_NN, y_true] = detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal)
% DETECTMULTIPLEATTACKERS Detect multiple attackers using various methods
%
% This function performs attack detection using traditional methods (PPR and MDL)
% and neural network-based methods on the given dataset.
%
% Inputs:
%   X_feature_PPR - PPR features, size: [numSamples x numFeaturesPPR x numPED]
%   X_feature_Eig - Eigenvalue features, size: [numSamples x numFeaturesEig x numPED]
%   y_label       - True labels, size: [numSamples x numPED]
%   P_ED          - Eavesdropper power levels (W)
%   P_ED_dBm      - Eavesdropper power levels (dBm)
%   nbLoc         - Number of location realizations
%   nbChanReal    - Number of channel realizations per location
%
% Outputs:
%   detAcc_PPR     - Detection accuracy using PPR method
%   detAcc_MDL     - Detection accuracy using MDL method
%   detAcc_PPR_NN  - Detection accuracy using PPR-based neural network
%   detAcc_Eig_NN  - Detection accuracy using Eigenvalue-based neural network
%   predictions_PPR_NN - Predictions from PPR-based neural network
%   predictions_Eig_NN - Predictions from Eigenvalue-based neural network
%   y_true         - True labels (flattened)

    % Load trained models
    load('trainedNet_PPR.mat', 'trainedNet_PPR');
    load('trainedNet_Eig.mat', 'trainedNet_Eig');

    % Initialize variables
    numPED = length(P_ED);
    detAcc_PPR = zeros(1, numPED);
    detAcc_MDL = zeros(1, numPED);
    detAcc_PPR_NN = zeros(1, numPED);
    detAcc_Eig_NN = zeros(1, numPED);
    
    % Reshape features and labels
    X_feature_PPR_2D = reshape(X_feature_PPR, [], size(X_feature_PPR, 2));
    X_feature_Eig_2D = reshape(X_feature_Eig, [], size(X_feature_Eig, 2));
    y_true = y_label(:);

    % Perform detection using neural networks
    predictions_PPR_NN = classify(trainedNet_PPR, X_feature_PPR_2D);
    predictions_Eig_NN = classify(trainedNet_Eig, X_feature_Eig_2D);

    % Calculate detection accuracy for each P_ED
    for i = 1:numPED
        start_idx = (i-1)*nbLoc*nbChanReal + 1;
        end_idx = i*nbLoc*nbChanReal;
        
        % Traditional methods
        detAcc_PPR(i) = sum(detectPSA_PPR(X_feature_PPR(start_idx:end_idx,:)) == y_true(start_idx:end_idx)) / (nbLoc*nbChanReal);
        detAcc_MDL(i) = sum(detectPSA_MDL(X_feature_Eig(start_idx:end_idx,:)) == y_true(start_idx:end_idx)) / (nbLoc*nbChanReal);
        
        % Neural network methods
        detAcc_PPR_NN(i) = sum(predictions_PPR_NN(start_idx:end_idx) == categorical(y_true(start_idx:end_idx))) / (nbLoc*nbChanReal);
        detAcc_Eig_NN(i) = sum(predictions_Eig_NN(start_idx:end_idx) == categorical(y_true(start_idx:end_idx))) / (nbLoc*nbChanReal);
    end
end

