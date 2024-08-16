function plotMDLHistogram(MDL_values, threshold, num_bins)
    % plotMDLHistogram - Plot a histogram of MDL values with a detection threshold
    %
    % Inputs:
    %   MDL_values - Array of MDL values
    %   threshold - Detection threshold value
    %   num_bins - Number of bins for the histogram (optional, default is 50)
    
    % Set default number of bins if not provided
    if nargin < 3
        num_bins = 50;
    end
    
    % Create the figure
    figure;
    
    % Plot the histogram
    histogram(MDL_values, num_bins);
    
    % Hold on to add more elements to the plot
    hold on;
    
    % Add the threshold line
    xline(threshold, 'r--', 'LineWidth', 1);
    
    % Label the axes
    xlabel('MDL Values');
    ylabel('Frequency');
    
    % Add a title
    title('MDL Distribution and Detection Threshold');
    
    % Add a legend
    legend('MDL Values', 'Threshold');
    
    % Release the hold on the figure
    hold off;
end