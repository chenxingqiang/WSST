function plotLocalizationAccuracy(attackerTargets, attackerTarget, n_attackers)
% PLOTLOCALIZATIONACCURACY Plot localization accuracy for single and multiple attackers
%
% Inputs:
%   attackerTargets - Estimated attacker indices for multiple attackers scenario
%   attackerTarget  - Estimated attacker index for single attacker scenario
%   n_attackers     - Number of attackers in multiple attackers scenario

    % Plot settings
    P_ED_dBm = 0:5:30;  % Assuming this is the range used
    numPED = length(P_ED_dBm);
    
    figure('Position', [100, 100, 1000, 400]);
    
    % Single attacker localization
    subplot(1, 2, 1);
    plot(P_ED_dBm, attackerTarget, 'bo-', 'LineWidth', 2);
    xlabel('Eavesdropper Power (dBm)');
    ylabel('Estimated Attacker Index');
    title('Single Attacker Localization');
    grid on;
    ylim([0, max(attackerTarget) + 1]);
    
    % Multiple attackers localization
    subplot(1, 2, 2);
    for i = 1:n_attackers
        plot(P_ED_dBm, attackerTargets(:, i), 'o-', 'LineWidth', 2);
        hold on;
    end
    hold off;
    xlabel('Eavesdropper Power (dBm)');
    ylabel('Estimated Attacker Indices');
    title('Multiple Attackers Localization');
    legend(arrayfun(@(x) sprintf('Attacker %d', x), 1:n_attackers, 'UniformOutput', false));
    grid on;
    ylim([0, max(attackerTargets(:)) + 1]);
    
    sgtitle('Attacker Localization Accuracy');
    
    % Save the figure
    saveas(gcf, 'LocalizationAccuracy.png');
    disp('Localization accuracy plot saved as LocalizationAccuracy.png');
end