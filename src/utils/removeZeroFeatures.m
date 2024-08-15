function [X_filtered, kept_features] = removeZeroFeatures(X, tolerance)
% REMOVEZEROFEATURES Remove features with zero or near-zero variance
%
% Inputs:
%   X         - Input feature matrix (samples x features)
%   tolerance - Variance threshold (default: 1e-6)
%
% Outputs:
%   X_filtered    - Filtered feature matrix
%   kept_features - Logical vector indicating which features were kept

    if nargin < 2
        tolerance = 1e-6;
    end

    % Calculate variance of each feature
    feature_variance = var(X, [], 1);
    
    % Identify features to keep
    kept_features = feature_variance > tolerance;
    
    % Filter features
    X_filtered = X(:, kept_features);
end