function [Y, attack_metrics] = enhancedPSASimulation(h_UE, g_ED, Phi, P_UE, P_ED, N, indAttPres, indAttUE, varargin)
% ENHANCEDPSASIMULATION Enhanced Pilot Spoofing Attack Simulation
%
% This function simulates PSA with enhanced power sensitivity by:
% 1. Removing hard limits on attack strength
% 2. Adding power-dependent attack metrics
% 3. Including SNR difference features
%
% Inputs:
%   h_UE      - Channel matrix for legitimate users, size: [M x K]
%   g_ED      - Channel vector for eavesdropper, size: [M x 1]
%   Phi       - Training sequence matrix, size: [tau x K]
%   P_UE      - Transmit power of user equipment (scalar)
%   P_ED      - Transmit power of eavesdropper (scalar)
%   N         - Noise matrix, size: [M x tau]
%   indAttPres- Indicator of attack presence (0 or 1)
%   indAttUE  - Index of the attacked user
%
% Optional Name-Value Pair Arguments:
%   'NoiseVariance' - Noise variance for SNR calculation (default: calculated from N)
%   'PathLoss_UE'   - Path loss matrix for UE (M x K)
%   'PathLoss_ED'   - Path loss for ED (scalar)
%
% Outputs:
%   Y             - Received signal at the base station, size: [M x tau]
%   attack_metrics - Structure containing attack-related metrics

    % Input parsing
    p = inputParser;
    addRequired(p, 'h_UE', @(x) isnumeric(x) && ismatrix(x));
    addRequired(p, 'g_ED', @(x) isnumeric(x) && iscolumn(x));
    addRequired(p, 'Phi', @(x) isnumeric(x) && ismatrix(x));
    addRequired(p, 'P_UE', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'P_ED', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addRequired(p, 'N', @(x) isnumeric(x) && ismatrix(x));
    addRequired(p, 'indAttPres', @(x) isnumeric(x) && isscalar(x) && (x == 0 || x == 1));
    addRequired(p, 'indAttUE', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'NoiseVariance', [], @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'PathLoss_UE', [], @(x) isnumeric(x) && ismatrix(x));
    addParameter(p, 'PathLoss_ED', [], @(x) isnumeric(x) && isscalar(x) && x > 0);
    parse(p, h_UE, g_ED, Phi, P_UE, P_ED, N, indAttPres, indAttUE, varargin{:});

    % Input validation
    [M, K] = size(h_UE);
    validateattributes(g_ED, {'numeric'}, {'column', 'numel', M});
    validateattributes(Phi, {'numeric'}, {'size', [size(Phi, 1), K]});
    validateattributes(N, {'numeric'}, {'size', [M, size(Phi, 1)]});
    validateattributes(indAttUE, {'numeric'}, {'integer', 'positive', '<=', K, 'scalar'});

    % Calculate noise variance if not provided
    if isempty(p.Results.NoiseVariance)
        sigma_n_2 = mean(var(N, 0, 2)); % Average variance across antennas
    else
        sigma_n_2 = p.Results.NoiseVariance;
    end

    % Generate received signal without attack
    Y = sqrt(P_UE) * h_UE * Phi.' + N;

    % Initialize attack metrics
    attack_metrics = struct();
    attack_metrics.attack_present = logical(indAttPres);
    attack_metrics.attacked_user = indAttUE;
    attack_metrics.eavesdropper_power = P_ED;
    attack_metrics.legitimate_power = P_UE;
    attack_metrics.power_ratio = P_ED / P_UE;

    if indAttPres
        % Calculate enhanced attack strength without hard limits
        if ~isempty(p.Results.PathLoss_UE) && ~isempty(p.Results.PathLoss_ED)
            % Calculate SNR-based metrics
            SNR_UE = P_UE * p.Results.PathLoss_UE(:, indAttUE) / sigma_n_2;
            SNR_ED = P_ED * p.Results.PathLoss_ED / sigma_n_2;

            % Enhanced attack strength calculation
            attack_metrics.SNR_UE = SNR_UE;
            attack_metrics.SNR_ED = SNR_ED;
            attack_metrics.SNR_ratio = SNR_ED / mean(SNR_UE);

            % Power-based attack strength (no hard limit)
            attack_metrics.attack_strength_power = P_ED / P_UE;

            % SNR-based attack strength (no hard limit)
            attack_metrics.attack_strength_SNR = SNR_ED / mean(SNR_UE);

            % Channel correlation-based attack strength
            h_attacked = h_UE(:, indAttUE);
            channel_correlation = abs(g_ED' * h_attacked) / (norm(g_ED) * norm(h_attacked));
            attack_metrics.channel_correlation = channel_correlation;

            % Combined attack strength
            attack_metrics.combined_attack_strength = attack_metrics.attack_strength_SNR * channel_correlation;

        else
            % Fallback to basic attack strength
            attack_metrics.attack_strength_power = P_ED / P_UE;
            attack_metrics.attack_strength_SNR = P_ED / P_UE; % Simplified
            attack_metrics.channel_correlation = 1; % Default
            attack_metrics.combined_attack_strength = P_ED / P_UE;
        end

        % Add attack signal with enhanced strength
        attack_signal = sqrt(P_ED) * g_ED * Phi(:, indAttUE).';

        % Scale attack signal by combined attack strength for better power sensitivity
        if isfield(attack_metrics, 'combined_attack_strength')
            attack_signal = attack_metrics.combined_attack_strength * attack_signal;
        end

        Y = Y + attack_signal;

        % Calculate post-attack metrics
        attack_metrics.received_power_ratio = (norm(Y)^2 - norm(sqrt(P_UE) * h_UE * Phi.')^2) / norm(sqrt(P_UE) * h_UE * Phi.')^2;
        attack_metrics.attack_contribution = norm(attack_signal)^2 / norm(Y)^2;
    else
        % No attack case
        attack_metrics.SNR_UE = P_UE / sigma_n_2;
        attack_metrics.SNR_ED = P_ED / sigma_n_2;
        attack_metrics.SNR_ratio = 0;
        attack_metrics.attack_strength_power = 0;
        attack_metrics.attack_strength_SNR = 0;
        attack_metrics.channel_correlation = 0;
        attack_metrics.combined_attack_strength = 0;
        attack_metrics.received_power_ratio = 0;
        attack_metrics.attack_contribution = 0;
    end
end
