function h_UE = generateUEChannels(M, K, Beta_UE)
% GENERATEUECHANNELS Generate channels for user equipment
% h_UE = GENERATEUECHANNELS(M, K, Beta_UE) returns the channel matrix for user equipment
%
% Inputs:
% M - Number of base station antennas
% K - Number of user devices
% Beta_UE - Path loss matrix (M x K), vector (1 x K or K x 1), or scalar
%
% Output:
% h_UE - User equipment channel matrix (M x K)

    % Input validation
    validateattributes(M, {'numeric'}, {'positive', 'integer', 'scalar'});
    validateattributes(K, {'numeric'}, {'positive', 'integer', 'scalar'});
    validateattributes(Beta_UE, {'numeric'}, {'nonnegative'});

    % Handle different input sizes for Beta_UE
    if isscalar(Beta_UE)
        Beta_UE = Beta_UE * ones(M, K);
    elseif isvector(Beta_UE)
        if length(Beta_UE) ~= K
            error('Length of Beta_UE vector must be equal to K');
        end
        Beta_UE = repmat(Beta_UE(:)', M, 1);
    elseif ~isequal(size(Beta_UE), [M, K])
        error('Beta_UE must be a scalar, a vector of length K, or a matrix of size M x K');
    end

    % Generate channel matrix
    h_UE = sqrt(Beta_UE/2) .* (randn(M, K) + 1i * randn(M, K));

    % Verification (optional, can be commented out for performance)
    assert(all(size(h_UE) == [M, K]), 'Output size mismatch');
    assert(~any(isnan(h_UE(:))), 'NaN values in output');
    assert(~any(isinf(h_UE(:))), 'Inf values in output');
end