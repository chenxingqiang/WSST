function [detection, detection_metrics, threshold] = enhancedPSADetection(X_features, P_ED, varargin)
% ENHANCEDPSADETECTION Enhanced PSA Detection with Power Sensitivity
%
% This function implements enhanced PSA detection that is more sensitive
% to eavesdropper power variations by:
% 1. Using power-dependent features
% 2. Implementing adaptive thresholds
% 3. Combining multiple detection metrics
%
% Inputs:
%   X_features - Feature matrix including power-sensitive features
%   P_ED       - Vector of eavesdropper powers used for training
%
% Optional Name-Value Pair Arguments:
%   'Method'       - Detection method: 'adaptive', 'ensemble', 'power_weighted' (default: 'adaptive')
%   'Threshold'    - Base detection threshold (default: auto-calculated)
%   'PowerWeight'  - Power weighting factor for threshold adjustment (default: 0.5)
%   'Sensitivity'  - Detection sensitivity level: 'low', 'medium', 'high' (default: 'medium')
%
% Outputs:
%   detection        - Binary vector indicating detected attacks
%   detection_metrics - Structure containing detection performance metrics
%   threshold        - The threshold(s) used for detection

    % Input parsing
    p = inputParser;
    addRequired(p, 'X_features', @(x) isnumeric(x) && ismatrix(x));
    addRequired(p, 'P_ED', @(x) isnumeric(x) && isvector(x));
    addParameter(p, 'Method', 'adaptive', @(x) ismember(x, {'adaptive', 'ensemble', 'power_weighted'}));
    addParameter(p, 'Threshold', [], @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'PowerWeight', 0.5, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
    addParameter(p, 'Sensitivity', 'medium', @(x) ismember(x, {'low', 'medium', 'high'}));
    parse(p, X_features, P_ED, varargin{:});

    % Get parameters
    method = p.Results.Method;
    base_threshold = p.Results.Threshold;
    power_weight = p.Results.PowerWeight;
    sensitivity = p.Results.Sensitivity;
    
    % Calculate number of power levels
    num_power_levels = length(P_ED);
    num_samples = size(X_features, 1);
    
    % Initialize outputs
    detection = false(num_samples, num_power_levels);
    detection_metrics = struct();
    
    % Calculate base threshold if not provided
    if isempty(base_threshold)
        base_threshold = calculateBaseThreshold(X_features, sensitivity);
    end
    
    % Perform detection based on method
    switch method
        case 'adaptive'
            [detection, detection_metrics, threshold] = adaptiveDetection(X_features, P_ED, base_threshold, power_weight, sensitivity);
        case 'ensemble'
            [detection, detection_metrics, threshold] = ensembleDetection(X_features, P_ED, base_threshold, power_weight, sensitivity);
        case 'power_weighted'
            [detection, detection_metrics, threshold] = powerWeightedDetection(X_features, P_ED, base_threshold, power_weight, sensitivity);
        otherwise
            error('Invalid detection method specified.');
    end
    
    % Calculate overall detection metrics
    detection_metrics.overall_detection_rate = mean(detection(:));
    detection_metrics.power_sensitivity = calculatePowerSensitivity(detection, P_ED);
    detection_metrics.method_used = method;
    detection_metrics.sensitivity_level = sensitivity;
    
    % Display results
    disp(['Enhanced PSA Detection Results - Method: ' method]);
    disp(['Overall Detection Rate: ' num2str(detection_metrics.overall_detection_rate*100) '%']);
    disp(['Power Sensitivity Index: ' num2str(detection_metrics.power_sensitivity)]);
    disp(['Sensitivity Level: ' sensitivity]);
end

function threshold = calculateBaseThreshold(X_features, sensitivity)
    % Calculate base threshold based on sensitivity level
    feature_std = std(X_features(:));
    feature_mean = mean(X_features(:));
    
    switch sensitivity
        case 'low'
            threshold = feature_mean + 2 * feature_std;
        case 'medium'
            threshold = feature_mean + 1.5 * feature_std;
        case 'high'
            threshold = feature_mean + 1 * feature_std;
        otherwise
            threshold = feature_mean + 1.5 * feature_std;
    end
end

function [detection, metrics, threshold] = adaptiveDetection(X_features, P_ED, base_threshold, power_weight, sensitivity)
    % Adaptive detection that adjusts threshold based on power level
    num_power_levels = length(P_ED);
    num_samples = size(X_features, 1);
    
    detection = false(num_samples, num_power_levels);
    threshold = zeros(1, num_power_levels);
    
    % Calculate power-dependent thresholds
    for i = 1:num_power_levels
        % Adjust threshold based on power level
        power_factor = (P_ED(i) / max(P_ED))^power_weight;
        
        % Higher power should lower threshold for better detection
        threshold(i) = base_threshold * (1 - 0.3 * power_factor);
        
        % Perform detection
        detection(:, i) = X_features(:, i) > threshold(i);
    end
    
    % Calculate metrics
    metrics = calculateDetectionMetrics(detection, P_ED);
    metrics.threshold_adaptation = threshold;
end

function [detection, metrics, threshold] = ensembleDetection(X_features, P_ED, base_threshold, power_weight, sensitivity)
    % Ensemble detection combining multiple approaches
    num_power_levels = length(P_ED);
    num_samples = size(X_features, 1);
    
    detection = false(num_samples, num_power_levels);
    threshold = zeros(1, num_power_levels);
    
    % Multiple detection approaches
    for i = 1:num_power_levels
        % Approach 1: Power-adjusted threshold
        threshold1 = base_threshold * (1 - 0.3 * (P_ED(i) / max(P_ED))^power_weight);
        
        % Approach 2: Statistical threshold
        feature_stats = X_features(:, i);
        threshold2 = mean(feature_stats) + 1.5 * std(feature_stats);
        
        % Approach 3: Percentile-based threshold
        threshold3 = prctile(feature_stats, 85);
        
        % Combine thresholds (weighted average)
        threshold(i) = 0.4 * threshold1 + 0.3 * threshold2 + 0.3 * threshold3;
        
        % Perform detection
        detection(:, i) = X_features(:, i) > threshold(i);
    end
    
    % Calculate metrics
    metrics = calculateDetectionMetrics(detection, P_ED);
    metrics.threshold_ensemble = threshold;
end

function [detection, metrics, threshold] = powerWeightedDetection(X_features, P_ED, base_threshold, power_weight, sensitivity)
    % Power-weighted detection emphasizing power sensitivity
    num_power_levels = length(P_ED);
    num_samples = size(X_features, 1);
    
    detection = false(num_samples, num_power_levels);
    threshold = zeros(1, num_power_levels);
    
    % Calculate power weights for each power level
    power_weights = (P_ED / max(P_ED)).^power_weight;
    
    for i = 1:num_power_levels
        % Power-dependent threshold adjustment
        power_factor = power_weights(i);
        
        % More aggressive threshold reduction for higher powers
        threshold(i) = base_threshold * (1 - 0.5 * power_factor);
        
        % Additional power-based feature enhancement
        enhanced_features = X_features(:, i) * (1 + power_factor);
        
        % Perform detection
        detection(:, i) = enhanced_features > threshold(i);
    end
    
    % Calculate metrics
    metrics = calculateDetectionMetrics(detection, P_ED);
    metrics.threshold_power_weighted = threshold;
    metrics.power_weights = power_weights;
end

function metrics = calculateDetectionMetrics(detection, P_ED)
    % Calculate comprehensive detection metrics
    num_power_levels = length(P_ED);
    
    metrics = struct();
    metrics.detection_rate_per_power = mean(detection, 1);
    metrics.total_detections = sum(detection, 1);
    metrics.power_levels = P_ED;
    
    % Calculate power sensitivity metrics
    if num_power_levels > 1
        % Correlation between power and detection rate
        power_corr = corrcoef(P_ED, metrics.detection_rate_per_power);
        metrics.power_detection_correlation = power_corr(1, 2);
        
        % Detection rate improvement with power
        detection_improvement = diff(metrics.detection_rate_per_power);
        metrics.detection_improvement = detection_improvement;
        metrics.avg_improvement_per_power = mean(detection_improvement);
    end
end

function sensitivity_index = calculatePowerSensitivity(detection, P_ED)
    % Calculate power sensitivity index
    detection_rate = mean(detection, 1);
    
    if length(P_ED) > 1
        % Calculate slope of detection rate vs power
        power_normalized = P_ED / max(P_ED);
        detection_normalized = detection_rate / max(detection_rate);
        
        % Linear regression slope
        slope = (length(P_ED) * sum(power_normalized .* detection_normalized) - ...
                sum(power_normalized) * sum(detection_normalized)) / ...
               (length(P_ED) * sum(power_normalized.^2) - sum(power_normalized)^2);
        
        sensitivity_index = slope;
    else
        sensitivity_index = 0;
    end
end
