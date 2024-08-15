function Phi = generateTrainingSequence(tau, K)
% GENERATETRAININGSEQUENCE Generate orthogonal training sequences
%
% This function generates orthogonal training sequences for user equipment
% in a massive MIMO system using Hadamard matrices.
%
% Inputs:
%   tau - Length of the training sequence (must be a power of 2)
%   K   - Number of user equipment (must be less than or equal to tau)
%
% Output:
%   Phi - Matrix of training sequences, size: [tau x K]
%
% Note: This function uses Hadamard matrices to generate orthogonal sequences.
% If tau is not a power of 2, it will be rounded up to the nearest power of 2.

    % Input validation
    validateattributes(tau, {'numeric'}, {'positive', 'integer', 'scalar'});
    validateattributes(K, {'numeric'}, {'positive', 'integer', 'scalar', '<=', tau});

    % Ensure tau is a power of 2
    tau_adjusted = 2^ceil(log2(tau));
    if tau_adjusted ~= tau
        warning('tau adjusted to %d to ensure it is a power of 2', tau_adjusted);
        tau = tau_adjusted;
    end

    % Generate Hadamard matrix
    H = hadamard(tau);

    % Randomly select K columns
    selected_columns = randperm(tau, K);
    Phi = H(:, selected_columns);

    % Normalize columns
    Phi = Phi ./ sqrt(tau);

    % Verify orthogonality
    orthogonality_check = Phi' * Phi;
    if any(abs(orthogonality_check - eye(K)) > 1e-10, 'all')
        warning('Generated sequences are not perfectly orthogonal');
    end

    % Visualize training sequences
    figure;
    imagesc(real(Phi));
    colorbar;
    title('Training Sequences (Real Part)');
    xlabel('User Index');
    ylabel('Time Index');
end