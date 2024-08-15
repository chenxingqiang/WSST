function attackerTargets = locateMultipleAttackers(X_feature_PPR, n_attackers, K, P_ED, nbLoc, nbChanReal)
% LOCATEMULTIPLEATTACKERS Locate multiple attackers based on PPR features
%
% This function attempts to locate multiple attackers among K users
% based on the Pilot Pollution Ratio (PPR) features.
%
% Inputs:
%   X_feature_PPR - PPR features, size: [numSamples x K x numPED]
%   n_attackers   - Number of attackers to locate
%   K             - Number of users
%   P_ED          - Eavesdropper power levels
%   nbLoc         - Number of location realizations
%   nbChanReal    - Number of channel realizations per location
%
% Output:
%   attackerTargets - Estimated attacker indices for each P_ED level

    numPED = length(P_ED);
    attackerTargets = zeros(numPED, n_attackers);
    
    for i = 1:numPED
        start_idx = (i-1)*nbLoc*nbChanReal + 1;
        end_idx = i*nbLoc*nbChanReal;
        
        % Extract PPR features for current P_ED level
        PPR_features = X_feature_PPR(start_idx:end_idx, :);
        
        % Simple localization: choose the n_attackers users with the highest average PPR
        [~, sortedIndices] = sort(mean(PPR_features), 'descend');
        attackerTargets(i, :) = sortedIndices(1:n_attackers);
    end
end