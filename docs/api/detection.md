# Detection Methods API

This document describes the functions available in the `src/detection` directory of the Wireless Security Simulation Toolkit (WSST) for detecting pilot spoofing attacks in massive MIMO systems.

## Functions

### `calculateEigenvalues`

```matlab
function lambda = calculateEigenvalues(Y, N)
```

Calculates the eigenvalues of the sample covariance matrix of the received signal.

#### Inputs
- `Y`: Received signal at the base station (M x tau)
- `N`: Noise matrix (M x tau)

#### Output
- `lambda`: Eigenvalues of the sample covariance matrix

### `calculateMDL`

```matlab
function MDL = calculateMDL(lambda, M, K, tau)
```

Calculates the Minimum Description Length (MDL) criterion for detecting the presence of an attack.

#### Inputs
- `lambda`: Eigenvalues of the sample covariance matrix
- `M`: Number of base station antennas
- `K`: Number of user devices
- `tau`: Length of training sequence

#### Output
- `MDL`: MDL criterion value

### `detectMultipleAttackers`

```matlab
function [detAcc_PPR, detAcc_MDL, detAcc_PPR_NN, detAcc_Eig_NN] = detectMultipleAttackers(X_feature_PPR, X_feature_Eig, y_label, P_ED, P_ED_dBm, nbLoc, nbChanReal)
```

Detects the presence of multiple attackers using different detection methods.

#### Inputs
- `X_feature_PPR`: PPR feature matrix
- `X_feature_Eig`: Eigenvalue feature matrix
- `y_label`: Label vector
- `P_ED`: Transmit power of eavesdropper (in watts)
- `P_ED_dBm`: Transmit power of eavesdropper (in dBm)
- `nbLoc`: Number of different location realizations
- `nbChanReal`: Number of channel realizations per location

#### Outputs
- `detAcc_PPR`: Detection accuracy of the PPR method
- `detAcc_MDL`: Detection accuracy of the MDL method
- `detAcc_PPR_NN`: Detection accuracy of the PPR-NN method
- `detAcc_Eig_NN`: Detection accuracy of the Eig-NN method

### `detectPSA`

```matlab
function [detected, threshold] = detectPSA(Y, N, M, K, tau, method)
```

Detects the presence of a pilot spoofing attack using a specified detection method.

#### Inputs
- `Y`: Received signal at the base station (M x tau)
- `N`: Noise matrix (M x tau)
- `M`: Number of base station antennas
- `K`: Number of user devices
- `tau`: Length of training sequence
- `method`: Detection method ('MDL' or 'PPR')

#### Outputs
- `detected`: Binary indicator of attack presence (0 or 1)
- `threshold`: Detection threshold value

### `detectPSA_MDL`

```matlab
function [detected, threshold] = detectPSA_MDL(Y, N, M, K, tau)
```

Detects the presence of a pilot spoofing attack using the MDL method.

#### Inputs
- `Y`: Received signal at the base station (M x tau)
- `N`: Noise matrix (M x tau)
- `M`: Number of base station antennas
- `K`: Number of user devices
- `tau`: Length of training sequence

#### Outputs
- `detected`: Binary indicator of attack presence (0 or 1)
- `threshold`: Detection threshold value

### `detectPSA_PPR`

```matlab
function [detected, threshold] = detectPSA_PPR(Y, N, M, K, tau, P_UE, Beta_UE, Phi, sigma_n_2)
```

Detects the presence of a pilot spoofing attack using the PPR method.

#### Inputs
- `Y`: Received signal at the base station (M x tau)
- `N`: Noise matrix (M x tau)
- `M`: Number of base station antennas
- `K`: Number of user devices
- `tau`: Length of training sequence
- `P_UE`: Transmit power of user equipment
- `Beta_UE`: Path loss matrix for user equipment (M x K)
- `Phi`: Training sequence matrix (tau x K)
- `sigma_n_2`: Noise variance

#### Outputs
- `detected`: Binary indicator of attack presence (0 or 1)
- `threshold`: Detection threshold value