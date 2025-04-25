function [attackedUserIndices, attackedUserMetrics] = detectAttackedUsers(Y, Phi, K, M, tau, P_UE, Beta_UE, sigma_n_2)
% DETECTATTACKEDUSERS Detect which specific user(s) are being attacked in a PSA scenario
%
% This function uses the Power Projection Ratio (PPR) method to identify which
% specific users are being affected by a pilot spoofing attack.
%
% Inputs:
%   Y - Received signal matrix (M x tau)
%   Phi - Pilot sequence matrix (tau x K)
%   K - Number of legitimate users
%   M - Number of base station antennas
%   tau - Length of pilot sequence
%   P_UE - Transmit power of legitimate users
%   Beta_UE - Large-scale fading coefficients (M x K)
%   sigma_n_2 - Noise variance
%
% Outputs:
%   attackedUserIndices - Indices of users detected as being attacked
%   attackedUserMetrics - Detection metrics for each user

    % Calculate PPR for each user
    PPR_values = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
    
    % Set PPR threshold for attack detection (can be adjusted based on calibration)
    % This threshold could be determined dynamically based on noise level
    % or through statistical analysis of the legitimate user PPR distribution
    PPR_threshold = 0.5;
    
    % Identify users with PPR values above the threshold
    attackedUserIndices = find(PPR_values > PPR_threshold);
    attackedUserMetrics = PPR_values;
    
    % If no users are above threshold, return empty
    if isempty(attackedUserIndices)
        disp('No users detected as being attacked');
    else
        disp(['Detected ', num2str(length(attackedUserIndices)), ' user(s) being attacked']);
        disp(['Attacked user indices: ', num2str(attackedUserIndices')]);
    end
end
