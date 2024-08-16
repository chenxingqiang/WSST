function [detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN, predictions_PPR_NN, predictions_Eig_NN, y_true] = detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal)
% DETECTMULTIPLEATTACKERS Detect multiple attackers using various methods
%
% This function performs attack detection using traditional methods (PPR and MDL)
% and neural network-based methods on the given dataset.
%
% Inputs:
% X_feature_PPR - PPR features, size: [numSamples x numFeaturesPPR x numPED]
% X_feature_Eig - Eigenvalue features, size: [numSamples x numFeaturesEig x numPED]
% y_label - True labels, size: [numSamples x numPED]
% P_ED - Eavesdropper power levels (W)
% P_ED_dBm - Eavesdropper power levels (dBm)
% nbLoc - Number of location realizations
% nbChanReal - Number of channel realizations per location
%
% Outputs:
% detAcc_PPR - Detection accuracy using PPR method
% detAcc_MDL - Detection accuracy using MDL method
% detAcc_PPR_NN - Detection accuracy using PPR-based neural network
% detAcc_Eig_NN - Detection accuracy using Eigenvalue-based neural network
% predictions_PPR_NN - Predictions from PPR-based neural network
% predictions_Eig_NN - Predictions from Eigenvalue-based neural network
% y_true - True labels (flattened)

    % Load trained models
    load('trainedNet_PPR.mat', 'trainedNet_PPR');
    load('trainedNet_Eig.mat', 'trainedNet_Eig');

    % Display input sizes for debugging
    disp(['Size of X_feature_PPR: ', num2str(size(X_feature_PPR))]);
    disp(['Size of X_feature_Eig: ', num2str(size(X_feature_Eig))]);
    disp(['Size of y_label: ', num2str(size(y_label))]);
    disp(['nbLoc: ', num2str(nbLoc)]);
    disp(['nbChanReal: ', num2str(nbChanReal)]);

    % Initialize variables
    numPED = length(P_ED);
    detAcc_PPR = zeros(1, numPED);
    detAcc_MDL = zeros(1, numPED);
    detAcc_PPR_NN = zeros(1, numPED);
    detAcc_Eig_NN = zeros(1, numPED);

    % Reshape features and labels
    [numSamples, numFeatures, ~] = size(X_feature_PPR);
    X_feature_PPR_2D = reshape(X_feature_PPR, numSamples * numPED, numFeatures);
    X_feature_Eig_2D = reshape(X_feature_Eig, numSamples * numPED, size(X_feature_Eig, 2));
    y_true = y_label(:);

    % Perform detection using neural networks
    predictions_PPR_NN = classify(trainedNet_PPR, X_feature_PPR_2D);
    predictions_Eig_NN = classify(trainedNet_Eig, X_feature_Eig_2D);

    % Calculate detection accuracy for each P_ED
    for i = 1:numPED
        start_idx = (i-1)*nbLoc*nbChanReal + 1;
        end_idx = i*nbLoc*nbChanReal;

        % Add these debug lines:
        disp(['Iteration ', num2str(i)]);
        disp(['start_idx: ', num2str(start_idx)]);
        disp(['end_idx: ', num2str(end_idx)]);
        disp(['Size of y_true: ', num2str(size(y_true))]);

        % Ensure indices are within bounds
        start_idx = max(1, start_idx);
        end_idx = min(numSamples, end_idx);

        % Traditional methods
        detAcc_PPR(i) = sum(detectPSA_PPR(X_feature_PPR(:,:,i)) == y_label(:,i)) / (nbLoc*nbChanReal);
        detAcc_MDL(i) = sum(detectPSA_MDL(X_feature_Eig(:,:,i)) == y_label(:,i)) / (nbLoc*nbChanReal);

        % Neural network methods
        nn_idx_start = (i-1)*numSamples + 1;
        nn_idx_end = i*numSamples;
        detAcc_PPR_NN(i) = sum(predictions_PPR_NN(nn_idx_start:nn_idx_end) == categorical(y_label(:,i))) / (nbLoc*nbChanReal);
        detAcc_Eig_NN(i) = sum(predictions_Eig_NN(nn_idx_start:nn_idx_end) == categorical(y_label(:,i))) / (nbLoc*nbChanReal);

        % Display results for this iteration
        disp(['P_ED = ', num2str(P_ED_dBm(i)), ' dBm:']);
        disp(['  PPR Detection Accuracy: ', num2str(detAcc_PPR(i)*100), '%']);
        disp(['  MDL Detection Accuracy: ', num2str(detAcc_MDL(i)*100), '%']);
        disp(['  PPR-NN Detection Accuracy: ', num2str(detAcc_PPR_NN(i)*100), '%']);
        disp(['  Eig-NN Detection Accuracy: ', num2str(detAcc_Eig_NN(i)*100), '%']);
    end
end