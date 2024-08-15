function trainedModels = trainAllModels(X_feature_PPR, X_feature_Eig, y_label)
    % Prepare data
    X_PPR_2D = reshape(X_feature_PPR, [], size(X_feature_PPR, 2));
    X_Eig_2D = reshape(X_feature_Eig, [], size(X_feature_Eig, 2));
    y = categorical(y_label(:));

    % Train models on PPR features
    [trainedModels.svm_PPR, acc_svm_PPR] = svmPSADetection(X_PPR_2D, y);
    [trainedModels.rf_PPR, acc_rf_PPR] = randomForestPSADetection(X_PPR_2D, y);
    [trainedModels.gb_PPR, acc_gb_PPR] = gradientBoostingPSADetection(X_PPR_2D, y);

    % Train models on Eigenvalue features
    [trainedModels.svm_Eig, acc_svm_Eig] = svmPSADetection(X_Eig_2D, y);
    [trainedModels.rf_Eig, acc_rf_Eig] = randomForestPSADetection(X_Eig_2D, y);
    [trainedModels.gb_Eig, acc_gb_Eig] = gradientBoostingPSADetection(X_Eig_2D, y);

    % Train LSTM (assuming temporal data)
    [trainedModels.lstm, acc_lstm] = lstmPSADetection(X_feature_Eig, y);

    % Train original neural networks
    [trainedModels.nn_PPR, trainedModels.nn_Eig] = trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label);

    % Train ensemble
    [trainedModels.ensemble, acc_ensemble] = ensemblePSADetection(X_PPR_2D, y);

    % Display results
    disp('Training Accuracies:');
    disp(['SVM (PPR): ', num2str(acc_svm_PPR)]);
    disp(['Random Forest (PPR): ', num2str(acc_rf_PPR)]);
    disp(['Gradient Boosting (PPR): ', num2str(acc_gb_PPR)]);
    disp(['SVM (Eig): ', num2str(acc_svm_Eig)]);
    disp(['Random Forest (Eig): ', num2str(acc_rf_Eig)]);
    disp(['Gradient Boosting (Eig): ', num2str(acc_gb_Eig)]);
    disp(['LSTM: ', num2str(acc_lstm)]);
    disp(['Ensemble: ', num2str(acc_ensemble)]);

    % Save models
    save('trainedModels.mat', 'trainedModels');
end