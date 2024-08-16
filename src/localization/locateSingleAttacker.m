function attackerTarget = locateSingleAttacker(X_feature_PPR, K, P_ED, nbLoc, nbChanReal)
    % LOCATESINGLEATTACKER Locate a single attacker based on PPR features
    %
    % This function attempts to locate a single attacker among K users
    % based on the Pilot Pollution Ratio (PPR) features.
    %
    % Inputs:
    % X_feature_PPR - PPR features, size: [numSamples x K x numPED]
    % K - Number of users
    % P_ED - Eavesdropper power levels
    % nbLoc - Number of location realizations
    % nbChanReal - Number of channel realizations per location
    %
    % Output:
    % attackerTarget - Estimated attacker index for each P_ED level

    % Get the dimensions of the input
    [numSamples, numUsers, numPED] = size(X_feature_PPR);

    % Input validation
    if numUsers ~= K
        error('Number of users in X_feature_PPR does not match K');
    end
    if numPED ~= length(P_ED)
        error('Number of P_ED levels in X_feature_PPR does not match length of P_ED');
    end
    if numSamples ~= nbLoc * nbChanReal
        warning('Number of samples in X_feature_PPR does not match nbLoc * nbChanReal');
    end

    [numSamples, numUsers, numPED] = size(X_feature_PPR);
    attackerTarget = zeros(numPED, 1);

    for i = 1:numPED
        % Extract PPR features for current P_ED level
        PPR_features = X_feature_PPR(:, :, i);

        % Calculate the mean PPR for each user
        mean_PPR = mean(PPR_features);

        % Add some randomness to avoid always selecting the same user
        randomness = 0.1 * randn(size(mean_PPR));
        adjusted_PPR = mean_PPR + randomness;

        % Choose the user with the highest adjusted PPR
        [~, attackerTarget(i)] = max(adjusted_PPR);
    end

    % Display some debug information
    disp(['Number of samples: ', num2str(numSamples)]);
    disp(['Number of users: ', num2str(numUsers)]);
    disp(['Number of P_ED levels: ', num2str(numPED)]);
    disp(['Attacker targets: ', num2str(attackerTarget')]);
end