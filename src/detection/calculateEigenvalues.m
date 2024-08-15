function lambda_R = calculateEigenvalues(M, tau, P_UE, h_UE, Phi, g_ED, N, indAttPres, P_ED, indAttUE, K)
% CALCULATEEIGENVALUES Calculate eigenvalues for PSA detection
%
% This function calculates the eigenvalues of the sample covariance matrix
% of the received signal, which can be used for PSA detection.
%
% Inputs:
%   M         - Number of base station antennas
%   tau       - Length of training sequence
%   P_UE      - Transmit power of user equipment
%   h_UE      - Channel matrix for legitimate users, size: [M x K]
%   Phi       - Training sequence matrix, size: [tau x K]
%   g_ED      - Channel vector for eavesdropper, size: [M x 1]
%   N         - Noise matrix, size: [M x tau]
%   indAttPres- Indicator of attack presence (logical: true or false)
%   P_ED      - Transmit power of eavesdropper
%   indAttUE  - Index of the attacked user
%   K         - Number of legitimate users
%
% Output:
%   lambda_R  - Eigenvalues of the sample covariance matrix, sorted in descending order

    % Input validation
    validateattributes(M, {'numeric'}, {'positive', 'integer', 'scalar'});
    validateattributes(tau, {'numeric'}, {'positive', 'integer', 'scalar'});
    validateattributes(P_UE, {'numeric'}, {'positive', 'scalar'});
    validateattributes(h_UE, {'numeric'}, {'size', [M, K]});
    validateattributes(Phi, {'numeric'}, {'size', [tau, K]});
    validateattributes(g_ED, {'numeric'}, {'column', 'numel', M});
    validateattributes(N, {'numeric'}, {'size', [M, tau]});
    validateattributes(indAttPres, {'logical'}, {'scalar'});
    validateattributes(P_ED, {'numeric'}, {'positive', 'scalar'});
    validateattributes(indAttUE, {'numeric'}, {'integer', 'positive', '<=', K, 'scalar'});

    % Generate received signal
    Y = sqrt(P_UE) * h_UE * Phi.' + N;
    if indAttPres
        Y = Y + sqrt(P_ED) * g_ED * Phi(:, indAttUE).';
    end
    
    % Calculate sample covariance matrix
    R = (Y * Y') / tau;
    
    % Calculate eigenvalues
    lambda_R = eig(R);
    lambda_R = sort(lambda_R, 'descend');
end