# Wireless Security Simulation Toolkit (WSST)

## Overview

The Wireless Security Simulation Toolkit (WSST) is a MATLAB-based library for simulating and analyzing Pilot Spoofing Attacks (PSA) in massive MIMO systems. It provides a comprehensive set of tools for channel modeling, signal processing, attack simulation, and detection using both traditional methods and machine learning approaches. The toolkit now includes enhanced functionality for detecting which specific users are being targeted by attackers, not just whether an attack is present in the system.

## Features

- Channel modeling for massive MIMO systems
- Generation of orthogonal training sequences
- Simulation of Pilot Spoofing Attacks
- Implementation of various PSA detection methods:
  - Pilot Pollution Ratio (PPR)
  - Minimum Description Length (MDL)
  - Neural Network-based detection
- **User-specific attack detection:**
  - Identification of which specific users are being targeted
  - Support for multiple attack scenarios (single user, two users, multiple users)
  - Performance metrics including precision, recall, and F1 score
- Attacker localization for both single and multiple attackers
- Performance analysis and visualization tools

## Installation

1. Clone this repository or download the source code.
2. Add the WSST directory and its subdirectories to your MATLAB path:

```matlab
addpath(genpath('path/to/WSST'));
```

Alternatively, you can run the `setup.m` script to automatically set up the paths.

## Usage

Here's a basic example of how to use WSST:

```matlab
% Set parameters
M = 100;  % Number of BS antennas
K = 8;    % Number of users
tau = 16; % Training sequence length
% ... (set other parameters)

% Generate dataset
[X_feature_PPR, X_feature_Eig, y_label] = generateDataset(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED);

% Train neural network models
trainAndSaveNNModels(X_feature_PPR, X_feature_Eig, y_label);

% Perform attack detection
[detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN] = detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal);

% Define attack scenarios for user-specific detection
attackScenarios = struct();
attackScenarios(1).name = 'Single User Attack';
attackScenarios(1).numAttacked = 1;
attackScenarios(1).fixedUsers = 3; % User 3 is always attacked

attackScenarios(2).name = 'Two User Attack';
attackScenarios(2).numAttacked = 2;
attackScenarios(2).fixedUsers = [2, 6]; % Users 2 and 6 are always attacked

% Perform user-specific attack detection
[detectionResults, userAccuracy] = simulateAttackedUserDetection(M, K, tau, gridSize, nbLoc, nbChanReal, P_ED, attackScenarios);

% Visualize results
plotDetectionAccuracy(P_ED_dBm, detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN);

% Visualize user-specific detection results
testResults = testDetectAttackedUsers();
caseResult = testResults.caseResults{2}; % Multiple user attack case
visualizeAttackedUsers(caseResult.detectedAttackedUsers, caseResult.detectionMetrics, K, 'Attacked User Detection');

```

For more detailed examples, please refer to the `examples` directory.

## Simulation Results

The WSST toolkit generates various plots to visualize the simulation results and performance metrics. Here's a description of each plot:

### Accuracy vs. Complexity
![Accuracy vs. Complexity](results/AccuracyVsComplexity.png)
This plot shows the detection accuracy of different methods (PPR, MDL, PPR-NN, Eig-NN) against the system complexity, represented by the number of base station antennas. It helps evaluate the trade-off between detection performance and system complexity.

### Best Algorithm
![Best Algorithm](results/BestAlgorithm.png)
This plot identifies and displays the best performing algorithm (PPR, MDL, PPR-NN, or Eig-NN) for each eavesdropper power level. It helps determine the most suitable detection method under different attack scenarios.

### Detection Accuracy
![Detection Accuracy](results/DetectionAccuracy.png)
This plot shows the detection accuracy of different methods (PPR, MDL, PPR-NN, Eig-NN) across different eavesdropper power levels. It provides an overview of the detection performance of each method under varying attack strengths.

### Detection Heatmap
![Detection Heatmap](results/DetectionHeatmap.png)
This heatmap visualizes the detection accuracy of the PPR-NN method for different combinations of base station antennas and eavesdropper power levels. It offers a more detailed view of the PPR-NN performance across different system configurations.

### Error Rates
![Error Rates](results/ErrorRates.png)
This plot displays the false positive rate (FPR) and false negative rate (FNR) of the PPR-NN and Eig-NN methods across different eavesdropper power levels. It helps assess the reliability of these detection methods in terms of minimizing false alarms and missed detections.

### Execution Times
![Execution Times](results/ExecutionTimes.png)
This plot visualizes the execution times of different stages of the simulation, including training, detection, and localization. It provides insights into the computational efficiency of the WSST toolkit and helps identify potential bottlenecks.

### Localization Accuracy
![Localization Accuracy](results/LocalizationAccuracy.png)
This plot shows the localization accuracy for single and multiple attacker scenarios. It demonstrates the ability of the WSST toolkit to estimate the positions of the attackers based on the received signals at the base station.

### MDL Histogram
![MDL Histogram](results/MDLHistogram.png)
This histogram displays the distribution of Minimum Description Length (MDL) values calculated from the received signals. It also shows the detection threshold used to distinguish between the presence and absence of attacks based on the MDL values.

### Network Topology
![Network Topology](results/NetworkTopology.png)
This plot visualizes the spatial arrangement of the base station, user equipment, and eavesdropper in the simulated network. It provides a visual representation of the system layout and helps understand the relative positions of the network elements.

### PPR Distribution
![PPR Distribution](results/PPRDistribution.png)
This plot shows the distribution of Pilot Pollution Ratio (PPR) values calculated from the received signals. It also displays the detection threshold used to differentiate between legitimate and malicious pilot signals based on the PPR values.

### Received Signal Visualization
![Received Signal Visualization](results/ReceivedSignalVisualization.png)
This plot visualizes the magnitude of the received signal at the base station over time and across different antennas. It helps analyze the characteristics of the received signal and identify any abnormalities or patterns indicative of a pilot spoofing attack.

### User Detection Performance Summary
![User Detection Performance Summary](results/UserDetectionSummary.png)
This comprehensive plot shows the performance metrics of the user-specific attack detection across different attack scenarios and power levels. It displays F1 scores, precision, and recall for each scenario, helping to evaluate the effectiveness of the detection algorithm in identifying which specific users are being targeted by attackers.

### Attacked User Visualization
![Attacked User Visualization](results/AttackScenario_2.png)
This visualization shows which specific users are detected as being under attack. It uses color coding to distinguish between attacked and normal users and displays the detection metrics for each user along with the detection threshold.

These plots provide comprehensive insights into the performance, behavior, and efficiency of the PSA detection, user-specific attack identification, and localization methods implemented in the WSST toolkit.

## Directory Structure

```
.
├── AccuracyVsComplexity.png
├── BestAlgorithm.png
├── create_structure.sh
├── DetectionAccuracy.png
├── DetectionHeatmap.png
├── docs
│   ├── api
│   │   ├── attack.md
│   │   ├── channel.md
│   │   ├── data.md
│   │   ├── detection.md
│   │   ├── ml.md
│   │   └── signal.md
│   ├── examples
│   │   ├── advancedDetection.md
│   │   └── basicSimulation.md
│   └── gettingStarted.md
├── ErrorRates.png
├── examples
│   ├── advancedDetection.m
│   └── basicSimulation.m
├── ExecutionTimes.png
├── LICENSE
├── LocalizationAccuracy.png
├── main.asv
├── main.m
├── MDLHistogram.png
├── NetworkTopology.png
├── PPRDistribution.png
├── README.md
├── ReceivedSignalVisualization.png
├── setup.m
├── src
│   ├── attack
│   │   ├── calculatePPR.m
│   │   └── simulatePSA.m
│   ├── channel
│   │   ├── calculatePathLoss.m
│   │   ├── generateEDChannel.m
│   │   ├── generatePositions.m
│   │   └── generateUEChannels.m
│   ├── data
│   │   ├── balanceDataset.m
│   │   └── generateDataset.m
│   ├── detection
│   │   ├── calculateEigenvalues.m
│   │   ├── calculateMDL.m
│   │   ├── detectMultipleAttackers.m
│   │   ├── detectPSA.m
│   │   ├── detectPSA_MDL.m
│   │   └── detectPSA_PPR.m
│   ├── localization
│   │   ├── locateMultipleAttackers.m
│   │   └── locateSingleAttacker.m
│   ├── ml
│   │   ├── defineModelArchitecture.m
│   │   ├── ensemblePSADetection.m
│   │   ├── gradientBoostingPSADetection.m
│   │   ├── lstmPSADetection.m
│   │   ├── randomForestPSADetection.m
│   │   ├── svmPSADetection.m
│   │   ├── trainAllModels.m
│   │   └── trainAndSaveNNModels.m
│   ├── signal
│   │   ├── generateNoise.m
│   │   └── generateTrainingSequence.m
│   └── utils
│       ├── addGaussianNoise.m
│       ├── calculateErrorRates.m
│       ├── removeExtremelyLowVarianceFeatures.m
│       ├── removeZeroFeatures.m
│       └── selectBestAlgorithm.m
├── tests
│   ├── testAttack.m
│   ├── testAttackSimulation.m
│   ├── testChannelGeneration.m
│   ├── testChannel.m
│   ├── testDataGeneration.m
│   ├── testDetection.m
│   ├── testDetectionMethods.m
│   ├── testNNTraining.m
│   └── testSignal.m
├── trainedNet_Eig.mat
├── trainedNet_PPR.mat
└── visualization
    ├── plotAccuracyVsComplexity.m
    ├── plotBestAlgorithm.m
    ├── plotDetectionAccuracy.m
    ├── plotErrorRates.m
    ├── plotExecutionTime.m
    ├── plotHeatmap.m
    ├── plotLocalizationAccuracy.m
    ├── plotMDLHistogram.m
    ├── plotReceivedSignal.m
    ├── visualizeNetworkTopology.m
    └── visualizePPRDistribution.m
```

The WSST toolkit includes the following main directories:

- `src/`: Source code for all WSST functions, organized into subdirectories based on functionality:
  - `channel/`: Channel modeling functions
  - `signal/`: Signal generation functions
  - `attack/`: PSA simulation functions
  - `detection/`: PSA detection functions including user-specific attack detection:
    - `detectAttackedUsers.m`: Core function for identifying which users are under attack
    - `testDetectAttackedUsers.m`: Test cases for user detection functionality
  - `localization/`: Attacker localization functions
  - `utils/`: Utility functions
  - `data/`: Data generation functions
  - `ml/`: Machine learning functions
  - `simulation/`: Simulation frameworks including:
    - `simulateAttackedUserDetection.m`: Comprehensive simulation for user-specific attack detection
  - `visualization/`: Visualization tools including:
    - `visualizeAttackedUsers.m`: Graphical representation of attacked users
- `docs/`: Documentation, including API reference and example usage guides
- `examples/`: Example scripts demonstrating WSST usage
- `tests/`: Unit tests for WSST functions
- `visualization/`: Plotting and visualization functions

The toolkit also includes pre-generated images (`AccuracyVsComplexity.png`, `BestAlgorithm.png`, etc.), trained neural network models (`trainedNet_Eig.mat`, `trainedNet_PPR.mat`), and main simulation scripts (`main.m`, `main.asv`).

## Contributing

Contributions to WSST are welcome! Please refer to the contributing guidelines for more information.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contact

For any queries or suggestions, please open an issue on the GitHub repository.