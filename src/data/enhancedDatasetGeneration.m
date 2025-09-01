function [X_features_enhanced, y_label_enhanced, power_metrics] = enhancedDatasetGeneration(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, varargin)
% ENHANCEDDATASETGENERATION Generate Enhanced Dataset with Power Sensitivity
%
% This function generates an enhanced dataset that is more sensitive to
% eavesdropper power variations by:
% 1. Removing hard limits on attack strength
% 2. Adding power-dependent features
% 3. Including SNR difference metrics
% 4. Preserving power information in features
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
% Optional Name-Value Pair Arguments:
%   'FeatureType'  - Type of features: 'combined', 'power_weighted', 'snr_based' (default: 'combined')
%   'Normalization' - Feature normalization: 'none', 'minmax', 'zscore' (default: 'power_preserving')
%   'PowerWeight'   - Power weighting factor (default: 0.7)
%
% Outputs:
%   X_features_enhanced - Enhanced features with power sensitivity
%   y_label_enhanced    - Attack presence labels
%   power_metrics       - Structure containing power-related metrics

    % Input parsing
    p = inputParser;
    addRequired(p, 'M', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'K', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'tau', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'gridSize', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'nbLoc', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'nbChanReal', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'P_ED', @(x) isnumeric(x) && isvector(x) && all(x > 0));
    addParameter(p, 'FeatureType', 'combined', @(x) ismember(x, {'combined', 'power_weighted', 'snr_based'}));
    addParameter(p, 'Normalization', 'power_preserving', @(x) ismember(x, {'none', 'minmax', 'zscore', 'power_preserving'}));
    addParameter(p, 'PowerWeight', 0.7, @(x) isnumeric(x) && isscalar(x) && x >= 0 && x <= 1);
    parse(p, M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, varargin{:});

    % Get parameters
    feature_type = p.Results.FeatureType;
    normalization = p.Results.Normalization;
    power_weight = p.Results.PowerWeight;

    % Define constants
    P_UE_dBm = 23; % User equipment transmit power in dBm
    P_UE = 10^(-3) * 10^(P_UE_dBm/10); % Convert UE power to Watts
    Bandwidth = 20e6; % System bandwidth in Hz
    NF = 10^(5/10); % Noise figure (linear scale)
    NT = 290; % Noise temperature in Kelvin
    kappa = physconst('Boltzmann'); % Boltzmann constant
    sigma_n_2 = NT * kappa * Bandwidth * NF; % Noise variance

    % Preallocation
    numSamples = nbLoc * nbChanReal;
    numPED = length(P_ED);
    
    % Enhanced feature structure
    X_features_enhanced = cell(numPED, 1);
    y_label_enhanced = zeros(numSamples, numPED);
    power_metrics = struct();
    power_metrics.power_levels = P_ED;
    power_metrics.feature_types = {};
    power_metrics.power_sensitivity = [];

    % Generate training sequence
    A = hadamard(tau);
    Phi = A(:, 1:K);

    % Generate dataset for each power level
    for ii = 1:numPED
        disp(['Generating enhanced dataset for power level ' num2str(ii) '/' num2str(numPED)]);
        
        % Initialize features for this power level
        features_this_power = [];
        
        for sample = 1:numSamples
            % Generate positions and channels
            [x_BS, y_BS, x_UE, y_UE, x_ED, y_ED] = generatePositions(K, gridSize);
            [Beta_UE, Beta_ED] = calculatePathLoss(M, K, x_BS, y_BS, x_UE, y_UE, x_ED, y_ED);
            h_UE = generateUEChannels(M, K, Beta_UE);
            g_ED = generateEDChannel(M, Beta_ED);
            N = generateNoise(M, tau, sigma_n_2);
            
            % Generate attack scenario
            indAttPres = rand() < 0.3; % 30% chance of PSA
            indAttUE = randi([1 K], 1);
            
            % Calculate enhanced attack metrics
            attack_metrics = calculateEnhancedAttackMetrics(h_UE, g_ED, Beta_UE, Beta_ED, ...
                P_UE, P_ED(ii), sigma_n_2, indAttPres, indAttUE, power_weight);
            
            % Generate received signal using enhanced simulation
            Y = enhancedSignalGeneration(h_UE, g_ED, Phi, P_UE, P_ED(ii), N, ...
                indAttPres, indAttUE, attack_metrics);
            
            % Calculate enhanced features
            sample_features = calculateEnhancedFeatures(Y, h_UE, g_ED, Phi, P_UE, P_ED(ii), ...
                Beta_UE, Beta_ED, sigma_n_2, attack_metrics, feature_type);
            
            % Store features
            if isempty(features_this_power)
                features_this_power = zeros(numSamples, length(sample_features));
            end
            features_this_power(sample, :) = sample_features;
            
            % Store label
            y_label_enhanced(sample, ii) = indAttPres;
        end
        
        % Store features for this power level
        X_features_enhanced{ii} = features_this_power;
        
        % Calculate power sensitivity metrics
        power_metrics.feature_types{ii} = feature_type;
        power_metrics.power_sensitivity(ii) = calculateFeaturePowerSensitivity(features_this_power, P_ED(ii));
    end
    
    % Apply normalization if requested
    if ~strcmp(normalization, 'none')
        X_features_enhanced = applyNormalization(X_features_enhanced, normalization, P_ED);
    end
    
    % Calculate overall power sensitivity
    power_metrics.overall_sensitivity = mean(power_metrics.power_sensitivity);
    power_metrics.feature_type_used = feature_type;
    power_metrics.normalization_method = normalization;
    
    disp(['Enhanced dataset generation complete. Overall power sensitivity: ' num2str(power_metrics.overall_sensitivity)]);
end

function attack_metrics = calculateEnhancedAttackMetrics(h_UE, g_ED, Beta_UE, Beta_ED, P_UE, P_ED, sigma_n_2, indAttPres, indAttUE, power_weight)
    % Calculate comprehensive attack metrics without hard limits
    
    attack_metrics = struct();
    attack_metrics.attack_present = indAttPres;
    attack_metrics.attacked_user = indAttUE;
    
    if indAttPres
        % Calculate SNR metrics
        SNR_UE = P_UE * Beta_UE(:, indAttUE) / sigma_n_2;
        SNR_ED = P_ED * Beta_ED / sigma_n_2;
        
        % Enhanced attack strength (no hard limits)
        attack_metrics.SNR_UE = SNR_UE;
        attack_metrics.SNR_ED = SNR_ED;
        attack_metrics.SNR_ratio = SNR_ED / mean(SNR_UE);
        attack_metrics.power_ratio = P_ED / P_UE;
        
        % Channel correlation
        h_attacked = h_UE(:, indAttUE);
        channel_corr = abs(g_ED' * h_attacked) / (norm(g_ED) * norm(h_attacked));
        attack_metrics.channel_correlation = channel_corr;
        
        % Combined attack strength
        attack_metrics.attack_strength = (P_ED / P_UE)^power_weight * channel_corr;
        
        % Path loss impact
        attack_metrics.path_loss_ratio = Beta_ED / mean(Beta_UE(:, indAttUE));
        
    else
        % No attack case
        attack_metrics.SNR_UE = P_UE * Beta_UE(:, indAttUE) / sigma_n_2;
        attack_metrics.SNR_ED = P_ED * Beta_ED / sigma_n_2;
        attack_metrics.SNR_ratio = 0;
        attack_metrics.power_ratio = 0;
        attack_metrics.channel_correlation = 0;
        attack_metrics.attack_strength = 0;
        attack_metrics.path_loss_ratio = 0;
    end
end

function Y = enhancedSignalGeneration(h_UE, g_ED, Phi, P_UE, P_ED, N, indAttPres, indAttUE, attack_metrics)
    % Generate enhanced received signal
    
    % Base signal
    Y = sqrt(P_UE) * h_UE * Phi.' + N;
    
    if indAttPres
        % Enhanced attack signal
        attack_signal = sqrt(P_ED) * g_ED * Phi(:, indAttUE).';
        
        % Scale by attack strength for better power sensitivity
        if isfield(attack_metrics, 'attack_strength')
            attack_signal = attack_metrics.attack_strength * attack_signal;
        end
        
        Y = Y + attack_signal;
    end
end

function features = calculateEnhancedFeatures(Y, h_UE, g_ED, Phi, P_UE, P_ED, Beta_UE, Beta_ED, sigma_n_2, attack_metrics, feature_type)
    % Calculate enhanced features with power sensitivity
    
    [M, K] = size(h_UE);
    tau = size(Phi, 1);
    
    switch feature_type
        case 'combined'
            % Combine multiple feature types
            features = [];
            
            % PPR features
            PPR = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
            features = [features, PPR];
            
            % Eigenvalue features
            R = (Y * Y') / tau;
            lambda_R = eig(R);
            lambda_R = sort(lambda_R, 'descend');
            features = [features, lambda_R(1:min(10, M))']; % Top 10 eigenvalues
            
            % Power-dependent features
            if attack_metrics.attack_present
                power_features = [P_ED/P_UE, attack_metrics.SNR_ratio, attack_metrics.channel_correlation];
            else
                power_features = [0, 0, 0];
            end
            features = [features, power_features];
            
        case 'power_weighted'
            % Power-weighted features
            features = [];
            
            % Basic PPR
            PPR = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
            
            % Power-weighted PPR
            if attack_metrics.attack_present
                power_weight = (P_ED / P_UE)^0.5;
                PPR_weighted = PPR * power_weight;
            else
                PPR_weighted = PPR;
            end
            
            features = [PPR_weighted, PPR, P_ED/P_UE];
            
        case 'snr_based'
            % SNR-based features
            features = [];
            
            % SNR features
            SNR_UE = P_UE * Beta_UE / sigma_n_2;
            SNR_ED = P_ED * Beta_ED / sigma_n_2;
            
            % SNR difference features
            SNR_diff = SNR_ED - SNR_UE;
            SNR_ratio = SNR_ED ./ (SNR_UE + eps);
            
            features = [SNR_UE(:)', SNR_ED, SNR_diff(:)', SNR_ratio(:)'];
            
        otherwise
            error('Unknown feature type');
    end
end

function sensitivity = calculateFeaturePowerSensitivity(features, P_ED)
    % Calculate power sensitivity of features
    
    % Use variance as a proxy for power sensitivity
    feature_variance = var(features, 0, 1);
    
    % Weight by power level
    power_factor = P_ED / 1e-3; % Normalize to 1mW baseline
    
    sensitivity = mean(feature_variance) * power_factor;
end

function X_normalized = applyNormalization(X_features, normalization, P_ED)
    % Apply normalization while preserving power information
    
    num_power_levels = length(P_ED);
    X_normalized = cell(num_power_levels, 1);
    
    for ii = 1:num_power_levels
        features = X_features{ii};
        
        switch normalization
            case 'minmax'
                % Min-max normalization
                X_normalized{ii} = (features - min(features, [], 1)) ./ (max(features, [], 1) - min(features, [], 1) + eps);
                
            case 'zscore'
                % Z-score normalization
                X_normalized{ii} = (features - mean(features, 1)) ./ (std(features, 1) + eps);
                
            case 'power_preserving'
                % Power-preserving normalization
                power_factor = (P_ED(ii) / max(P_ED))^0.5;
                X_normalized{ii} = features * power_factor;
                
            otherwise
                X_normalized{ii} = features;
        end
    end
end
