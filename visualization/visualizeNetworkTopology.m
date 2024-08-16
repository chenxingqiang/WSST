function visualizeNetworkTopology(x_BS, y_BS, x_UE, y_UE, x_ED, y_ED, gridSize)
% VISUALIZENETWORKTOPOLOGY Visualize the positions of network elements
%
% Inputs:
% x_BS, y_BS - Coordinates of the Base Station
% x_UE, y_UE - Coordinates of the User Equipment
% x_ED, y_ED - Coordinates of the Eavesdropper
% gridSize - Size of the grid (assumed square)

% Input validation
if nargin < 7
    error('All input arguments are required: x_BS, y_BS, x_UE, y_UE, x_ED, y_ED, gridSize');
end

% Create figure
figure('Position', [100, 100, 800, 600]);

% Plot network elements
scatter(x_BS, y_BS, 100, 'rs', 'filled'); hold on;
scatter(x_UE, y_UE, 50, 'bo');
scatter(x_ED, y_ED, 75, 'gd', 'filled');

% Customize plot
legend('Base Station', 'User Equipment', 'Eavesdropper', 'Location', 'best');
title('Network Topology');
xlabel('X coordinate (m)');
ylabel('Y coordinate (m)');
axis([0 gridSize 0 gridSize]);
grid on;

% Add text labels for each point
text(x_BS, y_BS, '  BS', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
text(x_UE, y_UE, '  UE', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');
text(x_ED, y_ED, '  ED', 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left');

% Add text annotation for grid size
annotation('textbox', [0.15, 0.95, 0.7, 0.05], ...
    'String', sprintf('Grid Size: %d x %d m', gridSize, gridSize), ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', 'FontSize', 12);

% Save the figure
saveas(gcf, 'NetworkTopology.png');
disp('Network Topology visualization saved as NetworkTopology.png');
end