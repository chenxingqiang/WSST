function N = generateNoise(M, tau, sigma_n_2)
% GENERATENOISE Generate additive white Gaussian noise
%   N = GENERATENOISE(M, tau, sigma_n_2) generates a noise matrix
%
%   Inputs:
%   M - Number of base station antennas
%   tau - Number of time samples
%   sigma_n_2 - Noise variance
%
%   Output:
%   N - Noise matrix (M x tau)

    N = sqrt(sigma_n_2/2) * (randn(M, tau) + 1i * randn(M, tau));
end