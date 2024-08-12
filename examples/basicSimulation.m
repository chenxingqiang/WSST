% Basic Simulation Example
% This script demonstrates a basic simulation using the WSST library

% Parameters
M = 100;  % Number of BS antennas
K = 10;   % Number of UEs
Beta_UE = ones(M, K);  % Simplified path loss

% Generate UE channels
h_UE = generateUEChannels(M, K, Beta_UE);

% Display channel statistics
disp('UE Channel Statistics:');
disp(['Mean power: ', num2str(mean(abs(h_UE(:)).^2))]);
disp(['Standard deviation: ', num2str(std(abs(h_UE(:))))]);

% Plot channel magnitude
figure;
imagesc(abs(h_UE));
colorbar;
title('UE Channel Magnitude');
xlabel('User');
ylabel('Antenna');