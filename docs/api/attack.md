# Attack Simulation API

This document describes the functions available in the `src/attack` directory of the Wireless Security Simulation Toolkit (WSST) for simulating pilot spoofing attacks in massive MIMO systems.

## Functions

### `calculatePPR`

```matlab
function PPR = calculatePPR(K, M, tau, P_UE, Beta_UE, Y, Phi, sigma_n_2)
```

Calculates the Pilot Pollution Ratio (PPR) for each user based on the received signal and system parameters.

#### Inputs
- `K`: Number of user devices
- `M`: Number of base station antennas
- `tau`: Length of training sequence
- `P_UE`: Transmit power of user equipment
- `Beta_UE`: Path loss matrix for user equipment (M x K)
- `Y`: Received signal at the base station (M x tau)
- `Phi`: Training sequence matrix (tau x K)
- `sigma_n_2`: Noise variance

#### Output
- `PPR`: Pilot Pollution Ratio for each user (1 x K)

### `simulatePSA`

```matlab
function Y = simulatePSA(h_UE, g_ED, Phi, P_UE, P_ED, N, indAttPres, indAttUE)
```

Simulates the received signal at the base station under a potential pilot spoofing attack scenario.

#### Inputs
- `h_UE`: Channel matrix for legitimate users (M x K)
- `g_ED`: Channel vector for eavesdropper (M x 1)
- `Phi`: Training sequence matrix (tau x K)
- `P_UE`: Transmit power of user equipment
- `P_ED`: Transmit power of eavesdropper
- `N`: Noise matrix (M x tau)
- `indAttPres`: Indicator of attack presence (0 or 1)
- `indAttUE`: Index of the attacked user

#### Output
- `Y`: Received signal at the base station (M x tau)

Note: This function assumes that the eavesdropper, if present, attacks only one legitimate user's pilot sequence.