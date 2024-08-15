function PPR = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2)
% CALCULATEPPR Calculate Pilot Pollution Ratio
%   PPR = CALCULATEPPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2)
%   calculates the Pilot Pollution Ratio for each user
%
%   Inputs:
%   K - Number of user devices
%   M - Number of base station antennas
%   tau - Length of training sequence
%   P_UE - Transmit power of user equipment
%   Beta_UE - Path loss matrix for user equipment (M x K)
%   Y - Received signal at the base station (M x tau)
%   Phi - Training sequence matrix (tau x K)
%   sigma_n_2 - Noise variance
%
%   Output:
%   PPR - Pilot Pollution Ratio for each user (1 x K)

    PPR = zeros(1, K);
    for k = 1:K
        h_hat = Y * Phi(:, k) / (sqrt(P_UE * tau));
        PPR(k) = (norm(h_hat)^2 - M * sigma_n_2 / (P_UE * tau)) / (M * Beta_UE(1, k));
    end
end