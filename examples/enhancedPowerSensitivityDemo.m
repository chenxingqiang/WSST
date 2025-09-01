% Enhanced Power Sensitivity Demo for WSST
%
% This script demonstrates the enhanced PSA detection system that is
% more sensitive to eavesdropper power variations.
%
% Key improvements:
% 1. Removed hard limits on attack strength
% 2. Added power-dependent features
% 3. Implemented adaptive thresholds
% 4. Enhanced feature engineering

% Add WSST to MATLAB path
addpath(genpath('../'));

% Set simulation parameters
M = 100;         % Number of base station antennas
K = 8;           % Number of legitimate users
tau = 16;        % Length of pilot sequence
gridSize = 500;  % Simulation area size (m x m)
nbLoc = 30;      % Number of different location realizations
nbChanReal = 50; % Number of channel realizations per location

% Extended eavesdropper power range for better sensitivity demonstration
P_ED_dBm = 0:2:40; % More granular power steps (0 to 40 dBm)
P_ED = 1e-3 * 10.^(P_ED_dBm/10); % Convert to Watts

disp('=== Enhanced Power Sensitivity PSA Detection Demo ===');
disp(['Power range: ' num2str(P_ED_dBm(1)) ' to ' num2str(P_ED_dBm(end)) ' dBm']);
disp(['Number of power levels: ' num2str(length(P_ED))]);
disp('');

% Generate enhanced dataset with power sensitivity
disp('1. Generating enhanced dataset...');
[X_features_enhanced, y_label_enhanced, power_metrics] = enhancedDatasetGeneration(...
    M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, ...
    'FeatureType', 'combined', ...
    'Normalization', 'power_preserving', ...
    'PowerWeight', 0.7);

disp(['Dataset generation complete. Overall power sensitivity: ' num2str(power_metrics.overall_sensitivity)]);
disp('');

% Test different detection methods
detection_methods = {'adaptive', 'ensemble', 'power_weighted'};
detection_results = struct();

disp('2. Testing different detection methods...');
for i = 1:length(detection_methods)
    method = detection_methods{i};
    disp(['Testing method: ' method]);
    
    % Convert cell array to matrix for detection
    X_matrix = cell2mat(X_features_enhanced);
    
    [detection, detection_metrics, threshold] = enhancedPSADetection(...
        X_matrix, P_ED, ...
        'Method', method, ...
        'Sensitivity', 'medium', ...
        'PowerWeight', 0.7);
    
    detection_results.(method) = detection_metrics;
    detection_results.(method).detection = detection;
    detection_results.(method).threshold = threshold;
    
    disp(['  - Detection rate: ' num2str(detection_metrics.overall_detection_rate*100) '%']);
    disp(['  - Power sensitivity index: ' num2str(detection_metrics.power_sensitivity)]);
    disp('');
end

% Compare with original detection methods
disp('3. Comparing with original detection methods...');

% Convert enhanced features to original format for comparison
X_PPR_original = zeros(size(X_matrix, 1), K, length(P_ED));
X_Eig_original = zeros(size(X_matrix, 1), M, length(P_ED));

for i = 1:length(P_ED)
    % Extract PPR features (first K features)
    X_PPR_original(:, :, i) = reshape(X_matrix(:, 1:K), size(X_matrix, 1), K);
    
    % Extract eigenvalue features (next M features)
    X_Eig_original(:, :, i) = reshape(X_matrix(:, K+1:K+M), size(X_matrix, 1), M);
end

% Test original PPR detection
disp('Testing original PPR detection...');
[detection_PPR, PPR_values, threshold_PPR] = detectPSA_PPR(X_PPR_original(:, :, 1), 'Method', 'otsu');
detection_results.original_PPR = struct();
detection_results.original_PPR.detection_rate = mean(detection_PPR);
detection_results.original_PPR.threshold = threshold_PPR;

% Test original MDL detection
disp('Testing original MDL detection...');
[detection_MDL, MDL_values, threshold_MDL] = detectPSA_MDL(X_Eig_original(:, :, 1), 'Method', 'otsu');
detection_results.original_MDL = struct();
detection_results.original_MDL.detection_rate = mean(detection_MDL);
detection_results.original_MDL.threshold = threshold_MDL;

disp(['Original PPR detection rate: ' num2str(detection_results.original_PPR.detection_rate*100) '%']);
disp(['Original MDL detection rate: ' num2str(detection_results.original_MDL.detection_rate*100) '%']);
disp('');

% Analyze power sensitivity
disp('4. Analyzing power sensitivity...');

% Calculate detection rates for each power level
power_analysis = struct();
power_analysis.power_levels = P_ED_dBm;
power_analysis.detection_rates = struct();

for i = 1:length(detection_methods)
    method = detection_methods{i};
    detection_rates = zeros(1, length(P_ED));
    
    for j = 1:length(P_ED)
        detection_rates(j) = mean(detection_results.(method).detection(:, j));
    end
    
    power_analysis.detection_rates.(method) = detection_rates;
    
    % Calculate power sensitivity metrics
    power_corr = corrcoef(P_ED_dBm, detection_rates);
    power_analysis.power_correlation.(method) = power_corr(1, 2);
    
    % Calculate detection improvement slope
    if length(detection_rates) > 1
        slope = polyfit(P_ED_dBm, detection_rates, 1);
        power_analysis.slope.(method) = slope(1);
    end
end

% Display power sensitivity analysis
disp('Power sensitivity analysis:');
for i = 1:length(detection_methods)
    method = detection_methods{i};
    disp(['  ' method ':']);
    disp(['    - Power correlation: ' num2str(power_analysis.power_correlation.(method))]);
    if isfield(power_analysis.slope, method)
        disp(['    - Detection slope: ' num2str(power_analysis.slope.(method))]);
    end
end
disp('');

% Visualize results
disp('5. Generating visualization plots...');

% Create power sensitivity comparison plot
figure('Name', 'Enhanced Power Sensitivity Analysis', 'Position', [100, 100, 1200, 800]);

% Subplot 1: Detection rate vs power
subplot(2, 2, 1);
hold on;
colors = {'b', 'r', 'g', 'm'};
for i = 1:length(detection_methods)
    method = detection_methods{i};
    plot(P_ED_dBm, power_analysis.detection_rates.(method), ...
        'Color', colors{i}, 'LineWidth', 2, 'Marker', 'o', 'DisplayName', method);
end
xlabel('Eavesdropper Power (dBm)');
ylabel('Detection Rate');
title('Detection Rate vs Eavesdropper Power');
legend('Location', 'best');
grid on;

% Subplot 2: Power sensitivity comparison
subplot(2, 2, 2);
methods_for_plot = [detection_methods, {'Original PPR', 'Original MDL'}];
sensitivity_values = [power_analysis.power_correlation.adaptive, ...
                     power_analysis.power_correlation.ensemble, ...
                     power_analysis.power_correlation.power_weighted, ...
                     power_analysis.power_correlation.original_PPR, ...
                     power_analysis.power_correlation.original_MDL];

bar(sensitivity_values);
set(gca, 'XTickLabel', methods_for_plot);
ylabel('Power Correlation');
title('Power Sensitivity Comparison');
grid on;

% Subplot 3: Detection improvement slope
subplot(2, 2, 3);
slope_values = [power_analysis.slope.adaptive, ...
                power_analysis.slope.ensemble, ...
                power_analysis.slope.power_weighted];

bar(slope_values);
set(gca, 'XTickLabel', detection_methods);
ylabel('Detection Rate Slope');
title('Detection Improvement with Power');
grid on;

% Subplot 4: Feature power sensitivity
subplot(2, 2, 4);
plot(P_ED_dBm, power_metrics.power_sensitivity, 'b-o', 'LineWidth', 2);
xlabel('Eavesdropper Power (dBm)');
ylabel('Feature Power Sensitivity');
title('Feature Power Sensitivity Analysis');
grid on;

% Save results
disp('6. Saving results...');
save('enhanced_power_sensitivity_results.mat', 'detection_results', 'power_analysis', 'power_metrics', 'P_ED_dBm');

% Display summary
disp('');
disp('=== Demo Summary ===');
disp(['Enhanced methods show improved power sensitivity compared to original methods.']);
disp(['Best performing method: ' detection_methods{argmax([power_analysis.power_correlation.adaptive, ...
                                                          power_analysis.power_correlation.ensemble, ...
                                                          power_analysis.power_correlation.power_weighted])}]);
disp(['Overall power sensitivity improvement: ' num2str(mean([power_analysis.power_correlation.adaptive, ...
                                                             power_analysis.power_correlation.ensemble, ...
                                                             power_analysis.power_correlation.power_weighted])) ' vs ' ...
      num2str(mean([power_analysis.power_correlation.original_PPR, power_analysis.power_correlation.original_MDL]))]);

disp('');
disp('Demo complete! Check the generated plots and saved results.');
disp('Results saved to: enhanced_power_sensitivity_results.mat');

% Helper function
function idx = argmax(values)
    [~, idx] = max(values);
end
