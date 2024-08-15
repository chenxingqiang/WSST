function trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label)
% TRAINANDSAVENNMODELS Train and save neural network models for PSA detection
%
% This function trains two neural network models for Pilot Spoofing Attack (PSA) detection:
% one using PPR (Pilot Pollution Ratio) features and another using eigenvalue-based features.
% It handles data preprocessing, balancing, and model training.
%
% Inputs:
%   X_feature_PPR - PPR features, size: [numSamples x numFeaturesPPR x numPED]
%   X_feature_Eig - Eigenvalue features, size: [numSamples x numFeaturesEig x numPED]
%   y_label       - Attack presence labels, size: [numSamples x numPED]
%
% Outputs:
%   This function does not return any values but saves the trained models to files:
%   'trainedNet_PPR.mat' and 'trainedNet_Eig.mat'
%
% Note: This function assumes that the Deep Learning Toolbox is available.

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
    y_label_cat = categorical(y_label_1D, [0, 1]);

    % Normalize features using z-score normalization
    X_feature_PPR_2D = normalize(X_feature_PPR_2D);
    X_feature_Eig_2D = normalize(X_feature_Eig_2D);

    % Balance the dataset to handle potential class imbalance
    [X_feature_PPR_balanced, y_label_PPR_balanced] = balanceDataset(X_feature_PPR_2D, y_label_cat);
    [X_feature_Eig_balanced, y_label_Eig_balanced] = balanceDataset(X_feature_Eig_2D, y_label_cat);

    % Define neural network structures
    numClasses = 2;  % Binary classification: attack or no attack
    
    % PPR Neural Network Structure
    PSADetector_Kinputs = [
        featureInputLayer(numFeaturesPPR, "Name", "Input")
        fullyConnectedLayer(128, "Name", "fc1")
        batchNormalizationLayer("Name", "bn1")
        reluLayer("Name", "relu1")
        dropoutLayer(0.5, "Name", "dropout1")
        fullyConnectedLayer(64, "Name", "fc2")
        batchNormalizationLayer("Name", "bn2")
        reluLayer("Name", "relu2")
        dropoutLayer(0.3, "Name", "dropout2")
        fullyConnectedLayer(32, "Name", "fc3")
        reluLayer("Name", "relu3")
        fullyConnectedLayer(numClasses, "Name", "fc4")
        softmaxLayer("Name", "softmax")
        classificationLayer("Name", "classification")];

    % Eigenvalue Neural Network Structure
    PSADetector_Minputs = [
        featureInputLayer(numFeaturesEig, "Name", "Input")
        fullyConnectedLayer(256, "Name", "fc1")
        batchNormalizationLayer("Name", "bn1")
        reluLayer("Name", "relu1")
        dropoutLayer(0.5, "Name", "dropout1")
        fullyConnectedLayer(128, "Name", "fc2")
        batchNormalizationLayer("Name", "bn2")
        reluLayer("Name", "relu2")
        dropoutLayer(0.4, "Name", "dropout2")
        fullyConnectedLayer(64, "Name", "fc3")
        batchNormalizationLayer("Name", "bn3")
        reluLayer("Name", "relu3")
        dropoutLayer(0.3, "Name", "dropout3")
        fullyConnectedLayer(32, "Name", "fc4")
        reluLayer("Name", "relu4")
        fullyConnectedLayer(numClasses, "Name", "fc5")
        softmaxLayer("Name", "softmax")
        classificationLayer("Name", "classification")];

    % Define training options
    options = trainingOptions('adam', ...
        'InitialLearnRate', 0.001, ...
        'MaxEpochs', 150, ...
        'MiniBatchSize', 64, ...
        'Shuffle', 'every-epoch', ...
        'Verbose', false, ...
        'Plots', 'training-progress');

    % Train PPR model
    disp('Training PPR Neural Network...');
    trainedNet_PPR = trainNetwork(X_feature_PPR_balanced, y_label_PPR_balanced, PSADetector_Kinputs, options);
    save('trainedNet_PPR.mat', 'trainedNet_PPR');
    disp('PPR Neural Network training complete. Model saved as trainedNet_PPR.mat');
    
    % Train Eigenvalue model
    disp('Training Eigenvalue Neural Network...');
    trainedNet_Eig = trainNetwork(X_feature_Eig_balanced, y_label_Eig_balanced, PSADetector_Minputs, options);
    save('trainedNet_Eig.mat', 'trainedNet_Eig');
    disp('Eigenvalue Neural Network training complete. Model saved as trainedNet_Eig.mat');
end

function [X_balanced, y_balanced] = balanceDataset(X, y)
% BALANCEDATASET Balance the dataset by undersampling the majority class
%
% This function balances a binary classification dataset by undersampling
% the majority class to match the number of samples in the minority class.
%
% Inputs:
%   X - Feature matrix
%   y - Labels (categorical)
%
% Outputs:
%   X_balanced - Balanced feature matrix
%   y_balanced - Balanced labels (categorical)

    % Find minority and majority classes
    classes = categories(y);
    numClasses = length(classes);
    counts = countcats(y);
    [~, minorityIdx] = min(counts);
    minorityClass = classes{minorityIdx};
    
    % Initialize balanced datasets
    X_balanced = [];
    y_balanced = categorical();
    
    % Balance each class
    for i = 1:numClasses
        currentClass = classes{i};
        idx = y == currentClass;
        X_class = X(idx, :);
        y_class = y(idx);
        
        if strcmp(currentClass, minorityClass)
            % Keep all samples of minority class
            X_balanced = [X_balanced; X_class];
            y_balanced = [y_balanced; y_class];
        else
            % Undersample majority class
            numSamples = sum(y == minorityClass);
            randIdx = randperm(size(X_class, 1), numSamples);
            X_balanced = [X_balanced; X_class(randIdx, :)];
            y_balanced = [y_balanced; y_class(randIdx)];
        end
    end
    
    % Shuffle the balanced dataset
    randIdx = randperm(size(X_balanced, 1));
    X_balanced = X_balanced(randIdx, :);
    y_balanced = y_balanced(randIdx);
end