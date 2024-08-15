function g_ED = generateEDChannel(M, Beta_ED)
% GENERATEEDCHANNEL Generate channel for eavesdropper device
%   g_ED = GENERATEEDCHANNEL(M, Beta_ED) returns the channel vector for the eavesdropper device
%
%   Inputs:
%   M - Number of base station antennas
%   Beta_ED - Path loss scalar for the eavesdropper
%
%   Output:
%   g_ED - Eavesdropper device channel vector (M x 1)

    g_ED = sqrt(Beta_ED/2) * (randn(M, 1) + 1i * randn(M, 1));
end