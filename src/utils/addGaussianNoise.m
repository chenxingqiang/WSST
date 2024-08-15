function X_noisy = addGaussianNoise(X, noise_level, varargin)
% ADDGAUSSIANNOISE Add Gaussian noise to input data
%
% This function adds Gaussian noise to the input data, which can be used
% for data augmentation or to simulate noisy measurements.
%
% Inputs:
%   X           - Input data (can be a vector, matrix, or n-dimensional array)
%   noise_level - Standard deviation of the Gaussian noise
%
% Optional Name-Value Pair Arguments:
%   'SNR'       - If provided, noise_level is interpreted as target SNR in dB
%   'Complex'   - Boolean flag for complex-valued noise (default: false)
%
% Output:
%   X_noisy     - Noisy version of the input data
%
% Example:
%   X_noisy = addGaussianNoise(X, 0.1);
%   X_noisy = addGaussianNoise(X, 20, 'SNR', true);

    % Input parsing
    p = inputParser;
    addRequired(p, 'X', @isnumeric);
    addRequired(p, 'noise_level', @(x) isnumeric(x) && isscalar(x) && x > 0);
    addParameter(p, 'SNR', false, @islogical);
    addParameter(p, 'Complex', false, @islogical);
    parse(p, X, noise_level, varargin{:});

    % Generate noise
    if p.Results.Complex
        noise = (randn(size(X)) + 1i * randn(size(X))) / sqrt(2);
    else
        noise = randn(size(X));
    end

    % Adjust noise level if SNR is specified
    if p.Results.SNR
        signal_power = mean(abs(X(:)).^2);
        noise_power = signal_power / (10^(noise_level/10));
        noise_level = sqrt(noise_power);
    end

    % Add noise to the input data
    X_noisy = X + noise_level * noise;

    % Visualize the effect of noise (for 1D or 2D data)
    if ndims(X) <= 2
        figure;
        if isvector(X)
            subplot(2,1,1);
            plot(X, 'b-', 'LineWidth', 1.5);
            hold on;
            plot(X_noisy, 'r-', 'LineWidth', 1);
            title('Original vs Noisy Data');
            legend('Original', 'Noisy');
            xlabel('Sample Index');
            ylabel('Value');
        else
            subplot(2,2,1);
            imagesc(abs(X));
            title('Original Data Magnitude');
            colorbar;
            subplot(2,2,2);
            imagesc(abs(X_noisy));
            title('Noisy Data Magnitude');
            colorbar;
            subplot(2,2,3);
            imagesc(abs(X_noisy - X));
            title('Noise Magnitude');
            colorbar;
        end
    end

    % Calculate and display SNR
    signal_power = mean(abs(X(:)).^2);
    noise_power = mean(abs(X_noisy(:) - X(:)).^2);
    SNR = 10 * log10(signal_power / noise_power);
    disp(['Resulting SNR: ', num2str(SNR), ' dB']);
end