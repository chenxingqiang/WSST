# Data Generation API

This document describes the functions available in the `src/data` directory of the Wireless Security Simulation Toolkit (WSST) for generating datasets for training and evaluating machine learning models.

## Functions

### `balanceDataset`

```matlab
function [X_balanced, y_balanced] = balanceDataset(X, y, method)
```

Balances the dataset by oversampling the minority class or undersampling the majority class.

#### Inputs
- `X`: Feature matrix (n x d)
- `y`: Label vector (n x 1)
- `method`: Balancing method ('oversample' or 'undersample')

#### Outputs
- `X_balanced`: Balanced feature matrix
- `y_balanced`: Balanced label vector

### `generateDataset`

```matlab
function [X, y] = generateDataset(M, K, tau, P_UE, P_ED, r_UE, r_ED, x_BS, y_BS, x_UE, y_UE, x_ED, y_ED, alpha, beta_0, N, numSamples, indAttPres)
```

Generates a dataset for training and evaluating pilot spoofing attack detection models.

#### Inputs
- `M`: Number of base station antennas
- `K`: Number of user devices
- `tau`: Length of training sequence
- `P_UE`: Transmit power of user equipment
- `P_ED`: Transmit power of eavesdropper
- `r_UE`: User devices' channel correlation matrix (K x K)
- `r_ED`: Eavesdropper's channel correlation matrix (K x K)
- `x_BS`: x-coordinate of the base station
- `y_BS`: y-coordinate of the base station
- `x_UE`: x-coordinates of the user devices (1 x K)
- `y_UE`: y-coordinates of the user devices (1 x K)
- `x_ED`: x-coordinate of the eavesdropper
- `y_ED`: y-coordinate of the eavesdropper
- `alpha`: Path loss exponent
- `beta_0`: Path loss at reference distance
- `N`: Noise matrix (M x tau)
- `numSamples`: Number of samples to generate
- `indAttPres`: Indicator of attack presence (0 or 1)

#### Outputs
- `X`: Feature matrix (numSamples x (M * tau))
- `y`: Label vector (numSamples x 1)