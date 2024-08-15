function plotExecutionTime(executionTimes)
% PLOTEXECUTIONTIME Plot execution times for different stages of the simulation
%
% Input:
%   executionTimes - Vector of execution times [trainTime, detectTime, locateSingleTime, locateMultipleTime]

    stages = {'Training', 'Detection', 'Single Localization', 'Multiple Localization'};
    
    figure('Position', [100, 100, 800, 400]);
    bar(executionTimes);
    
    title('Execution Time for Different Stages');
    xlabel('Stage');
    ylabel('Execution Time (seconds)');
    xticklabels(stages);
    xtickangle(45);
    
    % Add text annotations for each bar
    for i = 1:length(executionTimes)
        text(i, executionTimes(i), sprintf('%.2f s', executionTimes(i)), ...
             'HorizontalAlignment', 'center', ...
             'VerticalAlignment', 'bottom');
    end
    
    % Save the figure
    saveas(gcf, 'ExecutionTimes.png');
    disp('Execution time plot saved as ExecutionTimes.png');
end