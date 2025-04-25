function visualizeAttackedUsers(attackedUserIndices, attackedUserMetrics, K, figTitle)
% VISUALIZEATTACKEDUSERS Visualize which users are being attacked
%
% This function creates a bar chart showing detection metrics for all users
% and highlights the users that are identified as being attacked
%
% Inputs:
%   attackedUserIndices - Indices of users detected as being attacked
%   attackedUserMetrics - Detection metrics for each user
%   K - Total number of legitimate users
%   figTitle - Title for the figure (optional)
%
% Outputs:
%   None (creates a visualization figure)

    if nargin < 4
        figTitle = 'Attacked User Detection Results';
    end

    % Create figure
    figure('Name', 'Attacked User Detection', 'Position', [100, 100, 800, 500]);
    
    % Create bar graph of metrics for all users
    barHandles = bar(1:K, attackedUserMetrics, 0.6);
    
    % Set bar colors based on whether user is identified as attacked
    isAttacked = false(1, K);
    isAttacked(attackedUserIndices) = true;
    
    % Create color map (blue for non-attacked, red for attacked)
    colorMap = zeros(K, 3);
    colorMap(~isAttacked, :) = repmat([0.3, 0.5, 0.9], sum(~isAttacked), 1); % Blue for normal
    colorMap(isAttacked, :) = repmat([0.9, 0.3, 0.3], sum(isAttacked), 1);   % Red for attacked
    
    % Apply colors to bars
    for i = 1:K
        barHandles.FaceColor = 'flat';
        barHandles.CData(i,:) = colorMap(i,:);
    end
    
    % Add threshold line
    hold on;
    plot([0.5, K+0.5], [0.5, 0.5], '--k', 'LineWidth', 1.5);
    hold off;
    
    % Add labels and formatting
    xlabel('User Index', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Detection Metric (PPR)', 'FontSize', 12, 'FontWeight', 'bold');
    title(figTitle, 'FontSize', 14, 'FontWeight', 'bold');
    
    % Add grid and adjust axis limits
    grid on;
    ylim([0, max(attackedUserMetrics)*1.2]);
    xlim([0.5, K+0.5]);
    
    % Add a legend
    if any(isAttacked) && any(~isAttacked)
        legend('Detection Metric', 'Detection Threshold', 'Location', 'Best');
    end
    
    % Add text labels for attacked users
    for i = attackedUserIndices
        text(i, attackedUserMetrics(i) + 0.05*max(attackedUserMetrics), ...
            ['User ', num2str(i)], ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontWeight', 'bold', ...
            'Color', 'r');
    end
    
    % Make the figure background white
    set(gcf, 'Color', 'w');
    
    % Save the figure
    saveas(gcf, 'AttackedUsersDetection.png');
    saveas(gcf, 'AttackedUsersDetection.fig');
    
    disp('Attacked users visualization saved as AttackedUsersDetection.png');
end
