function [trainedModel, accuracy] = gradientBoostingPSADetection(X, y)
    % GRADIENTBOOSTINGPSADETECTION Train a Gradient Boosting model for PSA detection
    %
    % Inputs:
    %   X - Feature matrix
    %   y - Labels (categorical)
    %
    % Outputs:
    %   trainedModel - Trained Gradient Boosting model
    %   accuracy - Training accuracy

    % Convert categorical labels to numeric
    y_numeric = double(y) - 1;

    % Train Gradient Boosting model
    trainedModel = fitcensemble(X, y_numeric, 'Method', 'GentleBoost', ...
        'NumLearningCycles', 100, 'Learners', 'tree');

    % Cross-validate the model
    cvModel = crossval(trainedModel);

    % Calculate accuracy
    accuracy = 1 - kfoldLoss(cvModel);

    disp(['Gradient Boosting Training Accuracy: ', num2str(accuracy)]);
end