# Machine Learning API

This document describes the functions available in the `src/ml` directory of the Wireless Security Simulation Toolkit (WSST) for training and evaluating machine learning models for pilot spoofing attack detection.

## Functions

### `defineModelArchitecture`

```matlab
function layers = defineModelArchitecture(inputSize, numClasses)
```

Defines the architecture of a neural network model for pilot spoofing attack detection.

#### Inputs
- `inputSize`: Size of the input feature vector
- `numClasses`: Number of output classes

#### Output
- `layers`: Neural network layer array

### `ensemblePSADetection`

```matlab
function [accuracy, F1score] = ensemblePSADetection(X_train, y_train, X_test, y_test)
```

Trains an ensemble of machine learning models for pilot spoofing attack detection and evaluates their performance.

#### Inputs
- `X_train`: Training feature matrix
- `y_train`: Training label vector
- `X_test`: Testing feature matrix
- `y_test`: Testing label vector

#### Outputs
- `accuracy`: Detection accuracy of the ensemble model
- `F1score`: F1 score of the ensemble model

### `gradientBoostingPSADetection`

```matlab
function [accuracy, F1score] = gradientBoostingPSADetection(X_train, y_train, X_test, y_test)
```

Trains a gradient boosting model for pilot spoofing attack detection and evaluates its performance.

#### Inputs
- `X_train`: Training feature matrix
- `y_train`: Training label vector
- `X_test`: Testing feature matrix
- `y_test`: Testing label vector

#### Outputs
- `accuracy`: Detection accuracy of the gradient boosting model
- `F1score`: F1 score of the gradient boosting model

### `lstmPSADetection`

```matlab
function [accuracy, F1score] = lstmPSADetection(X_train, y_train, X_test, y_test)
```

Trains an LSTM neural network model for pilot spoofing attack detection and evaluates its performance.

#### Inputs
- `X_train`: Training feature matrix
- `y_train`: Training label vector
- `X_test`: Testing feature matrix
- `y_test`: Testing label vector

#### Outputs
- `accuracy`: Detection accuracy of the LSTM model
- `F1score`: F1 score of the LSTM model

### `randomForestPSADetection`

```matlab
function [accuracy, F1score] = randomForestPSADetection(X_train, y_train, X_test, y_test)
```

Trains a random forest model for pilot spoofing attack detection and evaluates its performance.

#### Inputs
- `X_train`: Training feature matrix
- `y_train`: Training label vector
- `X_test`: Testing feature matrix
- `y_test`: Testing label vector

#### Outputs
- `accuracy`: Detection accuracy of the random forest model
- `F1score`: F1 score of the random forest model

### `svmPSADetection`

```matlab
function [accuracy, F1score] = svmPSADetection(X_train, y_train, X_test, y_test)
```

Trains a support vector machine (SVM) model for pilot spoofing attack detection and evaluates its performance.

#### Inputs
- `X_train`: Training feature matrix
- `y_train`: Training label vector
- `X_test`: Testing feature matrix
- `y_test`: Testing label vector

#### Outputs
- `accuracy`: Detection accuracy of the SVM model
- `F1score`: F1 score of the SVM model

### `trainAllModels`

```matlab
function [accuracies, F1scores] = trainAllModels(X_train, y_train, X_test, y_test)
```

Trains multiple machine learning models for pilot spoofing attack detection and evaluates their performance.

#### Inputs
- `X_train`: Training feature matrix
- `y_train`: Training label vector
- `X_test`: Testing feature matrix
- `y_test`: Testing label vector

#### Outputs
- `accuracies`: Detection accuracies of the trained models
- `F1scores`: F1 scores of the trained models

### `trainAndSaveNNModels`

```matlab
function trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label)
```

Trains neural network models for pilot spoofing attack detection using PPR and eigenvalue features and saves the trained models.

#### Inputs
- `X_feature_PPR`: PPR feature matrix
- `X_feature_Eig`: Eigenvalue feature matrix
- `y_label`: Label vector

#### Outputs
- Saves the trained neural network models to files.

</antArtifact>