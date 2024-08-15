function [trainedNet, accuracy] = lstmPSADetection(X, y)
    % LSTMPSADETECTION Train an LSTM network for PSA detection
    %
    % Inputs:
    %   X - Feature matrix (numSamples x numTimeSteps x numFeatures)
    %   y - Labels (categorical)
    %
    % Outputs:
    %   trainedNet - Trained LSTM network
    %   accuracy - Training accuracy

    numFeatures = size(X, 3);
    numClasses = numel(categories(y));

    layers = [ ...
        sequenceInputLayer(numFeatures)
        lstmLayer(100, 'OutputMode', 'last')
        fullyConnectedLayer(50)
        reluLayer
        dropoutLayer(0.5)
        fullyConnectedLayer(numClasses)
        softmaxLayer
        classificationLayer];

    options = trainingOptions('adam', ...
        'MaxEpochs', 50, ...
        'MiniBatchSize', 32, ...
        'Shuffle', 'every-epoch', ...
        'ValidationFrequency', 30, ...
        'Plots', 'training-progress', ...
        'Verbose', false);

    [trainedNet, info] = trainNetwork(X, y, layers, options);
    accuracy = info.TrainingAccuracy(end);

    disp(['LSTM Training Accuracy: ', num2str(accuracy)]);
end