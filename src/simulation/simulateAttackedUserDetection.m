function [detectionResults, userAccuracy] = simulateAttackedUserDetection(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, attackScenarios)
% SIMULATEATTACKEDUSERDETECTION Simulate detection of users under pilot spoofing attack
%
% This function runs a comprehensive simulation to evaluate the performance of
% the attacked user detection algorithm under various attack scenarios and power levels.
% It provides detailed analysis of detection performance including precision, recall,
% F1 score, and per-user detection accuracy across different attack scenarios and
% attacker power levels.
%
% Inputs:
%   M - Number of base station antennas
%   K - Number of legitimate users
%   tau - Length of pilot sequence
%   gridSize - Size of the simulation area (m x m)
%   nbLoc - Number of location realizations
%   nbChanReal - Number of channel realizations per location
%   P_ED - Vector of eavesdropper power levels (W)
%   attackScenarios - Structure array containing attack scenarios (optional)
%                     Each scenario has fields:
%                     - name: String description
%                     - numAttacked: Number of users attacked
%                     - fixedUsers: (Optional) Fixed indices of attacked users
%
% Outputs:
%   detectionResults - Structure with detection performance metrics including:
%                     - precision: Detection precision for each scenario and power level
%                     - recall: Detection recall for each scenario and power level
%                     - f1Score: F1 score for each scenario and power level
%                     - scenarios: Copy of input attack scenarios
%                     - P_ED: Attacker power levels in Watts
%                     - P_ED_dBm: Attacker power levels in dBm
%                     - confusionMatrix: Confusion matrices for each scenario and power level
%   userAccuracy - Per-user detection accuracy (dimensions: scenarios × power levels × users)

    % Set default attack scenarios if not provided
    if nargin < 8
        attackScenarios = struct();
        attackScenarios(1).name = 'Single User Attack';
        attackScenarios(1).numAttacked = 1;
        attackScenarios(1).fixedUsers = randi(K); % Random user if not specified
        
        attackScenarios(2).name = 'Two User Attack';
        attackScenarios(2).numAttacked = 2;
        attackScenarios(2).fixedUsers = randperm(K, min(K, 2)); % Random 2 users if not specified
        
        attackScenarios(3).name = 'Multiple User Attack';
        attackScenarios(3).numAttacked = min(K, 3);
        attackScenarios(3).fixedUsers = randperm(K, min(K, 3)); % Random 3 users if not specified
    end
    
    % System parameters
    P_UE = 1;              % User equipment transmit power (W)
    sigma_n_2 = 0.1;       % Noise variance
    numScenarios = length(attackScenarios);
    numPED = length(P_ED);
    
    % Initialize result structures with more detailed metrics
    detectionResults = struct();
    detectionResults.scenarios = attackScenarios;
    detectionResults.P_ED = P_ED;
    detectionResults.P_ED_dBm = 10*log10(P_ED*1000); % Convert to dBm
    detectionResults.simulationParameters = struct(...
        'M', M, ...                  % Number of base station antennas
        'K', K, ...                  % Number of legitimate users
        'tau', tau, ...              % Length of pilot sequence
        'gridSize', gridSize, ...    % Simulation area size
        'nbLoc', nbLoc, ...          % Number of location realizations
        'nbChanReal', nbChanReal, ... % Number of channel realizations per location
        'P_UE', P_UE, ...            % User equipment transmit power
        'sigma_n_2', sigma_n_2 ...   % Noise variance
    );
    
    % Initialize performance metrics
    precision = zeros(numScenarios, numPED);
    recall = zeros(numScenarios, numPED);
    f1Score = zeros(numScenarios, numPED);
    accuracy = zeros(numScenarios, numPED);
    specificity = zeros(numScenarios, numPED);
    userAccuracy = zeros(numScenarios, numPED, K);
    confusionMatrix = cell(numScenarios, numPED); % Store confusion matrices
    
    % Run simulation for each scenario and power level
    for scenIdx = 1:numScenarios
        disp(['Simulating scenario: ', attackScenarios(scenIdx).name]);
        numAttacked = attackScenarios(scenIdx).numAttacked;
        
        % Display which users are being attacked in this scenario
        if isfield(attackScenarios(scenIdx), 'fixedUsers') && ~isempty(attackScenarios(scenIdx).fixedUsers)
            disp(['  Attacked users: ', num2str(attackScenarios(scenIdx).fixedUsers)]);
        else
            disp('  Random users will be attacked in each realization');
        end
        
        for powIdx = 1:numPED
            disp(['  Power level: ', num2str(detectionResults.P_ED_dBm(powIdx)), ' dBm']);
            
            % Initialize counters for this scenario and power
            scenarioPrecision = 0;
            scenarioRecall = 0;
            scenarioF1 = 0;
            scenarioAccuracy = 0;
            scenarioSpecificity = 0;
            correctDetections = zeros(1, K);
            totalAttacks = zeros(1, K);
            
            % Initialize confusion matrix counters
            totalTP = 0; % True Positives
            totalFP = 0; % False Positives
            totalTN = 0; % True Negatives
            totalFN = 0; % False Negatives
            
            % Run multiple location and channel realizations
            for locIdx = 1:nbLoc
                for chanIdx = 1:nbChanReal
                    % Generate random channel matrices for this realization
                    h_UE = sqrt(0.5) * (randn(M, K) + 1j * randn(M, K));
                    g_ED = sqrt(0.5) * (randn(M, 1) + 1j * randn(M, 1));
                    
                    % Generate random pilot sequences (orthogonal)
                    Phi = sqrt(0.5) * (randn(tau, K) + 1j * randn(tau, K));
                    for k = 1:K
                        Phi(:, k) = Phi(:, k) / norm(Phi(:, k));
                    end
                    
                    % Generate noise
                    N = sqrt(sigma_n_2/2) * (randn(M, tau) + 1j * randn(M, tau));
                    
                    % Determine which users to attack for this realization
                    if isfield(attackScenarios(scenIdx), 'fixedUsers') && ~isempty(attackScenarios(scenIdx).fixedUsers)
                        attackedUserIndices = attackScenarios(scenIdx).fixedUsers;
                    else
                        % Randomly select users to attack
                        attackedUserIndices = randperm(K, min(K, numAttacked));
                    end
                    
                    % Create indicator vector of attacked users
                    trueAttackedUsers = false(1, K);
                    trueAttackedUsers(attackedUserIndices) = true;
                    
                    % Update total attacks counter
                    totalAttacks = totalAttacks + trueAttackedUsers;
                    
                    % Create received signal (legitimate users + noise)
                    Y = zeros(M, tau);
                    for k = 1:K
                        Y = Y + sqrt(P_UE) * h_UE(:, k) * Phi(:, k)';
                    end
                    
                    % Add attack signal for specified users
                    for j = 1:length(attackedUserIndices)
                        attackedIdx = attackedUserIndices(j);
                        Y = Y + sqrt(P_ED(powIdx)) * g_ED * Phi(:, attackedIdx)';
                    end
                    
                    % Add noise
                    Y = Y + N;
                    
                    % Set path loss coefficients (simplified as ones)
                    Beta_UE = ones(M, K);
                    
                    % Detect which users are under attack
                    [detectedIndices, ~] = detectAttackedUsers(Y, Phi, K, M, tau, P_UE, Beta_UE, sigma_n_2);
                    
                    % Create indicator vector of detected attacks
                    detectedAttackedUsers = false(1, K);
                    detectedAttackedUsers(detectedIndices) = true;
                    
                    % Update correct detections counter
                    correctDetections = correctDetections + (detectedAttackedUsers == trueAttackedUsers);
                    
                    % Calculate detection performance with more detailed metrics
                    truePositives = length(intersect(detectedIndices, attackedUserIndices));
                    falsePositives = length(setdiff(detectedIndices, attackedUserIndices));
                    falseNegatives = length(setdiff(attackedUserIndices, detectedIndices));
                    trueNegatives = K - (truePositives + falsePositives + falseNegatives);
                    
                    % Update confusion matrix counters
                    totalTP = totalTP + truePositives;
                    totalFP = totalFP + falsePositives;
                    totalTN = totalTN + trueNegatives;
                    totalFN = totalFN + falseNegatives;
                    
                    % Calculate performance metrics
                    realPrecision = truePositives / max(1, truePositives + falsePositives);
                    realRecall = truePositives / max(1, truePositives + falseNegatives);
                    realF1 = 2 * realPrecision * realRecall / max(1e-10, realPrecision + realRecall);
                    realAccuracy = (truePositives + trueNegatives) / K;
                    realSpecificity = trueNegatives / max(1, trueNegatives + falsePositives);
                    
                    % Update scenario metrics
                    scenarioPrecision = scenarioPrecision + realPrecision;
                    scenarioRecall = scenarioRecall + realRecall;
                    scenarioF1 = scenarioF1 + realF1;
                    scenarioAccuracy = scenarioAccuracy + realAccuracy;
                    scenarioSpecificity = scenarioSpecificity + realSpecificity;
                end
            end
            
            % Calculate average metrics for this scenario and power
            totalRealizations = nbLoc * nbChanReal;
            precision(scenIdx, powIdx) = scenarioPrecision / totalRealizations;
            recall(scenIdx, powIdx) = scenarioRecall / totalRealizations;
            f1Score(scenIdx, powIdx) = scenarioF1 / totalRealizations;
            accuracy(scenIdx, powIdx) = scenarioAccuracy / totalRealizations;
            specificity(scenIdx, powIdx) = scenarioSpecificity / totalRealizations;
            
            % Store confusion matrix for this scenario and power level
            confusionMatrix{scenIdx, powIdx} = [
                totalTP, totalFP;
                totalFN, totalTN
            ];
            
            % Calculate per-user detection accuracy
            for k = 1:K
                if totalAttacks(k) > 0
                    userAccuracy(scenIdx, powIdx, k) = correctDetections(k) / totalRealizations;
                else
                    userAccuracy(scenIdx, powIdx, k) = NaN; % Not applicable if never attacked
                end
            end
            
            % Display comprehensive results for this power level
            disp(['    Precision: ', num2str(precision(scenIdx, powIdx), '%.4f')]);
            disp(['    Recall: ', num2str(recall(scenIdx, powIdx), '%.4f')]);
            disp(['    F1 Score: ', num2str(f1Score(scenIdx, powIdx), '%.4f')]);
            disp(['    Accuracy: ', num2str(accuracy(scenIdx, powIdx), '%.4f')]);
            disp(['    Specificity: ', num2str(specificity(scenIdx, powIdx), '%.4f')]);
            
            % Display confusion matrix summary
            disp('    Confusion Matrix:');
            disp(['      True Positives: ', num2str(totalTP)]);
            disp(['      False Positives: ', num2str(totalFP)]);
            disp(['      False Negatives: ', num2str(totalFN)]);
            disp(['      True Negatives: ', num2str(totalTN)]);
        end
    end
    
    % Store all metrics in results structure
    detectionResults.precision = precision;
    detectionResults.recall = recall;
    detectionResults.f1Score = f1Score;
    detectionResults.accuracy = accuracy;
    detectionResults.specificity = specificity;
    detectionResults.confusionMatrix = confusionMatrix;
    detectionResults.userAccuracy = userAccuracy;
    
    % Visualize results
    for scenIdx = 1:numScenarios
        % Plot detection performance vs power level
        figure('Name', ['Scenario ', num2str(scenIdx), ': ', attackScenarios(scenIdx).name], 'Position', [100, 100, 800, 600]);
        
        subplot(2, 2, 1);
        plot(detectionResults.P_ED_dBm, precision(scenIdx, :), 'o-', 'LineWidth', 2);
        xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
        ylabel('Precision', 'FontWeight', 'bold');
        title('Detection Precision vs. Attacker Power');
        grid on;
        
        subplot(2, 2, 2);
        plot(detectionResults.P_ED_dBm, recall(scenIdx, :), 'o-', 'LineWidth', 2);
        xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
        ylabel('Recall', 'FontWeight', 'bold');
        title('Detection Recall vs. Attacker Power');
        grid on;
        
        subplot(2, 2, 3);
        plot(detectionResults.P_ED_dBm, f1Score(scenIdx, :), 'o-', 'LineWidth', 2);
        xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
        ylabel('F1 Score', 'FontWeight', 'bold');
        title('Detection F1 Score vs. Attacker Power');
        grid on;
        
        subplot(2, 2, 4);
        % Plot per-user detection accuracy
        userAccScenario = squeeze(userAccuracy(scenIdx, :, :));
        semilogy(detectionResults.P_ED_dBm, userAccScenario);
        xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
        ylabel('Per-User Detection Accuracy', 'FontWeight', 'bold');
        title('Per-User Detection Accuracy');
        grid on;
        legend(arrayfun(@(x) ['User ' num2str(x)], 1:K, 'UniformOutput', false), 'Location', 'SouthEast');
        
        % Save figure
        set(gcf, 'Color', 'w');
        saveas(gcf, ['AttackScenario_', num2str(scenIdx), '.png']);
    end
    
    % Create overall summary figure
    figure('Name', 'Attack Detection Summary', 'Position', [100, 100, 900, 400]);
    
    % Plot F1 score for all scenarios
    subplot(1, 2, 1);
    plot(detectionResults.P_ED_dBm, f1Score', 'LineWidth', 2);
    xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
    ylabel('F1 Score', 'FontWeight', 'bold');
    title('Detection Performance Across Scenarios');
    grid on;
    legend(arrayfun(@(x) x.name, attackScenarios, 'UniformOutput', false), 'Location', 'SouthEast');
    
    % Plot heatmap of per-user detection accuracy (for highest power level)
    subplot(1, 2, 2);
    imagesc(squeeze(userAccuracy(:, end, :)));
    colorbar;
    xlabel('User Index', 'FontWeight', 'bold');
    ylabel('Scenario', 'FontWeight', 'bold');
    title('Per-User Detection Accuracy (Highest Power)');
    set(gca, 'YTick', 1:numScenarios);
    set(gca, 'YTickLabel', arrayfun(@(x) x.name, attackScenarios, 'UniformOutput', false));
    set(gca, 'XTick', 1:K);
    
    % Save summary figure
    set(gcf, 'Color', 'w');
    saveas(gcf, 'AttackDetectionSummary.png');
    
    disp('Simulation complete. Results have been saved.');
end
