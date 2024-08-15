function layers = defineModelArchitecture(numFeatures, numClasses, modelType)
    % DEFINEMODELARCHITECTURE Define the neural network architecture
    %
    % This function allows for easy modification of the model structure.
    % You can adjust the number of layers, neurons, and other parameters here.
    
    switch modelType
        case 'PPR'
            layers = [
                featureInputLayer(numFeatures, "Name", "Input")
                fullyConnectedLayer(128, "Name", "fc1")
                batchNormalizationLayer("Name", "bn1")
                reluLayer("Name", "relu1")
                dropoutLayer(0.5, "Name", "dropout1")
                fullyConnectedLayer(64, "Name", "fc2")
                batchNormalizationLayer("Name", "bn2")
                reluLayer("Name", "relu2")
                dropoutLayer(0.3, "Name", "dropout2")
                fullyConnectedLayer(32, "Name", "fc3")
                reluLayer("Name", "relu3")
                fullyConnectedLayer(numClasses, "Name", "fc4")
                softmaxLayer("Name", "softmax")
                classificationLayer("Name", "classification")];
        case 'Eig'
            layers = [
                featureInputLayer(numFeatures, "Name", "Input")
                fullyConnectedLayer(256, "Name", "fc1")
                batchNormalizationLayer("Name", "bn1")
                reluLayer("Name", "relu1")
                dropoutLayer(0.5, "Name", "dropout1")
                fullyConnectedLayer(128, "Name", "fc2")
                batchNormalizationLayer("Name", "bn2")
                reluLayer("Name", "relu2")
                dropoutLayer(0.4, "Name", "dropout2")
                fullyConnectedLayer(64, "Name", "fc3")
                batchNormalizationLayer("Name", "bn3")
                reluLayer("Name", "relu3")
                dropoutLayer(0.3, "Name", "dropout3")
                fullyConnectedLayer(32, "Name", "fc4")
                reluLayer("Name", "relu4")
                fullyConnectedLayer(numClasses, "Name", "fc5")
                softmaxLayer("Name", "softmax")
                classificationLayer("Name", "classification")];
        otherwise
            error('Unknown model type');
    end
end