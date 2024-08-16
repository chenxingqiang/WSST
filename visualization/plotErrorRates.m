function plotErrorRates(P_ED_dBm, FPR_PPR_NN, FNR_PPR_NN, FPR_Eig_NN, FNR_Eig_NN)
% PLOTERRORRATES Plot False Positive and False Negative Rates
%
% This function creates plots to visualize the False Positive Rate (FPR) and
% False Negative Rate (FNR) for different PSA detection methods across
% various eavesdropper power levels.
%
% Inputs:
%   P_ED_dBm   - Eavesdropper power levels in dBm
%   FPR_PPR_NN - False Positive Rate for PPR-based Neural Network
%   FNR_PPR_NN - False Negative Rate for PPR-based Neural Network
%   FPR_Eig_NN - False Positive Rate for Eigenvalue-based Neural Network
%   FNR_Eig_NN - False Negative Rate for Eigenvalue-based Neural Network

    % Input validation
    validateattributes(P_ED_dBm, {'numeric'}, {'vector'});
    validateattributes(FPR_PPR_NN, {'numeric'}, {'vector', 'numel', numel(P_ED_dBm)});
    validateattributes(FNR_PPR_NN, {'numeric'}, {'vector', 'numel', numel(P_ED_dBm)});
    validateattributes(FPR_Eig_NN, {'numeric'}, {'vector', 'numel', numel(P_ED_dBm)});
    validateattributes(FNR_Eig_NN, {'numeric'}, {'vector', 'numel', numel(P_ED_dBm)});

    % Remove NaN values
    valid_indices = ~isnan(FPR_PPR_NN) & ~isnan(FNR_PPR_NN) & ~isnan(FPR_Eig_NN) & ~isnan(FNR_Eig_NN);
    P_ED_dBm = P_ED_dBm(valid_indices);
    FPR_PPR_NN = FPR_PPR_NN(valid_indices);
    FNR_PPR_NN = FNR_PPR_NN(valid_indices);
    FPR_Eig_NN = FPR_Eig_NN(valid_indices);
    FNR_Eig_NN = FNR_Eig_NN(valid_indices);

    % Create figure
    figure('Name', 'Error Rates vs. Eavesdropper Power', 'Position', [100, 100, 800, 600]);

    % Plot FPR
    subplot(2,1,1);
    plot(P_ED_dBm, FPR_PPR_NN, 'b-o', 'LineWidth', 1, 'MarkerSize', 6);
    hold on;
    plot(P_ED_dBm, FPR_Eig_NN, 'r-s', 'LineWidth', 1, 'MarkerSize', 6);
    hold off;
    title('False Positive Rate vs. Eavesdropper Power');
    xlabel('Eavesdropper Power (dBm)');
    ylabel('False Positive Rate');
    legend('PPR-NN', 'Eig-NN', 'Location', 'best');
    grid on;

    % Plot FNR
    subplot(2,1,2);
    plot(P_ED_dBm, FNR_PPR_NN, 'b-o', 'LineWidth', 1, 'MarkerSize', 6);
    hold on;
    plot(P_ED_dBm, FNR_Eig_NN, 'r-s', 'LineWidth', 1, 'MarkerSize', 6);
    hold off;
    title('False Negative Rate vs. Eavesdropper Power');
    xlabel('Eavesdropper Power (dBm)');
    ylabel('False Negative Rate');
    legend('PPR-NN', 'Eig-NN', 'Location', 'best');
    grid on;

    % Adjust layout
    sgtitle('Error Rates vs. Eavesdropper Power');
    
    % Save the figure
    saveas(gcf, 'ErrorRates.png');
    disp('Error rates plot saved as ErrorRates.png');

    % Calculate and display average error rates
    avg_FPR_PPR = mean(FPR_PPR_NN);
    avg_FNR_PPR = mean(FNR_PPR_NN);
    avg_FPR_Eig = mean(FPR_Eig_NN);
    avg_FNR_Eig = mean(FNR_Eig_NN);

    disp(['Average FPR (PPR-NN): ', num2str(avg_FPR_PPR)]);
    disp(['Average FNR (PPR-NN): ', num2str(avg_FNR_PPR)]);
    disp(['Average FPR (Eig-NN): ', num2str(avg_FPR_Eig)]);
    disp(['Average FNR (Eig-NN): ', num2str(avg_FNR_Eig)]);
end