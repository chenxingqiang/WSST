function [trainedModel, accuracy] = randomForestPSADetection(X, y)
    % RANDOMFORESTPSADETECTION Train a Random Forest model for PSA detection
    %
    % Inputs:
    %   X - Feature matrix
    %   y - Labels (categorical)
    %
    % Outputs:
    %   trainedModel - Trained Random Forest model
    %   accuracy - Training accuracy

    % Train Random Forest model
    numTrees = 100;
    trainedModel = TreeBagger(numTrees, X, y, 'Method', 'classification');

    % Predict on training data
    predictions = predict(trainedModel, X);
    predictions = categorical(cellfun(@str2num, predictions));

    % Calculate accuracy
    accuracy = sum(predictions == y) / numel(y);

    disp(['Random Forest Training Accuracy: ', num2str(accuracy)]);
end