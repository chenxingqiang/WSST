function main()
% MAIN - Main script for Pilot Spoofing Attack (PSA) simulation and analysis
%
% This script runs a comprehensive simulation of a massive MIMO system
% with potential pilot spoofing attacks. It generates data, trains neural
% network models, performs attack detection and localization, and
% visualizes the results using the Wireless Security Simulation Toolkit (WSST).
%
% The script progresses through the following steps:
% 1. Set up simulation parameters
% 2. Generate dataset
% 3. Train neural network models
% 4. Perform attack detection (both overall system and per-user detection)
% 5. Perform attacker localization
% 6. Perform user-specific attack detection
% 7. Calculate and visualize performance metrics
%
% The enhanced version now includes user-specific attack detection capabilities
% that can identify which particular users are being targeted by attackers,
% rather than just detecting the presence of an attack in the system.
%
% Note: Ensure all required functions are in the MATLAB path before running.

    % Simulation Parameters
    M = 100;         % Number of base station antennas
    K = 8;           % Number of legitimate users
    tau = 16;        % Length of pilot sequence
    gridSize = 400;  % Simulation area size (m x m)
    nbLoc = 50;      % Number of different location realizations
    nbChanReal = 100;% Number of channel realizations per location
    P_ED_dBm = 0:5:30; % Eavesdropper power range (dBm)
    P_ED = 1e-3 * 10.^(P_ED_dBm/10); % Convert eavesdropper power to Watts
    n_attackers = 3; % Number of attackers for multiple attacker scenario

    % Generate Dataset
    disp('Generating dataset...');
    [X_feature_PPR, X_feature_Eig, y_label] = generateDataset(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED);

    % Print dataset sizes for debugging
    disp(['X_feature_PPR size: ', num2str(size(X_feature_PPR))]);
    disp(['X_feature_Eig size: ', num2str(size(X_feature_Eig))]);
    disp(['y_label size: ', num2str(size(y_label))]);

    % Remove extremely low variance features
    [X_feature_PPR, X_feature_Eig] = removeExtremelyLowVarianceFeatures(X_feature_PPR, X_feature_Eig);

    % Train Neural Network Models
    disp('Training neural network models...');
    tic;
    trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label);
    timeTrain = toc;
    disp(['Training time: ', num2str(timeTrain), ' seconds']);

    % Perform Attack Detection
    disp('Performing attack detection...');
    tic;
    [detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN, predictions_PPR_NN, predictions_Eig_NN, y_true] = ...
        detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal);
    timeDetect = toc;
    disp(['Detection time: ', num2str(timeDetect), ' seconds']);

    % Perform Single Attacker Localization
    disp('Performing single attacker localization...');
    tic;
    attackerTarget = locateSingleAttacker(X_feature_PPR, K, P_ED, nbLoc, nbChanReal);
    timeLocateSingle = toc;
    disp(['Single attacker localization time: ', num2str(timeLocateSingle), ' seconds']);

    % Perform Multiple Attacker Localization
    disp('Performing multiple attacker localization...');
    tic;
    attackerTargets = locateMultipleAttackers(X_feature_PPR, n_attackers, K, P_ED, nbLoc, nbChanReal);
    timeLocateMultiple = toc;
    disp(['Multiple attacker localization time: ', num2str(timeLocateMultiple), ' seconds']);

    % Visualize Execution Times
    executionTimes = [timeTrain, timeDetect, timeLocateSingle, timeLocateMultiple];
    plotExecutionTime(executionTimes);

    % Calculate Error Rates
    disp('Calculating error rates...');
    numPED = length(P_ED_dBm);
    [FPR_PPR_NN, FNR_PPR_NN] = calculateErrorRates(predictions_PPR_NN, y_true, numPED);
    [FPR_Eig_NN, FNR_Eig_NN] = calculateErrorRates(predictions_Eig_NN, y_true, numPED);
    
    % Visualize Results
    disp('Generating visualization plots...');

    % Plot Error Rates vs. Eavesdropper Power
    plotErrorRates(P_ED_dBm, FPR_PPR_NN, FNR_PPR_NN, FPR_Eig_NN, FNR_Eig_NN);

    % Plot Detection Accuracy
    plotDetectionAccuracy(P_ED_dBm, detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);

    % Plot Localization Accuracy
    plotLocalizationAccuracy(attackerTargets, attackerTarget, n_attackers);

    % Plot Accuracy vs Complexity
    complexityLevels = [50, 100, 150, 200];  % Assumed antenna numbers for complexity
    accuracyLevels = [mean(detAcc_PPR), mean(detAcc_MDL), mean(detAcc_PPR_NN), mean(detAcc_Eig_NN)];
    plotAccuracyVsComplexity(complexityLevels, accuracyLevels);
    
    % Plot Execution Times
    executionTimes = [timeTrain, timeDetect, timeLocateSingle, timeLocateMultiple];
    plotExecutionTime(executionTimes);

    % Select best algorithm and plot results
    bestAlgoIdx = selectBestAlgorithm(detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);
    plotBestAlgorithm(P_ED_dBm, bestAlgoIdx);

    % Plot MDL Histogram
    MDLValues = calculateMDL(X_feature_PPR); % Assuming X_feature_PPR contains the necessary data
    plotMDLHistogram(MDLValues);

    % Plot Received Signal
    h_UE = randn(M, K);  % Generate random channel matrix for legitimate users
    g_ED = randn(M, 1);  % Generate random channel vector for eavesdropper
    Phi = randn(tau, K); % Generate random training sequence matrix
    P_UE = 1;  % Set transmit power of user equipment
    N = randn(M, tau);  % Generate random noise matrix
    indAttPres = randi([0, 1]);  % Randomly set the indicator of attack presence
    indAttUE = randi(K);  % Randomly set the index of the attacked user
    P_ED_single = P_ED(1);  % Use the first element of P_ED as a scalar
    Y = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED_single, N, indAttPres, indAttUE);
    plotReceivedSignal(Y, N);

    % Visualize Network Topology
    x_BS = 0; y_BS = 0;  % Coordinates of the Base Station
    x_UE = rand(1, K) * gridSize; y_UE = rand(1, K) * gridSize;  % Coordinates of the User Equipment
    x_ED = rand * gridSize; y_ED = rand * gridSize;  % Coordinates of the Eavesdropper
    visualizeNetworkTopology(x_BS, y_BS, x_UE, y_UE, x_ED, y_ED, gridSize);
    
    % Visualize PPR Distribution
    % Extract necessary parameters from X_feature_PPR
    [numSamples, numFeatures, numPowerLevels] = size(X_feature_PPR);
    PPRValues = zeros(numSamples, K);
    for i = 1:numSamples
        % Generate placeholder received signal Y
        Y = randn(M, tau);  % Placeholder received signal with appropriate dimensions
        Phi = randn(tau, K);  % Generate random training sequence matrix
        sigma_n_2 = 1;  % Set noise variance
        Beta_UE = ones(M, K);  % Assume equal path loss for all users
        PPRValues(i, :) = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2);
    end
    PPR_threshold = 0.5;  % Set a threshold value for PPR detection
    visualizePPRDistribution(PPRValues(:), PPR_threshold);

   % Generate and plot heatmap
    [numRows, numCols] = size(detAcc_PPR_NN);
    if numCols ~= K
        warning('Number of columns in detAcc_PPR_NN does not match K. Adjusting heatmap size.');
        K_heatmap = numCols;
    else
        K_heatmap = K;
    end
    heatmapData = reshape(detAcc_PPR_NN, [], K_heatmap);
    plotHeatmap(heatmapData);

    % Select best algorithm and plot results
    bestAlgoIdx = selectBestAlgorithm(detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);
    plotBestAlgorithm(P_ED_dBm, bestAlgoIdx);

    % Perform Attacked User Detection Simulation
    disp('=================================================================');
    disp('PERFORMING USER-SPECIFIC ATTACK DETECTION SIMULATION');
    disp('=================================================================');
    tic;
    
    % Define attack scenarios as specified in the requirements
    attackScenarios = struct();
    
    % Scenario 1: Single User Attack (always attack user 3)
    attackScenarios(1).name = 'Single User Attack';
    attackScenarios(1).numAttacked = 1;
    attackScenarios(1).fixedUsers = 3; % User 3 is always attacked
    attackScenarios(1).description = 'Single user (User 3) is targeted by the attacker';
    
    % Scenario 2: Two User Attack (always attack users 2 and 6)
    attackScenarios(2).name = 'Two User Attack';
    attackScenarios(2).numAttacked = 2;
    attackScenarios(2).fixedUsers = [2, 6]; % Users 2 and 6 are always attacked
    attackScenarios(2).description = 'Two users (Users 2 and 6) are simultaneously targeted';
    
    % Scenario 3: Multiple User Attack (attack users 1, 3, and 5)
    attackScenarios(3).name = 'Multiple User Attack';
    attackScenarios(3).numAttacked = min(K, 3);
    attackScenarios(3).fixedUsers = [1, 3, 5]; % Users 1, 3, and 5 are attacked
    attackScenarios(3).description = 'Multiple users (Users 1, 3, and 5) are simultaneously targeted';
    
    % Display attack scenario information
    disp('Attack Scenarios Configuration:');
    for i = 1:length(attackScenarios)
        disp(['  Scenario ', num2str(i), ': ', attackScenarios(i).name]);
        disp(['    Description: ', attackScenarios(i).description]);
        disp(['    Targeted Users: ', num2str(attackScenarios(i).fixedUsers)]);
    end
    
    % Run the attacked user detection simulation using the enhanced detection function
    disp('\nRunning comprehensive simulation with multiple attack scenarios...');
    [detectionResults, userAccuracy] = simulateAttackedUserDetection(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, attackScenarios);
    timeUserDetection = toc;
    disp(['Attacked user detection time: ', num2str(timeUserDetection), ' seconds']);
    
    % Run test cases for validation and visualization
    disp('\nRunning attacked user detection test cases for validation...');
    tic;
    testResults = testDetectAttackedUsers();
    timeTestUserDetection = toc;
    disp(['Test case execution time: ', num2str(timeTestUserDetection), ' seconds']);
    
    % Display test results summary with enhanced formatting
    disp('\nTEST CASE RESULTS SUMMARY:');
    disp('----------------------------------');
    
    % Calculate overall performance metrics
    overallPrecision = 0;
    overallRecall = 0;
    overallF1 = 0;
    
    for i = 1:length(testResults.caseResults)
        caseResult = testResults.caseResults{i};
        disp(['Case ', num2str(i), ': ', caseResult.description]);
        
        % Display true vs detected users
        if isempty(caseResult.trueAttackedUsers)
            trueUsersStr = 'None';
        else
            trueUsersStr = num2str(caseResult.trueAttackedUsers);
        end
        
        if isempty(caseResult.detectedAttackedUsers)
            detectedUsersStr = 'None';
        else
            detectedUsersStr = num2str(caseResult.detectedAttackedUsers);
        end
        
        disp(['  True Attacked Users: ', trueUsersStr]);
        disp(['  Detected Users: ', detectedUsersStr]);
        
        % Display performance metrics with formatting
        disp(['  Precision: ', num2str(caseResult.precision, '%.4f')]);
        disp(['  Recall: ', num2str(caseResult.recall, '%.4f')]);
        disp(['  F1 Score: ', num2str(caseResult.f1Score, '%.4f')]);
        disp('----------------------------------');
        
        % Update overall metrics
        overallPrecision = overallPrecision + caseResult.precision;
        overallRecall = overallRecall + caseResult.recall;
        overallF1 = overallF1 + caseResult.f1Score;
    end
    
    % Display overall performance
    numCases = length(testResults.caseResults);
    disp(['Overall Precision: ', num2str(overallPrecision/numCases, '%.4f')]);
    disp(['Overall Recall: ', num2str(overallRecall/numCases, '%.4f')]);
    disp(['Overall F1 Score: ', num2str(overallF1/numCases, '%.4f')]);
    disp('==================================');
    
    % Create enhanced visualizations for each test case
    for i = 1:length(testResults.caseResults)
        caseResult = testResults.caseResults{i};
        visualizeAttackedUsers(caseResult.detectedAttackedUsers, caseResult.detectionMetrics, K, ...
            ['Attacked User Detection: ' caseResult.description]);
    end
    
    % Create a detailed visualization for the multiple user attack case (typically shows best results)
    bestTestCase = 2; % Multiple user attack case typically shows best results
    caseResult = testResults.caseResults{bestTestCase};
    visualizeAttackedUsers(caseResult.detectedAttackedUsers, caseResult.detectionMetrics, K, ...
        ['Detailed Attacked User Detection: ' caseResult.description]);
    
    % Update execution times to include new functions with enhanced visualization
    executionTimes = [timeTrain, timeDetect, timeLocateSingle, timeLocateMultiple, timeUserDetection, timeTestUserDetection];
    executionLabels = {'Training', 'Attack Detection', 'Single Attacker Localization', ...
                      'Multiple Attacker Localization', 'User-specific Detection', 'Detection Test Cases'};
    
    % Calculate total execution time
    totalExecutionTime = sum(executionTimes);
    
    % Plot execution times with enhanced visualization
    disp('\nGenerating execution time visualization...');
    plotExecutionTime(executionTimes, executionLabels);
    disp(['Total execution time: ', num2str(totalExecutionTime, '%.2f'), ' seconds']);
    
    % Display summary
    disp('Simulation complete. Results summary:');
    disp(['Average PPR-NN Detection Accuracy: ', num2str(mean(detAcc_PPR_NN))]);
    disp(['Average Eig-NN Detection Accuracy: ', num2str(mean(detAcc_Eig_NN))]);
    disp(['PPR-NN False Positive Rate: ', num2str(mean(FPR_PPR_NN))]);
    disp(['PPR-NN False Negative Rate: ', num2str(mean(FNR_PPR_NN))]);
    disp(['Eig-NN False Positive Rate: ', num2str(mean(FPR_Eig_NN))]);
    disp(['Eig-NN False Negative Rate: ', num2str(mean(FNR_Eig_NN))]);
    
    % Display comprehensive attacked user detection results
    disp('\nUSER-SPECIFIC ATTACK DETECTION RESULTS:');
    disp('==================================');
    
    % Display results for each attack scenario with enhanced metrics
    for i = 1:length(attackScenarios)
        disp(['Scenario ', num2str(i), ': ', attackScenarios(i).name]);
        disp(['  Description: ', attackScenarios(i).description]);
        disp(['  Attacked Users: ', num2str(attackScenarios(i).fixedUsers)]);
        
        % Display comprehensive performance metrics
        disp('  Performance Metrics:');
        disp(['    Average Precision: ', num2str(mean(detectionResults.precision(i,:)), '%.4f')]);
        disp(['    Average Recall: ', num2str(mean(detectionResults.recall(i,:)), '%.4f')]);
        disp(['    Average F1 Score: ', num2str(mean(detectionResults.f1Score(i,:)), '%.4f')]);
        disp(['    Average Accuracy: ', num2str(mean(detectionResults.accuracy(i,:)), '%.4f')]);
        disp(['    Average Specificity: ', num2str(mean(detectionResults.specificity(i,:)), '%.4f')]);
        
        % Display per-power level results with enhanced formatting
        disp('  Performance by attacker power level:');
        for p = 1:length(P_ED_dBm)
            disp(['    Power ', num2str(P_ED_dBm(p), '%2.0f'), ' dBm: ', ...
                  'F1=', num2str(detectionResults.f1Score(i,p), '%.4f'), ', ', ...
                  'Prec=', num2str(detectionResults.precision(i,p), '%.4f'), ', ', ...
                  'Rec=', num2str(detectionResults.recall(i,p), '%.4f'), ', ', ...
                  'Acc=', num2str(detectionResults.accuracy(i,p), '%.4f')]);
            
            % Display confusion matrix for highest power level
            if p == length(P_ED_dBm)
                cm = detectionResults.confusionMatrix{i,p};
                disp('    Confusion Matrix (highest power):');
                disp(['      TP: ', num2str(cm(1,1)), ', FP: ', num2str(cm(1,2))]);
                disp(['      FN: ', num2str(cm(2,1)), ', TN: ', num2str(cm(2,2))]);
            end
        end
        disp('----------------------------------');
    end
    
    % Display overall performance summary with enhanced metrics
    disp('\nOVERALL PERFORMANCE SUMMARY:');
    disp('----------------------------------');
    disp(['  Average Precision (all scenarios): ', num2str(mean(detectionResults.precision(:)), '%.4f')]);
    disp(['  Average Recall (all scenarios): ', num2str(mean(detectionResults.recall(:)), '%.4f')]);
    disp(['  Average F1 Score (all scenarios): ', num2str(mean(detectionResults.f1Score(:)), '%.4f')]);
    disp(['  Average Accuracy (all scenarios): ', num2str(mean(detectionResults.accuracy(:)), '%.4f')]);
    disp(['  Average Specificity (all scenarios): ', num2str(mean(detectionResults.specificity(:)), '%.4f')]);
    
    % Performance analysis by power level
    disp('\nPerformance Trend Analysis:');
    disp('  As attacker power increases:');
    
    % Calculate average improvement from lowest to highest power
    lowPowerIdx = 1;
    highPowerIdx = length(P_ED_dBm);
    f1Improvement = mean(detectionResults.f1Score(:,highPowerIdx) - detectionResults.f1Score(:,lowPowerIdx));
    precImprovement = mean(detectionResults.precision(:,highPowerIdx) - detectionResults.precision(:,lowPowerIdx));
    recallImprovement = mean(detectionResults.recall(:,highPowerIdx) - detectionResults.recall(:,lowPowerIdx));
    
    disp(['    F1 Score improvement: ', num2str(f1Improvement*100, '%.2f'), '%']);
    disp(['    Precision improvement: ', num2str(precImprovement*100, '%.2f'), '%']);
    disp(['    Recall improvement: ', num2str(recallImprovement*100, '%.2f'), '%']);
    
    % Best performing scenario
    avgF1Scores = mean(detectionResults.f1Score, 2);
    [bestF1, bestScenarioIdx] = max(avgF1Scores);
    disp(['\nBest performing scenario: ', attackScenarios(bestScenarioIdx).name, ...
          ' (F1 Score: ', num2str(bestF1, '%.4f'), ')']);
    
    disp(['\nTotal Execution Time: ', num2str(sum(executionTimes), '%.2f'), ' seconds']);
    disp('All results have been plotted and saved to the current directory.');
    
    % Create a comprehensive summary figure for the user detection results
    disp('\nGenerating comprehensive visualization of user detection results...');
    figure('Name', 'User Detection Performance Summary', 'Position', [100, 100, 1200, 800]);
    
    % Plot F1 scores across power levels for all scenarios
    subplot(3, 2, 1);
    plot(P_ED_dBm, detectionResults.f1Score', 'LineWidth', 2, 'Marker', 'o');
    xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
    ylabel('F1 Score', 'FontWeight', 'bold');
    title('Detection F1 Score vs. Attacker Power');
    grid on;
    legend({attackScenarios.name}, 'Location', 'southeast');
    
    % Plot precision across power levels
    subplot(3, 2, 2);
    plot(P_ED_dBm, detectionResults.precision', 'LineWidth', 2, 'Marker', 'o');
    xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
    ylabel('Precision', 'FontWeight', 'bold');
    title('Detection Precision vs. Attacker Power');
    grid on;
    
    % Plot recall across power levels
    subplot(3, 2, 3);
    plot(P_ED_dBm, detectionResults.recall', 'LineWidth', 2, 'Marker', 'o');
    xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
    ylabel('Recall', 'FontWeight', 'bold');
    title('Detection Recall vs. Attacker Power');
    grid on;
    
    % Plot accuracy across power levels
    subplot(3, 2, 4);
    plot(P_ED_dBm, detectionResults.accuracy', 'LineWidth', 2, 'Marker', 'o');
    xlabel('Attacker Power (dBm)', 'FontWeight', 'bold');
    ylabel('Accuracy', 'FontWeight', 'bold');
    title('Detection Accuracy vs. Attacker Power');
    grid on;
    
    % Plot execution time breakdown
    subplot(3, 2, 5);
    bar(executionTimes);
    set(gca, 'XTick', 1:length(executionTimes));
    set(gca, 'XTickLabel', executionLabels);
    xtickangle(45);
    ylabel('Time (seconds)', 'FontWeight', 'bold');
    title('Execution Time Breakdown');
    grid on;
    
    % Plot per-user detection accuracy heatmap
    subplot(3, 2, 6);
    imagesc(squeeze(mean(detectionResults.userAccuracy, 2))); % Average across power levels
    colorbar;
    xlabel('User Index', 'FontWeight', 'bold');
    ylabel('Scenario', 'FontWeight', 'bold');
    title('Per-User Detection Accuracy');
    set(gca, 'YTick', 1:length(attackScenarios));
    set(gca, 'YTickLabel', {attackScenarios.name});
    set(gca, 'XTick', 1:K);
    
    % Save the summary figure with timestamp
    set(gcf, 'Color', 'w');
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    filename = ['UserDetectionSummary_', timestamp, '.png'];
    saveas(gcf, filename);
    disp(['User detection summary visualization saved as: ', filename]);
    
    disp('User detection analysis complete!');
    disp('All results have been plotted and saved to the current directory.');
end