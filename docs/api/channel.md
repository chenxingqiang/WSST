# Channel Module

This module provides functions for generating and manipulating wireless channels.

## Functions

### generateUEChannels

```matlab
h_UE = generateUEChannels(M, K, Beta_UE)
```

Generates the channel matrix for user equipment (UE).

#### Inputs
- `M`: Number of base station antennas
- `K`: Number of user devices
- `Beta_UE`: Path loss matrix (M x K)

#### Output
- `h_UE`: UE channel matrix (M x K)

#### Example

```matlab
M = 100;
K = 10;
Beta_UE = ones(M, K);
h_UE = generateUEChannels(M, K, Beta_UE);
```

#### Notes
- The function assumes Rayleigh fading.
- The channel power is controlled by the `Beta_UE` matrix.