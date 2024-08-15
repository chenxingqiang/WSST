function [X_PPR_filtered, X_Eig_filtered] = removeExtremelyLowVarianceFeatures(X_PPR, X_Eig)
% REMOVEEXTREMELYLOWVARIANCEFEATURES Remove features with extremely low variance
%
% Inputs:
%   X_PPR - PPR feature matrix
%   X_Eig - Eigenvalue feature matrix
%
% Outputs:
%   X_PPR_filtered - Filtered PPR feature matrix
%   X_Eig_filtered - Filtered Eigenvalue feature matrix

    tolerance = 1e-10;  % Extremely low variance threshold
    
    % Calculate variance across samples and scenarios
    var_PPR = var(X_PPR, [], [1, 3]);
    var_Eig = var(X_Eig, [], [1, 3]);
    
    % Remove low variance features
    X_PPR_filtered = X_PPR(:, var_PPR > tolerance, :);
    X_Eig_filtered = X_Eig(:, var_Eig > tolerance, :);
end