function plotPowerSensitivity(detection_results, power_levels, varargin)
% PLOTPOWERSENSITIVITY Plot power sensitivity analysis results
%
% This function creates comprehensive plots to visualize the power
% sensitivity of different PSA detection methods.
%
% Inputs:
%   detection_results - Structure containing detection results for different methods
%   power_levels      - Vector of power levels (in dBm or Watts)
%
% Optional Name-Value Pair Arguments:
%   'PowerUnit'    - Unit of power: 'dBm' or 'Watts' (default: 'dBm')
%   'SavePlots'    - Whether to save plots (default: false)
%   'PlotType'     - Type of plot: 'all', 'comparison', 'sensitivity' (default: 'all')
%   'FigureSize'   - Figure size [width, height] (default: [1200, 800])

    % Input parsing
    p = inputParser;
    addRequired(p, 'detection_results', @(x) isstruct(x));
    addRequired(p, 'power_levels', @(x) isnumeric(x) && isvector(x));
    addParameter(p, 'PowerUnit', 'dBm', @(x) ismember(x, {'dBm', 'Watts'}));
    addParameter(p, 'SavePlots', false, @(x) islogical(x));
    addParameter(p, 'PlotType', 'all', @(x) ismember(x, {'all', 'comparison', 'sensitivity'}));
    addParameter(p, 'FigureSize', [1200, 800], @(x) isnumeric(x) && length(x) == 2);
    parse(p, detection_results, power_levels, varargin{:});

    % Get parameters
    power_unit = p.Results.PowerUnit;
    save_plots = p.Results.SavePlots;
    plot_type = p.Results.PlotType;
    figure_size = p.Results.FigureSize;

    % Get method names
    method_names = fieldnames(detection_results);
    
    % Remove non-method fields
    non_method_fields = {'power_levels', 'power_analysis', 'power_metrics'};
    method_names = setdiff(method_names, non_method_fields);

    % Create plots based on type
    switch plot_type
        case 'all'
            createAllPlots(detection_results, power_levels, method_names, power_unit, figure_size, save_plots);
        case 'comparison'
            createComparisonPlot(detection_results, power_levels, method_names, power_unit, figure_size, save_plots);
        case 'sensitivity'
            createSensitivityPlot(detection_results, power_levels, method_names, power_unit, figure_size, save_plots);
        otherwise
            error('Invalid plot type specified');
    end
end

function createAllPlots(detection_results, power_levels, method_names, power_unit, figure_size, save_plots)
    % Create comprehensive power sensitivity plots
    
    % Main figure
    figure('Name', 'Enhanced PSA Detection - Power Sensitivity Analysis', ...
           'Position', [100, 100, figure_size(1), figure_size(2)]);
    
    % Subplot 1: Detection Rate vs Power
    subplot(2, 3, 1);
    plotDetectionRateVsPower(detection_results, power_levels, method_names, power_unit);
    
    % Subplot 2: Power Sensitivity Comparison
    subplot(2, 3, 2);
    plotPowerSensitivityComparison(detection_results, method_names);
    
    % Subplot 3: Detection Improvement Slope
    subplot(2, 3, 3);
    plotDetectionSlope(detection_results, method_names);
    
    % Subplot 4: ROC-like Power Performance
    subplot(2, 3, 4);
    plotPowerPerformanceROC(detection_results, power_levels, method_names, power_unit);
    
    % Subplot 5: Feature Power Sensitivity
    subplot(2, 3, 5);
    plotFeaturePowerSensitivity(detection_results, power_levels, power_unit);
    
    % Subplot 6: Method Performance Summary
    subplot(2, 3, 6);
    plotMethodPerformanceSummary(detection_results, method_names);
    
    % Save plot if requested
    if save_plots
        saveas(gcf, 'enhanced_power_sensitivity_analysis.png');
        saveas(gcf, 'enhanced_power_sensitivity_analysis.fig');
    end
end

function createComparisonPlot(detection_results, power_levels, method_names, power_unit, figure_size, save_plots)
    % Create comparison plot
    
    figure('Name', 'Power Sensitivity Comparison', ...
           'Position', [100, 100, figure_size(1), figure_size(2)]);
    
    % Detection rate comparison
    subplot(1, 2, 1);
    plotDetectionRateVsPower(detection_results, power_levels, method_names, power_unit);
    
    % Power sensitivity comparison
    subplot(1, 2, 2);
    plotPowerSensitivityComparison(detection_results, method_names);
    
    if save_plots
        saveas(gcf, 'power_sensitivity_comparison.png');
    end
end

function createSensitivityPlot(detection_results, power_levels, method_names, power_unit, figure_size, save_plots)
    % Create sensitivity-focused plot
    
    figure('Name', 'Power Sensitivity Analysis', ...
           'Position', [100, 100, figure_size(1), figure_size(2)]);
    
    % Power sensitivity metrics
    subplot(1, 2, 1);
    plotPowerSensitivityComparison(detection_results, method_names);
    
    % Detection slope analysis
    subplot(1, 2, 2);
    plotDetectionSlope(detection_results, method_names);
    
    if save_plots
        saveas(gcf, 'power_sensitivity_analysis.png');
    end
end

function plotDetectionRateVsPower(detection_results, power_levels, method_names, power_unit)
    % Plot detection rate vs power level
    
    hold on;
    colors = {'b', 'r', 'g', 'm', 'c', 'y', 'k'};
    markers = {'o', 's', '^', 'd', 'v', '>', '<'};
    
    for i = 1:length(method_names)
        method = method_names{i};
        if isfield(detection_results.(method), 'detection_rate_per_power')
            detection_rates = detection_results.(method).detection_rate_per_power;
        else
            % Calculate from detection matrix if available
            if isfield(detection_results.(method), 'detection')
                detection_rates = mean(detection_results.(method).detection, 1);
            else
                continue;
            end
        end
        
        color_idx = mod(i-1, length(colors)) + 1;
        marker_idx = mod(i-1, length(markers)) + 1;
        
        plot(power_levels, detection_rates, ...
            'Color', colors{color_idx}, ...
            'Marker', markers{marker_idx}, ...
            'LineWidth', 2, ...
            'MarkerSize', 8, ...
            'DisplayName', method);
    end
    
    xlabel(['Eavesdropper Power (' power_unit ')']);
    ylabel('Detection Rate');
    title('Detection Rate vs Eavesdropper Power');
    legend('Location', 'best');
    grid on;
    hold off;
end

function plotPowerSensitivityComparison(detection_results, method_names)
    % Plot power sensitivity comparison
    
    sensitivity_values = zeros(1, length(method_names));
    
    for i = 1:length(method_names)
        method = method_names{i};
        if isfield(detection_results.(method), 'power_sensitivity')
            sensitivity_values(i) = detection_results.(method).power_sensitivity;
        elseif isfield(detection_results.(method), 'power_detection_correlation')
            sensitivity_values(i) = detection_results.(method).power_detection_correlation;
        else
            sensitivity_values(i) = 0;
        end
    end
    
    bar(sensitivity_values);
    set(gca, 'XTickLabel', method_names);
    ylabel('Power Sensitivity Index');
    title('Power Sensitivity Comparison');
    grid on;
    
    % Add value labels on bars
    for i = 1:length(sensitivity_values)
        text(i, sensitivity_values(i) + 0.01, num2str(sensitivity_values(i), '%.3f'), ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
    end
end

function plotDetectionSlope(detection_results, method_names)
    % Plot detection improvement slope
    
    slope_values = zeros(1, length(method_names));
    
    for i = 1:length(method_names)
        method = method_names{i};
        if isfield(detection_results.(method), 'slope')
            slope_values(i) = detection_results.(method).slope;
        elseif isfield(detection_results.(method), 'avg_improvement_per_power')
            slope_values(i) = detection_results.(method).avg_improvement_per_power;
        else
            slope_values(i) = 0;
        end
    end
    
    bar(slope_values);
    set(gca, 'XTickLabel', method_names);
    ylabel('Detection Rate Slope');
    title('Detection Improvement with Power');
    grid on;
    
    % Add value labels on bars
    for i = 1:length(slope_values)
        text(i, slope_values(i) + 0.001, num2str(slope_values(i), '%.4f'), ...
            'HorizontalAlignment', 'center', 'FontSize', 10);
    end
end

function plotPowerPerformanceROC(detection_results, power_levels, method_names, power_unit)
    % Plot ROC-like power performance
    
    hold on;
    colors = {'b', 'r', 'g', 'm', 'c', 'y', 'k'};
    
    for i = 1:length(method_names)
        method = method_names{i};
        if isfield(detection_results.(method), 'detection_rate_per_power')
            detection_rates = detection_results.(method).detection_rate_per_power;
        else
            continue;
        end
        
        color_idx = mod(i-1, length(colors)) + 1;
        
        % Plot detection rate vs power (normalized)
        power_normalized = power_levels / max(power_levels);
        detection_normalized = detection_rates / max(detection_rates);
        
        plot(power_normalized, detection_normalized, ...
            'Color', colors{color_idx}, ...
            'LineWidth', 2, ...
            'DisplayName', method);
    end
    
    xlabel('Normalized Power Level');
    ylabel('Normalized Detection Rate');
    title('Power Performance Curve');
    legend('Location', 'best');
    grid on;
    hold off;
end

function plotFeaturePowerSensitivity(detection_results, power_levels, power_unit)
    % Plot feature power sensitivity
    
    if isfield(detection_results, 'power_metrics') && isfield(detection_results.power_metrics, 'power_sensitivity')
        feature_sensitivity = detection_results.power_metrics.power_sensitivity;
        
        plot(power_levels, feature_sensitivity, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
        xlabel(['Eavesdropper Power (' power_unit ')']);
        ylabel('Feature Power Sensitivity');
        title('Feature Power Sensitivity Analysis');
        grid on;
    else
        text(0.5, 0.5, 'Feature power sensitivity data not available', ...
            'HorizontalAlignment', 'center', 'FontSize', 12);
        title('Feature Power Sensitivity');
    end
end

function plotMethodPerformanceSummary(detection_results, method_names)
    % Plot method performance summary
    
    % Create performance matrix
    performance_metrics = {'Overall Detection Rate', 'Power Sensitivity', 'Detection Slope'};
    performance_matrix = zeros(length(method_names), length(performance_metrics));
    
    for i = 1:length(method_names)
        method = method_names{i};
        
        % Overall detection rate
        if isfield(detection_results.(method), 'overall_detection_rate')
            performance_matrix(i, 1) = detection_results.(method).overall_detection_rate;
        end
        
        % Power sensitivity
        if isfield(detection_results.(method), 'power_sensitivity')
            performance_matrix(i, 2) = detection_results.(method).power_sensitivity;
        end
        
        % Detection slope
        if isfield(detection_results.(method), 'slope')
            performance_matrix(i, 3) = detection_results.(method).slope;
        end
    end
    
    % Normalize performance matrix
    performance_matrix_norm = performance_matrix ./ max(performance_matrix, [], 1);
    
    % Create heatmap
    imagesc(performance_matrix_norm);
    colorbar;
    
    set(gca, 'XTick', 1:length(performance_metrics));
    set(gca, 'XTickLabel', performance_metrics);
    set(gca, 'YTick', 1:length(method_names));
    set(gca, 'YTickLabel', method_names);
    
    title('Method Performance Summary');
    
    % Add value labels
    for i = 1:length(method_names)
        for j = 1:length(performance_metrics)
            text(j, i, num2str(performance_matrix(i, j), '%.3f'), ...
                'HorizontalAlignment', 'center', 'Color', 'white', 'FontWeight', 'bold');
        end
    end
end
