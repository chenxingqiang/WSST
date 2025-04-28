function visualizeAttackedUsers(attackedUserIndices, attackedUserMetrics, K, figTitle)
% VISUALIZEATTACKEDUSERS Visualize which users are being attacked
%
% This function creates a comprehensive visualization showing detection metrics for all users
% and highlights the users that are identified as being attacked. It provides both a bar chart
% representation and additional statistical information about the detection results.
%
% Inputs:
%   attackedUserIndices - Indices of users detected as being attacked
%   attackedUserMetrics - Detection metrics for each user
%   K - Total number of legitimate users
%   figTitle - Title for the figure (optional)
%
% Outputs:
%   None (creates a visualization figure and saves it to disk)

    if nargin < 4
        figTitle = 'Attacked User Detection Results';
    end

    % Create a more comprehensive figure with multiple panels
    figure('Name', 'Attacked User Detection', 'Position', [100, 100, 1000, 700]);
    
    % Panel 1: Bar chart of detection metrics
    subplot(2, 2, [1, 3]);
    
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
    thresholdValue = 0.5; % Default threshold for PPR detection
    thresholdLine = plot([0.5, K+0.5], [thresholdValue, thresholdValue], '--k', 'LineWidth', 1.5);
    hold off;
    
    % Add labels and formatting
    xlabel('User Index', 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Detection Metric (PPR)', 'FontSize', 12, 'FontWeight', 'bold');
    title(figTitle, 'FontSize', 14, 'FontWeight', 'bold');
    
    % Add grid and adjust axis limits
    grid on;
    ylim([0, max(max(attackedUserMetrics)*1.2, thresholdValue*1.5)]);
    xlim([0.5, K+0.5]);
    
    % Add a legend
    legend([barHandles, thresholdLine], {'Detection Metric', 'Detection Threshold'}, 'Location', 'Best');
    
    % Add text labels for attacked users
    for i = attackedUserIndices
        text(i, attackedUserMetrics(i) + 0.05*max(attackedUserMetrics), ...
            ['User ', num2str(i)], ...
            'HorizontalAlignment', 'center', ...
            'VerticalAlignment', 'bottom', ...
            'FontWeight', 'bold', ...
            'Color', 'r');
    end
    
    % Panel 2: Pie chart showing proportion of attacked users
    subplot(2, 2, 2);
    pie([sum(isAttacked), K-sum(isAttacked)]);
    colormap([0.9, 0.3, 0.3; 0.3, 0.5, 0.9]);
    legend({'Attacked Users', 'Normal Users'}, 'Location', 'Best');
    title('Proportion of Attacked Users', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Panel 3: Detection metrics statistics
    subplot(2, 2, 4);
    axis off;
    
    % Calculate statistics
    attackedMetrics = attackedUserMetrics(isAttacked);
    normalMetrics = attackedUserMetrics(~isAttacked);
    
    % Create text for statistics
    statsText = {...
        ['\bf{Detection Statistics}'], ...
        [''], ...
        ['Number of Users: ' num2str(K)], ...
        ['Attacked Users: ' num2str(sum(isAttacked)) ' (' num2str(100*sum(isAttacked)/K, '%.1f') '%)'], ...
        ['Normal Users: ' num2str(K-sum(isAttacked)) ' (' num2str(100*(K-sum(isAttacked))/K, '%.1f') '%)'], ...
        [''], ...
        ['Threshold Value: ' num2str(thresholdValue)], ...
        [''], ...
        ['\bf{Metrics for Attacked Users}'], ...
        ['Mean: ' num2str(mean(attackedMetrics), '%.4f')], ...
        ['Max: ' num2str(max(attackedMetrics), '%.4f')], ...
        ['Min: ' num2str(min(attackedMetrics), '%.4f')], ...
        ['Std Dev: ' num2str(std(attackedMetrics), '%.4f')], ...
        [''], ...
        ['\bf{Metrics for Normal Users}'], ...
        ['Mean: ' num2str(mean(normalMetrics), '%.4f')], ...
        ['Max: ' num2str(max(normalMetrics), '%.4f')], ...
        ['Min: ' num2str(min(normalMetrics), '%.4f')], ...
        ['Std Dev: ' num2str(std(normalMetrics), '%.4f')], ...
    };
    
    % Display statistics
    text(0.1, 0.95, statsText, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'left', 'FontSize', 10, 'Interpreter', 'tex');
    
    % Make the figure background white
    set(gcf, 'Color', 'w');
    
    % Create a timestamp for the filename
    timestamp = datestr(now, 'yyyymmdd_HHMMSS');
    
    % Create a more descriptive filename based on the attack scenario
    if sum(isAttacked) == 0
        attackType = 'NoAttack';
    elseif sum(isAttacked) == 1
        attackType = 'SingleUserAttack';
    elseif sum(isAttacked) == 2
        attackType = 'TwoUserAttack';
    else
        attackType = 'MultiUserAttack';
    end
    
    % Generate filenames
    baseFilename = ['AttackedUsersDetection_' attackType '_' timestamp];
    pngFilename = [baseFilename '.png'];
    figFilename = [baseFilename '.fig'];
    
    % Save the figure in multiple formats
    saveas(gcf, pngFilename);
    saveas(gcf, figFilename);
    
    % Print additional information to console
    disp('------------------------------------------------------');
    disp('Attacked Users Detection Results:');
    disp(['Total Users: ' num2str(K)]);
    
    if isempty(attackedUserIndices)
        disp('No users detected as being attacked.');
    else
        disp(['Detected ' num2str(length(attackedUserIndices)) ' user(s) as being attacked:']);
        for i = 1:length(attackedUserIndices)
            disp(['  User ' num2str(attackedUserIndices(i)) ': Metric = ' num2str(attackedUserMetrics(attackedUserIndices(i)), '%.4f')]);
        end
    end
    
    disp(['Visualization saved as ' pngFilename]);
    disp('------------------------------------------------------');
end
