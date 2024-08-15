function plotHeatmap(heatmapData)
% PLOTHEATMAP Plot a heatmap of detection accuracy or other metrics
%
% Input:
%   heatmapData - 2D matrix of data to be plotted as a heatmap

    figure('Position', [100, 100, 800, 600]);
    imagesc(heatmapData);
    colormap('jet');
    colorbar;
    
    title('Detection Performance Heatmap');
    xlabel('User Index');
    ylabel('Eavesdropper Power Level');
    
    % Add text annotations for each cell
    [m, n] = size(heatmapData);
    for i = 1:m
        for j = 1:n
            text(j, i, sprintf('%.2f', heatmapData(i,j)), ...
                 'HorizontalAlignment', 'center', ...
                 'VerticalAlignment', 'middle');
        end
    end
    
    % Save the figure
    saveas(gcf, 'DetectionHeatmap.png');
    disp('Heatmap plot saved as DetectionHeatmap.png');
end