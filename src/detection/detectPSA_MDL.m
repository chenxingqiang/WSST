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

    % Add these checks:
    if any(~isreal(MDL_values))
        warning('MDL values contain complex numbers');
        MDL_values = real(MDL_values);  % Take only the real part
    end
    
    if any(isnan(MDL_values) | isinf(MDL_values))
        warning('MDL values contain NaN or Inf');
        MDL_values = MDL_values(~isnan(MDL_values) & ~isinf(MDL_values));
    end

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



function threshold = otsuthreshold(values)
    % Remove any NaN or Inf values
    values = values(~isnan(values) & ~isinf(values));
    
    % Ensure values are real
    values = real(values);
    
    % Shift values to be positive
    values = values - min(values) + 1;
    
    % Ensure values are real
    if any(~isreal(values))
        warning('Values contain complex numbers. Taking real part.');
        values = real(values);
    end
    
    % Add these debug lines:
    disp(['Min value: ', num2str(min(values))]);
    disp(['Max value: ', num2str(max(values))]);

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

    % Shift the threshold back
    threshold = threshold + min(values) - 1;
    
    disp(['Calculated threshold: ', num2str(threshold)]);
end