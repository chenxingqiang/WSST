function plotDetectionAccuracy(P_ED_dBm, detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN)
% PLOTDETECTIONACCURACY Plot detection accuracy for different methods
%
% This function creates a plot comparing the detection accuracy of
% different PSA detection methods across various eavesdropper power levels.
%
% Inputs:
%   P_ED_dBm     - Eavesdropper power levels in dBm
%   detAcc_PPR   - Detection accuracy using PPR method
%   detAcc_MDL   - Detection accuracy using MDL method
%   detAcc_PPR_NN- Detection accuracy using PPR-based neural network
%   detAcc_Eig_NN- Detection accuracy using Eigenvalue-based neural network

    figure;
    plot(P_ED_dBm, detAcc_PPR, 'b-o', 'LineWidth', 2);
    hold on;
    plot(P_ED_dBm, detAcc_MDL, 'r-s', 'LineWidth', 2);
    plot(P_ED_dBm, detAcc_PPR_NN, 'g-^', 'LineWidth', 2);
    plot(P_ED_dBm, detAcc_Eig_NN, 'm-d', 'LineWidth', 2);
    hold off;

    xlabel('Eavesdropper Power (dBm)');
    ylabel('Detection Accuracy');
    title('PSA Detection Accuracy vs Eavesdropper Power');
    legend('PPR', 'MDL', 'PPR-NN', 'Eig-NN', 'Location', 'best');
    grid on;
    
    % Save the figure
    saveas(gcf, 'DetectionAccuracy.png');
    disp('Detection accuracy plot saved as DetectionAccuracy.png');
end