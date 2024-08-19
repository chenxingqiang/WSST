# Signal Generation API

This document describes the functions available in the `src/signal` directory of the Wireless Security Simulation Toolkit (WSST) for generating signals and sequences used in pilot spoofing attack simulations.

## Functions

### `generateNoise`

```matlab
function N = generateNoise(M, tau, sigma_n_2)
```

Generates a noise matrix with specified dimensions and variance.

#### Inputs
- `M`: Number of base station antennas
- `tau`: Length of training sequence
- `sigma_n_2`: Noise variance

#### Output
- `N`: Noise matrix (M x tau)

### `generateTrainingSequence`

```matlab
function Phi = generateTrainingSequence(tau, K)
```

Generates a matrix of orthogonal training sequences for user devices.

#### Inputs
- `tau`: Length of training sequence
- `K`: Number of user devices

#### Output
- `Phi`: Training sequence matrix (tau x K)