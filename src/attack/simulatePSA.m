function Y = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED, N, indAttPres, indAttUE)
% SIMULATEPSA Simulate Pilot Spoofing Attack in massive MIMO
%
% This function simulates the received signal at the base station
% under a potential Pilot Spoofing Attack scenario.
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
% Output:
%   Y         - Received signal at the base station, size: [M x tau]
%
% Note: This function assumes that the eavesdropper, if present,
% attacks only one legitimate user's pilot sequence.

    % Input validation
    [M, K] = size(h_UE);
    validateattributes(g_ED, {'numeric'}, {'column', 'numel', M});
    validateattributes(Phi, {'numeric'}, {'size', [size(Phi, 1), K]});
    validateattributes(P_UE, {'numeric'}, {'positive', 'scalar'});
    validateattributes(P_ED, {'numeric'}, {'positive', 'scalar'});
    validateattributes(N, {'numeric'}, {'size', [M, size(Phi, 1)]});
    validateattributes(indAttPres, {'numeric'}, {'binary', 'scalar'});
    validateattributes(indAttUE, {'numeric'}, {'integer', 'positive', '<=', K, 'scalar'});

    % Generate received signal without attack
    Y = sqrt(P_UE) * h_UE * Phi.' + N;

    % Add attack signal if present
    if indAttPres
        Y = Y + sqrt(P_ED) * g_ED * Phi(:, indAttUE).';
    end

    % Visualize received signal
    figure;
    subplot(2,1,1);
    imagesc(abs(Y));
    colorbar;
    title('Magnitude of Received Signal');
    xlabel('Time Index');
    ylabel('Antenna Index');

    subplot(2,1,2);
    plot(sum(abs(Y).^2, 1));
    title('Total Received Power Over Time');
    xlabel('Time Index');
    ylabel('Power');

    % Calculate and display signal-to-noise ratio (SNR)
    signal_power = mean(abs(Y(:) - N(:)).^2);
    noise_power = mean(abs(N(:)).^2);
    SNR_dB = 10 * log10(signal_power / noise_power);
    disp(['Estimated SNR: ', num2str(SNR_dB), ' dB']);
end