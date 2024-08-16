function visualizePPRDistribution(PPR_values, threshold)
% VISUALIZEPPRDISTRIBUTION Visualize the PPR distribution and detection threshold
%
% Inputs:
% PPR_values - Vector of Probability of Peak Ratio (PPR) values
% threshold - Detection threshold value

% Input validation
if nargin < 2
    error('Both PPR_values and threshold are required inputs');
end
if ~isvector(PPR_values)
    error('PPR_values must be a vector');
end
if ~isscalar(threshold)
    error('threshold must be a scalar value');
end

% Create figure
figure('Position', [100, 100, 800, 600]);

% Plot histogram of PPR values
histogram(PPR_values, 50, 'Normalization', 'probability');
hold on;

% Plot threshold line
xline(threshold, 'r--', 'LineWidth', 2);

% Customize plot
xlabel('PPR Values');
ylabel('Probability');
title('PPR Distribution and Detection Threshold');
legend('PPR Values', 'Threshold', 'Location', 'best');
grid on;

% Add text annotation for threshold value
annotation('textbox', [0.15, 0.95, 0.7, 0.05], ...
    'String', sprintf('Threshold: %.4f', threshold), ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', 'FontSize', 12);

% Calculate and display some statistics
mean_ppr = mean(PPR_values);
std_ppr = std(PPR_values);
detection_rate = sum(PPR_values > threshold) / length(PPR_values);

stats_str = sprintf('Mean PPR: %.4f\nStd Dev: %.4f\nDetection Rate: %.2f%%', ...
    mean_ppr, std_ppr, detection_rate * 100);
annotation('textbox', [0.15, 0.02, 0.7, 0.1], ...
    'String', stats_str, ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', ...
    'FontSize', 10);

hold off;

% Save the figure
saveas(gcf, 'PPRDistribution.png');
disp('PPR Distribution visualization saved as PPRDistribution.png');
end