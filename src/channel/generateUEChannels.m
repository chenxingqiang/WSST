function h_UE = generateUEChannels(M, K, Beta_UE)
% GENERATEUECHANNELS Generate channels for user equipment
%   h_UE = GENERATEUECHANNELS(M, K, Beta_UE) returns the channel matrix for user equipment
%
%   Inputs:
%   M - Number of base station antennas
%   K - Number of user devices
%   Beta_UE - Path loss matrix (M x K)
%
%   Output:
%   h_UE - User equipment channel matrix (M x K)

    h_UE = sqrt(Beta_UE/2) .* (randn(M, K) + 1i * randn(M, K));
end