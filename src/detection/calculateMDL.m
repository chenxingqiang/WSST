function MDL_values = calculateMDL(X_feature_Eig)
    % Calculate MDL values based on eigenvalue features
    MDL_values = sum(log(abs(X_feature_Eig)), 2);
    
    % Ensure real values
    MDL_values = real(MDL_values);
    
    % Add these debug lines:
    disp(['Size of X_feature: ', num2str(size(X_feature_Eig))]);
    disp(['Min of X_feature: ', num2str(min(X_feature_Eig(:)))]);
    disp(['Max of X_feature: ', num2str(max(X_feature_Eig(:)))]);
    disp(['Min of MDL_values: ', num2str(min(MDL_values))]);
    disp(['Max of MDL_values: ', num2str(max(MDL_values))]);
end