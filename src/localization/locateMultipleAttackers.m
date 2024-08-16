function attackerTargets = locateMultipleAttackers(X_feature_PPR, n_attackers, K, P_ED, nbLoc, nbChanReal)
% LOCATEMULTIPLEATTACKERS Locate multiple attackers based on PPR features
%
% This function attempts to locate multiple attackers among K users
% based on the Pilot Pollution Ratio (PPR) features.
%
% Inputs:
% X_feature_PPR - PPR features, size: [numSamples x K x numPED]
% n_attackers - Number of attackers to locate
% K - Number of users
% P_ED - Eavesdropper power levels
% nbLoc - Number of location realizations
% nbChanReal - Number of channel realizations per location
%
% Output:
% attackerTargets - Estimated attacker indices for each P_ED level

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

    attackerTargets = zeros(numPED, n_attackers);

    for i = 1:numPED
        % Extract PPR features for current P_ED level
        PPR_features = X_feature_PPR(:, :, i);

        % Simple localization: choose the n_attackers users with the highest average PPR
        [~, sortedIndices] = sort(mean(PPR_features), 'descend');
        attackerTargets(i, :) = sortedIndices(1:n_attackers);
    end

    % Display some debug information
    disp(['Number of samples: ', num2str(numSamples)]);
    disp(['Number of users: ', num2str(numUsers)]);
    disp(['Number of P_ED levels: ', num2str(numPED)]);
    disp(['Number of attackers: ', num2str(n_attackers)]);
    disp('Attacker targets:');
    disp(attackerTargets);
end