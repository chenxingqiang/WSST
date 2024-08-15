function [X_feature_PPR, X_feature_Eig, y_label] = generateDataset(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED)
% GENERATEDATASET Generate a dataset for Pilot Spoofing Attack (PSA) detection
%
% This function generates a synthetic dataset for training and testing
% PSA detection algorithms. It simulates a massive MIMO system with
% potential eavesdroppers attempting pilot spoofing attacks.
%
% Inputs:
%   M         - Number of base station antennas
%   K         - Number of legitimate users
%   tau       - Length of pilot sequence
%   gridSize  - Size of the simulation area (assumed square) in meters
%   nbLoc     - Number of different location realizations
%   nbChanReal- Number of channel realizations per location
%   P_ED      - Vector of eavesdropper transmit powers (in Watts)
%
% Outputs:
%   X_feature_PPR - PPR features, size: [numSamples x K x length(P_ED)]
%   X_feature_Eig - Eigenvalue features, size: [numSamples x M x length(P_ED)]
%   y_label       - Attack presence labels, size: [numSamples x length(P_ED)]
%
% Note: This function uses parallel computing to speed up data generation.
% Ensure that the Parallel Computing Toolbox is installed and configured.

    % Define constants
    P_UE_dBm = 23; % User equipment transmit power in dBm
    P_UE = 10^(-3) * 10^(P_UE_dBm/10); % Convert UE power to Watts
    Bandwidth = 20e6; % System bandwidth in Hz
    NF = 10^(5/10); % Noise figure (linear scale)
    NT = 290; % Noise temperature in Kelvin
    kappa = physconst('Boltzmann'); % Boltzmann constant
    sigma_n_2 = NT * kappa * Bandwidth * NF; % Noise variance

    % Preallocation of memory for efficiency
    numSamples = nbLoc * nbChanReal; % Total number of samples
    numPED = length(P_ED); % Number of eavesdropper power levels
    X_feature_PPR = zeros(numSamples, K, numPED);
    X_feature_Eig = zeros(numSamples, M, numPED);
    y_label = zeros(numSamples, numPED);

    % Generate training sequence (assumed to be the same for all realizations)
    A = hadamard(tau); % Generate Hadamard matrix
    Phi = A(:, 1:K); % Select K columns for K users

    % Use parallel computing for faster data generation
    parfor sample = 1:numSamples
        % Generate positions for base station, users, and eavesdropper
        [x_BS, y_BS, x_UE, y_UE, x_ED, y_ED] = generatePositions(K, gridSize);
        
        % Calculate path loss based on positions
        [Beta_UE, Beta_ED] = calculatePathLoss(M, K, x_BS, y_BS, x_UE, y_UE, x_ED, y_ED);
        
        % Generate channel matrices
        h_UE = generateUEChannels(M, K, Beta_UE);
        g_ED = generateEDChannel(M, Beta_ED);
        
        % Generate additive white Gaussian noise
        N = generateNoise(M, tau, sigma_n_2);
        
        for ii = 1:numPED
            % Randomly determine if an attack is present (30% probability)
            indAttPres = rand() < 0.3;
            
            % Randomly select a user to be attacked
            indAttUE = randi([1 K], 1);
            
            % Calculate signal-to-noise ratios
            SNR_UE = P_UE * mean(Beta_UE) / sigma_n_2;
            SNR_ED = P_ED(ii) * Beta_ED / sigma_n_2;
            
            % Adjust attack strength based on SNR ratio
            attack_strength = min(1, SNR_ED / SNR_UE);
            
            % Generate received signal at base station
            Y = sqrt(P_UE) * h_UE * Phi.' + ...
                indAttPres * attack_strength * sqrt(P_ED(ii)) * g_ED * Phi(:, indAttUE).' + N;
            
            % Calculate Pilot Pollution Ratio (PPR) feature
            PPR = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
            PPR_feature = sort(PPR / max(PPR), 'descend');
            
            % Calculate eigenvalue-based feature
            lambda_R = calculateEigenvalues(M, tau, P_UE, h_UE, Phi, g_ED, N, indAttPres, P_ED(ii), indAttUE, K);
            Eig_feature = lambda_R.' / max(lambda_R);
            
            % Store features and label
            X_feature_PPR(sample, :, ii) = PPR_feature;
            X_feature_Eig(sample, :, ii) = Eig_feature;
            y_label(sample, ii) = indAttPres;
        end
    end

    % Data augmentation: Add slight Gaussian noise to features
    X_feature_PPR = addGaussianNoise(X_feature_PPR, 0.01);
    X_feature_Eig = addGaussianNoise(X_feature_Eig, 0.01);

    % Feature selection: Remove features with extremely low variance
    [X_feature_PPR, X_feature_Eig] = removeExtremelyLowVarianceFeatures(X_feature_PPR, X_feature_Eig);

    % Ensure y_label is a 2D matrix
    y_label = reshape(y_label, [], numPED);
end

% Helper function to add Gaussian noise
function X_noisy = addGaussianNoise(X, noise_level)
    X_noisy = X + noise_level * randn(size(X));
end

% Helper function to remove features with extremely low variance
function [X_PPR_filtered, X_Eig_filtered] = removeExtremelyLowVarianceFeatures(X_PPR, X_Eig)
    var_PPR = var(X_PPR, [], [1, 3]);
    var_Eig = var(X_Eig, [], [1, 3]);
    X_PPR_filtered = X_PPR(:, var_PPR > 1e-10, :);
    X_Eig_filtered = X_Eig(:, var_Eig > 1e-10, :);
end