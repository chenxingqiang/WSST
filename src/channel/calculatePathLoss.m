function [Beta_UE, Beta_ED] = calculatePathLoss(M, K, x_BS, y_BS, x_UE, y_UE, x_ED, y_ED)
% CALCULATEPATHLOSS Calculate path loss for UEs and ED
%
% This function calculates the path loss for user equipment (UE) and
% eavesdropper device (ED) based on their positions relative to the base station (BS).
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

    % Calculate path loss for UEs
    Beta_UE_temp = 1 ./ (1 + d_UE.^alpha);
    
    % Replicate Beta_UE for all antennas
    Beta_UE = repmat(Beta_UE_temp(:)', M, 1);

    % Calculate path loss for ED
    Beta_ED = 1 / (1 + d_ED^alpha);

    % Debug information
    disp(['Beta_UE size: ', num2str(size(Beta_UE))]);
    disp(['Beta_ED size: ', num2str(size(Beta_ED))]);
    disp(['M: ', num2str(M), ', K: ', num2str(K)]);

    % Verification
    assert(isequal(size(Beta_UE), [M, K]), 'Beta_UE must be of size M x K');
    assert(isscalar(Beta_ED), 'Beta_ED must be a scalar');
end