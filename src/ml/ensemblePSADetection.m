function [trainedEnsemble, accuracy] = ensemblePSADetection(X, y)
    % ENSEMBLEPSADETECTION Train an ensemble of models for PSA detection
    %
    % Inputs:
    %   X - Feature matrix
    %   y - Labels (categorical)
    %
    % Outputs:
    %   trainedEnsemble - Struct containing trained models
    %   accuracy - Training accuracy

    % Train individual models
    [svmModel, ~] = svmPSADetection(X, y);
    [rfModel, ~] = randomForestPSADetection(X, y);
    [nnModel, ~] = trainNeuralNetwork(X, y);  % Assuming you have this function

    % Combine models into an ensemble
    trainedEnsemble.svm = svmModel;
    trainedEnsemble.rf = rfModel;
    trainedEnsemble.nn = nnModel;

    % Make predictions using the ensemble
    svmPred = predict(svmModel, X);
    rfPred = predict(rfModel, X);
    nnPred = classify(nnModel, X);

    % Combine predictions (simple majority voting)
    ensemblePred = mode(cat(2, svmPred, rfPred, nnPred), 2);

    % Calculate accuracy
    accuracy = sum(ensemblePred == y) / numel(y);

    disp(['Ensemble Training Accuracy: ', num2str(accuracy)]);
end