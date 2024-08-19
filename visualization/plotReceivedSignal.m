function plotReceivedSignal(Y, N)
% VISUALIZEreceivedsignal Visualize received signal and calculate SNR
%
% Inputs:
% Y - Received signal matrix
% N - Noise matrix (optional)

% Check input dimensions
[numAntennas, numTimePoints] = size(Y);

if nargin < 2
    N = zeros(numAntennas, numTimePoints);  % If N is not provided, assume zero noise
else
    if ~isequal(size(Y), size(N))
        error('Y and N must have the same dimensions');
    end
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

% Calculate and display signal-to-noise ratio (SNR) if N is provided
if nargin > 1
    signalPower = mean(abs(Y(:) - N(:)).^2);
    noisePower = mean(abs(N(:)).^2);
    if noisePower > 0
        SNR_dB = 10 * log10(signalPower / noisePower);
        annotation('textbox', [0.15, 0.95, 0.7, 0.05], ...
            'String', sprintf('Estimated SNR: %.2f dB', SNR_dB), ...
            'EdgeColor', 'none', 'HorizontalAlignment', 'center', ...
            'FontWeight', 'bold', 'FontSize', 12);
    end
end

% Save the figure
saveas(gcf, 'ReceivedSignalVisualization.png');
disp('Received Signal Visualization saved as ReceivedSignalVisualization.png');

end