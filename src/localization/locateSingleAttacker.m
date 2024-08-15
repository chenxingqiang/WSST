function attackerTarget = locateSingleAttacker(X_feature_PPR, K, P_ED, nbLoc, nbChanReal)
% LOCATESINGLEATTACKER Locate a single attacker based on PPR features
%
% This function attempts to locate a single attacker among K users
% based on the Pilot Pollution Ratio (PPR) features.
%
% Inputs:
%   X_feature_PPR - PPR features, size: [numSamples x K x numPED]
%   K             - Number of users
%   P_ED          - Eavesdropper power levels
%   nbLoc         - Number of location realizations
%   nbChanReal    - Number of channel realizations per location
%
% Output:
%   attackerTarget - Estimated attacker index for each P_ED level

    numPED = length(P_ED);
    attackerTarget = zeros(numPED, 1);
    
    for i = 1:numPED
        start_idx = (i-1)*nbLoc*nbChanReal + 1;
        end_idx = i*nbLoc*nbChanReal;
        
        % Extract PPR features for current P_ED level
        PPR_features = X_feature_PPR(start_idx:end_idx, :);
        
        % Simple localization: choose the user with the highest average PPR
        [~, attackerTarget(i)] = max(mean(PPR_features));
    end
end