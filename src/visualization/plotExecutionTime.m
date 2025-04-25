function plotExecutionTime(executionTimes, labels)
% PLOTEXECUTIONTIME Plot execution times for different stages of the simulation
%
% Inputs:
%   executionTimes - Vector of execution times (in seconds)
%   labels - (Optional) Cell array of labels for each time measurement
%
% Outputs:
%   None (creates a visualization figure)

    % Set default labels if not provided
    if nargin < 2 || isempty(labels)
        labels = {'Training', 'Attack Detection', 'Single Attacker Localization', 'Multiple Attacker Localization'};
    end
    
    % Ensure labels match execution times length
    if length(labels) ~= length(executionTimes)
        warning('Number of labels does not match number of execution times. Adjusting labels.');
        if length(labels) > length(executionTimes)
            labels = labels(1:length(executionTimes));
        else
            additionalLabels = arrayfun(@(x) ['Stage ' num2str(x)], (length(labels)+1):length(executionTimes), 'UniformOutput', false);
            labels = [labels, additionalLabels];
        end
    end

    % Create figure
    figure('Name', 'Execution Times', 'Position', [100, 100, 800, 500]);
    
    % Create bar chart
    bar(executionTimes, 0.6, 'FaceColor', [0.4, 0.6, 0.8]);
    
    % Add labels, title, and grid
    xlabel('Processing Stage', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Execution Time (seconds)', 'FontSize', 12, 'FontWeight', 'bold');
    title('Execution Times for Different Processing Stages', 'FontSize', 14, 'FontWeight', 'bold');
    grid on;
    
    % Set x-axis tick labels
    set(gca, 'XTick', 1:length(executionTimes));
    set(gca, 'XTickLabel', labels);
    xtickangle(45);
    
    % Add text labels above bars
    for i = 1:length(executionTimes)
        text(i, executionTimes(i) + max(executionTimes)*0.02, ...
            [num2str(executionTimes(i), '%.2f') 's'], ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontWeight', 'bold');
    end
    
    % Adjust y-axis limits to make room for text
    ylim([0, max(executionTimes)*1.15]);
    
    % Add total execution time as text
    totalTime = sum(executionTimes);
    text(length(executionTimes)/2, max(executionTimes)*1.1, ...
        ['Total Execution Time: ' num2str(totalTime, '%.2f') ' seconds'], ...
        'HorizontalAlignment', 'center', ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.9, 0.9, 0.9]);
    
    % Make the figure background white
    set(gcf, 'Color', 'w');
    
    % Save the figure
    saveas(gcf, 'ExecutionTimes.png');
    saveas(gcf, 'ExecutionTimes.fig');
    
    disp('Execution time plot saved as ExecutionTimes.png');
end
