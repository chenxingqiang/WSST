function bestAlgoIdx = selectBestAlgorithm(detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN)
% SELECTBESTALGORITHM Select the best performing algorithm
%
% Inputs:
% detAcc_PPR - Detection accuracy of the PPR algorithm
% detAcc_MDL - Detection accuracy of the MDL algorithm
% detAcc_PPR_NN - Detection accuracy of the PPR-NN algorithm
% detAcc_Eig_NN - Detection accuracy of the Eig-NN algorithm
%
% Output:
% bestAlgoIdx - Index of the best performing algorithm for each power level

    % Combine the accuracies of all algorithms into a matrix
    allAccuracies = [detAcc_PPR; detAcc_MDL; detAcc_PPR_NN; detAcc_Eig_NN];

    % Find the best performing algorithm for each power level
    [~, bestAlgoIdx] = max(allAccuracies, [], 1);
    
    % Get the number of power levels
    numPowerLevels = length(bestAlgoIdx);
    
    % Define the algorithm names
    algoNames = {'PPR', 'MDL', 'PPR-NN', 'Eig-NN'};
    
    % Display the best algorithm for each power level
    for i = 1:numPowerLevels
        bestAlgo = algoNames{bestAlgoIdx(i)};
        fprintf('Power Level %d: Best Algorithm - %s\n', i, bestAlgo);
    end
end