function trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label)
% TRAINANDSAVENNMODELS Train and save neural network models for PSA detection
%
% This function trains two neural network models for Pilot Spoofing Attack (PSA) detection:
% one using PPR (Pilot Pollution Ratio) features and another using eigenvalue-based features.
%
% Inputs:
%   X_feature_PPR - PPR features, size: [numSamples x numFeaturesPPR x numPED]
%   X_feature_Eig - Eigenvalue features, size: [numSamples x numFeaturesEig x numPED]
%   y_label       - Attack presence labels, size: [numSamples x numPED]

    % Get data dimensions
    [numSamples, numFeaturesPPR, numPED] = size(X_feature_PPR);
    [~, numFeaturesEig, ~] = size(X_feature_Eig);
    
    % Print detailed variable information for debugging
    disp(['X_feature_PPR size: ', num2str(numSamples), ' x ', num2str(numFeaturesPPR), ' x ', num2str(numPED)]);
    disp(['X_feature_Eig size: ', num2str(numSamples), ' x ', num2str(numFeaturesEig), ' x ', num2str(numPED)]);
    disp(['y_label size: ', num2str(size(y_label, 1)), ' x ', num2str(size(y_label, 2))]);

    % Reshape feature matrices to 2D
    X_feature_PPR_2D = reshape(X_feature_PPR, [], numFeaturesPPR);
    X_feature_Eig_2D = reshape(X_feature_Eig, [], numFeaturesEig);
    y_label_1D = y_label(:);

    % Convert y_label to categorical type for classification
    y_label_cat = categorical(y_label_1D);

    % Normalize features using z-score normalization
    X_feature_PPR_2D = normalize(X_feature_PPR_2D);
    X_feature_Eig_2D = normalize(X_feature_Eig_2D);

    % Balance the dataset to handle potential class imbalance
    [X_feature_PPR_balanced, y_label_PPR_balanced] = balanceDataset(X_feature_PPR_2D, y_label_cat);
    [X_feature_Eig_balanced, y_label_Eig_balanced] = balanceDataset(X_feature_Eig_2D, y_label_cat);

    % Define neural network structures
    numClasses = numel(categories(y_label_cat));
    
    % Define model architectures
    PPR_layers = defineModelArchitecture(numFeaturesPPR, numClasses, 'PPR');
    Eig_layers = defineModelArchitecture(numFeaturesEig, numClasses, 'Eig');

    % Training options
    options = trainingOptions('adam', ...
        'InitialLearnRate', 0.001, ...
        'MaxEpochs', 10, ...
        'MiniBatchSize', 64, ...
        'Shuffle', 'every-epoch', ...
        'ValidationFrequency', 30, ...
        'ValidationPatience', 5, ...
        'Verbose', true, ...
        'Plots', 'training-progress', ...
        'ExecutionEnvironment', 'auto');

    % Train PPR model
    disp('Training PPR Neural Network...');
    trainedNet_PPR = trainNetwork(X_feature_PPR_balanced, y_label_PPR_balanced, PPR_layers, options);
    save('trainedNet_PPR.mat', 'trainedNet_PPR');
    disp('PPR Neural Network training complete. Model saved as trainedNet_PPR.mat');
    
    % Train Eigenvalue model
    disp('Training Eigenvalue Neural Network...');
    trainedNet_Eig = trainNetwork(X_feature_Eig_balanced, y_label_Eig_balanced, Eig_layers, options);
    save('trainedNet_Eig.mat', 'trainedNet_Eig');
    disp('Eigenvalue Neural Network training complete. Model saved as trainedNet_Eig.mat');
end