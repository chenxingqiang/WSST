function [detection, PPR_values, threshold] = detectPSA_PPR(X_feature_PPR, varargin)
% DETECTPSA_PPR Detect Pilot Spoofing Attacks using Pilot Pollution Ratio
%
% This function implements a PPR-based detection method for identifying
% Pilot Spoofing Attacks in massive MIMO systems.
%
% Inputs:
%   X_feature_PPR - PPR features, size: [numSamples x numFeatures]
%
% Optional Name-Value Pair Arguments:
%   'Threshold'    - Detection threshold (default: auto-calculated)
%   'Method'       - Threshold calculation method: 'mean', 'median', or 'otsu' (default: 'otsu')
%   'Percentile'   - Percentile for threshold calculation if using 'mean' or 'median' (default: 95)
%
% Outputs:
%   detection   - Binary vector indicating detected attacks (1) or no attacks (0)
%   PPR_values  - Calculated PPR values for each sample
%   threshold   - The threshold used for detection
%
% Example:
%   [detection, PPR_values, threshold] = detectPSA_PPR(X_feature_PPR, 'Method', 'mean', 'Percentile', 90);

    % Input parsing
    p = inputParser;
    addRequired(p, 'X_feature_PPR', @(x) isnumeric(x) && ismatrix(x));
    addParameter(p, 'Threshold', [], @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'Method', 'otsu', @(x) ismember(x, {'mean', 'median', 'otsu'}));
    addParameter(p, 'Percentile', 95, @(x) isnumeric(x) && isscalar(x) && x > 0 && x < 100);
    parse(p, X_feature_PPR, varargin{:});

    % Extract PPR values (assuming the first feature is the primary PPR indicator)
    PPR_values = X_feature_PPR(:, 1);

    % Calculate threshold if not provided
    if isempty(p.Results.Threshold)
        switch p.Results.Method
            case 'mean'
                threshold = mean(PPR_values) + std(PPR_values) * norminv(p.Results.Percentile/100);
            case 'median'
                threshold = median(PPR_values) + 1.4826 * mad(PPR_values) * norminv(p.Results.Percentile/100);
            case 'otsu'
                threshold = otsuthreshold(PPR_values);
            otherwise
                error('Invalid threshold calculation method specified.');
        end
    else
        threshold = p.Results.Threshold;
    end

    % Perform detection
    detection = PPR_values > threshold;

    % Optional: You can add more sophisticated detection logic here
    % For example, you might want to consider temporal consistency or spatial correlation

    % Display detection results
    disp(['Number of detected attacks: ' num2str(sum(detection))]);
    disp(['Detection rate: ' num2str(mean(detection)*100) '%']);
    disp(['Threshold used: ' num2str(threshold)]);

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