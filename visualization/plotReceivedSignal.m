function plotReceivedSignal(Y, N)
% VISUALIZEreceivedsignal Visualize received signal and calculate SNR
%
% Inputs:
% Y - Received signal matrix
% N - Noise matrix

% Check input dimensions
[numAntennas, numTimePoints] = size(Y);
if ~isequal(size(Y), size(N))
    error('Y and N must have the same dimensions');
end

% Create figure
figure('Position', [100, 100, 800, 800]);

% Plot magnitude of received signal
subplot(2, 1, 1);
imagesc(abs(Y));
colorbar;
title('Magnitude of Received Signal');
xlabel('Time Index');
ylabel('Antenna Index');

% Plot total received power over time
subplot(2, 1, 2);
totalPower = sum(abs(Y).^2, 1);
plot(1:numTimePoints, totalPower, '-o', 'LineWidth', 1, 'MarkerSize', 6);
title('Total Received Power Over Time');
xlabel('Time Index');
ylabel('Power');
grid on;

% Add text annotations for peak power points
[peakPower, peakIndex] = max(totalPower);
text(peakIndex, peakPower, sprintf('Peak: %.2f', peakPower), ...
    'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');

% Calculate and display signal-to-noise ratio (SNR)
signalPower = mean(abs(Y(:) - N(:)).^2);
noisePower = mean(abs(N(:)).^2);
SNR_dB = 10 * log10(signalPower / noisePower);

% Add text annotation for SNR
annotation('textbox', [0.15, 0.95, 0.7, 0.05], ...
    'String', sprintf('Estimated SNR: %.2f dB', SNR_dB), ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
    'FontWeight', 'bold', 'FontSize', 12);

% Save the figure
saveas(gcf, 'ReceivedSignalVisualization.png');
disp('Received Signal Visualization saved as ReceivedSignalVisualization.png');
end