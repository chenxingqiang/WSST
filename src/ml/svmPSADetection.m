function [trainedModel, accuracy] = svmPSADetection(X, y)
    % SVMPSADETECTION Train an SVM model for PSA detection
    %
    % Inputs:
    %   X - Feature matrix
    %   y - Labels (categorical)
    %
    % Outputs:
    %   trainedModel - Trained SVM model
    %   accuracy - Training accuracy

    % Convert categorical labels to numeric
    y_numeric = double(y) - 1;

    % Train SVM model
    SVMModel = fitcsvm(X, y_numeric, 'KernelFunction', 'rbf', ...
        'Standardize', true, 'ClassNames', [0, 1]);

    % Cross-validate the model
    CVSVMModel = crossval(SVMModel);

    % Calculate accuracy
    accuracy = 1 - kfoldLoss(CVSVMModel);

    % Train final model on all data
    trainedModel = fitcsvm(X, y_numeric, 'KernelFunction', 'rbf', ...
        'Standardize', true, 'ClassNames', [0, 1]);

    disp(['SVM Training Accuracy: ', num2str(accuracy)]);
end