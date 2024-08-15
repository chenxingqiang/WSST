#!/bin/bash

# Create main directory
mkdir -p WSST

# Create subdirectories
mkdir -p WSST/src/{channel,signal,attack,detection,utils,data,ml,localization}
mkdir -p WSST/examples
mkdir -p WSST/tests
mkdir -p WSST/visualization

# Create files in src/channel
touch WSST/src/channel/{generateUEChannels.m,generateEDChannel.m,calculatePathLoss.m}

# Create files in src/signal
touch WSST/src/signal/{generateNoise.m,generateTrainingSequence.m}

# Create files in src/attack
touch WSST/src/attack/{simulatePSA.m,calculatePPR.m}

# Create files in src/detection
touch WSST/src/detection/{calculateEigenvalues.m,detectPSA.m,detectMultipleAttackers.m}

# Create files in src/utils
touch WSST/src/utils/{addGaussianNoise.m,removeExtremelyLowVarianceFeatures.m}

# Create files in src/data
touch WSST/src/data/generateDataset.m

# Create files in src/ml
touch WSST/src/ml/trainAndSaveNNModels.m

# Create files in src/localization
touch WSST/src/localization/{locateSingleAttacker.m,locateMultipleAttackers.m}

# Create files in examples
touch WSST/examples/basicSimulation.m

# Create files in tests
touch WSST/tests/{testChannel.m,testSignal.m,testAttack.m,testDetection.m}

# Create files in visualization
touch WSST/visualization/{plotExecutionTime.m,plotErrorRates.m,plotDetectionAccuracy.m,plotLocalizationAccuracy.m,plotAccuracyVsComplexity.m,plotHeatmap.m,plotBestAlgorithm.m}

# Create files in root directory
touch WSST/{main.m,setup.m,README.md}

echo "WSST directory structure has been created successfully."