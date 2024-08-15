function [Beta_UE, Beta_ED] = calculatePathLoss(M, K, x_BS, y_BS, x_UE, y_UE, x_ED, y_ED)
% CALCULATEPATHLOSS Calculate path loss for UEs and eavesdropper
%
% This function calculates the path loss for user equipment (UE) and
% eavesdropper (ED) based on their positions relative to the base station (BS).
%
% Inputs:
%   M     - Number of base station antennas
%   K     - Number of user equipment
%   x_BS, y_BS - Coordinates of the base station
%   x_UE, y_UE - Coordinates of user equipment, size: [K x 1] each
%   x_ED, y_ED - Coordinates of the eavesdropper
%
% Outputs:
%   Beta_UE - Path loss matrix for UEs, size: [M x K]
%   Beta_ED - Path loss scalar for eavesdropper
%
% Note: This function uses a simple distance-based path loss model.
% More sophisticated models can be implemented as needed.

    % Input validation
    validateattributes(M, {'numeric'}, {'positive', 'integer', 'scalar'});
    validateattributes(K, {'numeric'}, {'positive', 'integer', 'scalar'});
    validateattributes(x_UE, {'numeric'}, {'vector', 'numel', K});
    validateattributes(y_UE, {'numeric'}, {'vector', 'numel', K});

    % Path loss exponent (adjust as needed)
    alpha = 3.8;

    % Calculate distances
    d_UE = sqrt((x_UE - x_BS).^2 + (y_UE - y_BS).^2);
    d_ED = sqrt((x_ED - x_BS)^2 + (y_ED - y_BS)^2);

    % Calculate path loss
    Beta_UE_temp = 1 ./ (1 + d_UE.^alpha);
    Beta_ED = 1 / (1 + d_ED^alpha);

    % Replicate Beta_UE for all antennas (assuming uniform linear array)
    Beta_UE = repmat(Beta_UE_temp, M, 1);

    % Optionally, add shadow fading
    % shadow_fading_dB = 8; % Shadow fading standard deviation in dB
    % Beta_UE = Beta_UE .* 10.^(shadow_fading_dB * randn(M, K) / 10);
    % Beta_ED = Beta_ED * 10^(shadow_fading_dB * randn / 10);

    % Visualize path loss
    figure;
    subplot(2,1,1);
    imagesc(Beta_UE);
    colorbar;
    title('Path Loss for UEs');
    xlabel('User Index');
    ylabel('Antenna Index');

    subplot(2,1,2);
    bar(1:K, mean(Beta_UE));
    title('Average Path Loss per UE');
    xlabel('User Index');
    ylabel('Average Path Loss');
end