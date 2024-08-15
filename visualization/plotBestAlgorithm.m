function plotBestAlgorithm(P_ED_dBm, bestAlgoIdx)
% PLOTBESTALGORITHM Plot the best performing algorithm for each power level
%
% Inputs:
%   P_ED_dBm    - Vector of eavesdropper power levels in dBm
%   bestAlgoIdx - Vector of indices indicating the best algorithm for each power level

    algorithms = {'PPR', 'MDL', 'PPR-NN', 'Eig-NN'};
    colors = lines(length(algorithms));
    
    figure('Position', [100, 100, 800, 400]);
    for i = 1:length(algorithms)
        plot(P_ED_dBm(bestAlgoIdx == i), i * ones(sum(bestAlgoIdx == i), 1), ...
             'o', 'Color', colors(i,:), 'MarkerSize', 10, 'LineWidth', 2);
        hold on;
    end
    
    ylim([0.5, length(algorithms)+0.5]);
    yticks(1:length(algorithms));
    yticklabels(algorithms);
    
    title('Best Performing Algorithm vs. Eavesdropper Power');
    xlabel('Eavesdropper Power (dBm)');
    ylabel('Best Algorithm');
    grid on;
    
    % Save the figure
    saveas(gcf, 'BestAlgorithm.png');
    disp('Best algorithm plot saved as BestAlgorithm.png');
end