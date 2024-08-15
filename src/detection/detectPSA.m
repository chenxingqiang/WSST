function [isAttackDetected, detectionMetric] = detectPSA(X_feature, threshold)
% DETECTPSA Detect Pilot Spoofing Attack
%   [isAttackDetected, detectionMetric] = DETECTPSA(X_feature, threshold)
%   detects the presence of a Pilot Spoofing Attack based on input features
%
%   Inputs:
%   X_feature - Feature vector or matrix for PSA detection
%   threshold - Detection threshold
%
%   Outputs:
%   isAttackDetected - Boolean indicating whether an attack is detected
%   detectionMetric - Numerical metric used for detection decision

    % Calculate detection metric (example: using max eigenvalue)
    detectionMetric = max(X_feature);
    
    % Make detection decision
    isAttackDetected = detectionMetric > threshold;
end