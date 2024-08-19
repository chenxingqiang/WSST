# Channel Modeling API

This document describes the functions available in the `src/channel` directory of the Wireless Security Simulation Toolkit (WSST) for modeling the wireless channels in massive MIMO systems.

## Functions

### `calculatePathLoss`

```matlab
function Beta = calculatePathLoss(x_pos, y_pos, x_ref, y_ref, alpha, beta_0)
```

Calculates the path loss between a set of positions and a reference position using the log-distance path loss model.

#### Inputs
- `x_pos`: x-coordinates of the positions (1 x N)
- `y_pos`: y-coordinates of the positions (1 x N)
- `x_ref`: x-coordinate of the reference position
- `y_ref`: y-coordinate of the reference position
- `alpha`: Path loss exponent
- `beta_0`: Path loss at reference distance

#### Output
- `Beta`: Path loss values (1 x N)

### `generateEDChannel`

```matlab
function g_ED = generateEDChannel(M, K, r_ED, x_BS, y_BS, x_ED, y_ED, alpha, beta_0)
```

Generates the wireless channel between the eavesdropper and the base station.

#### Inputs
- `M`: Number of base station antennas
- `K`: Number of user devices
- `r_ED`: Eavesdropper's channel correlation matrix (K x K)
- `x_BS`: x-coordinate of the base station
- `y_BS`: y-coordinate of the base station
- `x_ED`: x-coordinate of the eavesdropper
- `y_ED`: y-coordinate of the eavesdropper
- `alpha`: Path loss exponent
- `beta_0`: Path loss at reference distance

#### Output
- `g_ED`: Eavesdropper's channel vector (M x 1)

### `generatePositions`

```matlab
function [x_pos, y_pos] = generatePositions(num_pos, x_min, x_max, y_min, y_max)
```

Generates random positions within a specified rectangular area.

#### Inputs
- `num_pos`: Number of positions to generate
- `x_min`: Minimum x-coordinate of the area
- `x_max`: Maximum x-coordinate of the area
- `y_min`: Minimum y-coordinate of the area
- `y_max`: Maximum y-coordinate of the area

#### Outputs
- `x_pos`: x-coordinates of the generated positions (1 x num_pos)
- `y_pos`: y-coordinates of the generated positions (1 x num_pos)

### `generateUEChannels`

```matlab
function H_UE = generateUEChannels(M, K, r_UE, x_BS, y_BS, x_UE, y_UE, alpha, beta_0)
```

Generates the wireless channels between the user devices and the base station.

#### Inputs
- `M`: Number of base station antennas
- `K`: Number of user devices
- `r_UE`: User devices' channel correlation matrix (K x K)
- `x_BS`: x-coordinate of the base station
- `y_BS`: y-coordinate of the base station
- `x_UE`: x-coordinates of the user devices (1 x K)
- `y_UE`: y-coordinates of the user devices (1 x K)
- `alpha`: Path loss exponent
- `beta_0`: Path loss at reference distance

#### Output
- `H_UE`: User devices' channel matrix (M x K)