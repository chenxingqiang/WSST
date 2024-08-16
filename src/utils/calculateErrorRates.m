function [FPR, FNR] = calculateErrorRates(predictions, y_true, numPED)
    % CALCULATEERRORRATES Calculate False Positive Rate and False Negative Rate
    %
    % Inputs:
    % predictions - Predicted labels (array or cell array of categorical or logical)
    % y_true - True labels (array or cell array of categorical or logical)
    % numPED - Number of expected P_ED levels
    %
    % Outputs:
    % FPR - False Positive Rate (array)
    % FNR - False Negative Rate (array)

    % Check if inputs are cell arrays, if not, convert them
    if ~iscell(predictions)
        predictions = {predictions};
    end
    if ~iscell(y_true)
        y_true = {y_true};
    end

    FPR = zeros(1, numPED);
    FNR = zeros(1, numPED);

    for i = 1:length(predictions)
        pred = predictions{i};
        true_labels = y_true{i};

        % Ensure inputs are logical
        if iscategorical(pred)
            pred = pred == categorical(1);
        end
        if iscategorical(true_labels)
            true_labels = true_labels == categorical(1);
        end

        % Calculate confusion matrix
        TP = sum(pred & true_labels);
        TN = sum(~pred & ~true_labels);
        FP = sum(pred & ~true_labels);
        FN = sum(~pred & true_labels);

        % Calculate rates
        FPR(i) = FP / (FP + TN);
        FNR(i) = FN / (TP + FN);
    end

    % If we have fewer results than expected, pad with NaN
    if length(FPR) < numPED
        FPR(end+1:numPED) = NaN;
        FNR(end+1:numPED) = NaN;
    end
end