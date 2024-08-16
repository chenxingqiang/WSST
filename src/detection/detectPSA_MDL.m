function [detection, MDL_values, threshold] = detectPSA_MDL(X_feature_Eig, varargin)
% DETECTPSA_MDL Detect Pilot Spoofing Attacks using Minimum Description Length
%
% This function implements an MDL-based detection method for identifying
% Pilot Spoofing Attacks in massive MIMO systems.
%
% Inputs:
%   X_feature_Eig - Eigenvalue-based features, size: [numSamples x numFeatures]
%
% Optional Name-Value Pair Arguments:
%   'Threshold'    - Detection threshold (default: auto-calculated)
%   'Method'       - Threshold calculation method: 'mean', 'median', or 'otsu' (default: 'otsu')
%   'Percentile'   - Percentile for threshold calculation if using 'mean' or 'median' (default: 95)
%
% Outputs:
%   detection   - Binary vector indicating detected attacks (1) or no attacks (0)
%   MDL_values  - Calculated MDL values for each sample
%   threshold   - The threshold used for detection
%
% Example:
%   [detection, MDL_values, threshold] = detectPSA_MDL(X_feature_Eig, 'Method', 'mean', 'Percentile', 90);

    % Input parsing
    p = inputParser;
    addRequired(p, 'X_feature_Eig', @(x) isnumeric(x) && ismatrix(x));
    addParameter(p, 'Threshold', [], @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'Method', 'otsu', @(x) ismember(x, {'mean', 'median', 'otsu'}));
    addParameter(p, 'Percentile', 95, @(x) isnumeric(x) && isscalar(x) && x > 0 && x < 100);
    parse(p, X_feature_Eig, varargin{:});

    % Calculate MDL values
    MDL_values = calculateMDL(X_feature_Eig);

    % Calculate threshold if not provided
    if isempty(p.Results.Threshold)
        switch p.Results.Method
            case 'mean'
                threshold = mean(MDL_values) + std(MDL_values) * norminv(p.Results.Percentile/100);
            case 'median'
                threshold = median(MDL_values) + 1.4826 * mad(MDL_values) * norminv(p.Results.Percentile/100);
            case 'otsu'
                threshold = otsuthreshold(MDL_values);
            otherwise
                error('Invalid threshold calculation method specified.');
        end
    else
        threshold = p.Results.Threshold;
    end

    % Perform detection
    detection = MDL_values > threshold;

    % Display detection results
    disp(['Number of detected attacks: ' num2str(sum(detection))]);
    disp(['Detection rate: ' num2str(mean(detection)*100) '%']);
    disp(['Threshold used: ' num2str(threshold)]);

    
end

function MDL_values = calculateMDL(X_feature_Eig)
    % Calculate MDL values based on eigenvalue features
    % This is a simplified placeholder implementation
    % In practice, you would implement the actual MDL calculation here
    MDL_values = sum(log(X_feature_Eig), 2);
end

function threshold = otsuthreshold(values)
    % Implement Otsu's method for threshold calculation
    [counts, edges] = histcounts(values, 'Normalization', 'probability');
    binCenters = (edges(1:end-1) + edges(2:end)) / 2;
    
    totalMean = sum(binCenters .* counts);
    w0 = cumsum(counts);
    w1 = 1 - w0;
    mu0 = cumsum(binCenters .* counts) ./ w0;
    mu1 = (totalMean - w0 .* mu0) ./ w1;
    
    betweenClassVariance = w0 .* w1 .* (mu0 - mu1).^2;
    [~, maxIndex] = max(betweenClassVariance);
    threshold = binCenters(maxIndex);
end