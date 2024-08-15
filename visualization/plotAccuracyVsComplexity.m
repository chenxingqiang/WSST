function plotAccuracyVsComplexity(complexityLevels, accuracyLevels)
% PLOTACCURACYVSCOMPLEXITY Plot detection accuracy vs. system complexity
%
% Inputs:
%   complexityLevels - Vector of complexity levels (e.g., number of antennas)
%   accuracyLevels   - Matrix of accuracy levels for different methods
%                      Each row corresponds to a method, each column to a complexity level

    [numMethods, numLevels] = size(accuracyLevels);
    if numLevels ~= length(complexityLevels)
        error('Number of complexity levels must match the number of columns in accuracyLevels');
    end

    methodNames = {'PPR', 'MDL', 'PPR-NN', 'Eig-NN'};
    colors = lines(numMethods);

    figure('Position', [100, 100, 800, 600]);
    for i = 1:numMethods
        plot(complexityLevels, accuracyLevels(i, :), '-o', 'Color', colors(i, :), 'LineWidth', 2, 'MarkerSize', 8);
        hold on;
    end
    hold off;

    xlabel('System Complexity (Number of Antennas)');
    ylabel('Detection Accuracy');
    title('Detection Accuracy vs. System Complexity');
    legend(methodNames(1:numMethods), 'Location', 'best');
    grid on;

    % Add text annotations for each data point
    for i = 1:numMethods
        for j = 1:numLevels
            text(complexityLevels(j), accuracyLevels(i, j), sprintf('%.2f', accuracyLevels(i, j)), ...
                 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
        end
    end

    % Save the figure
    saveas(gcf, 'AccuracyVsComplexity.png');
    disp('Accuracy vs. Complexity plot saved as AccuracyVsComplexity.png');
end