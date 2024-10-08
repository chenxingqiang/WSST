function [x_BS, y_BS, x_UE, y_UE, x_ED, y_ED] = generatePositions(K, gridSize)
% GENERATEPOSITIONS Generate positions for BS, UEs, and ED
%
% This function generates random positions for the base station (BS),
% user equipment (UE), and eavesdropper device (ED) within a specified grid.
%
% Inputs:
%   K        - Number of user equipment
%   gridSize - Size of the simulation grid (assumed square)
%
% Outputs:
%   x_BS, y_BS - Coordinates of the base station
%   x_UE, y_UE - Coordinates of user equipment (K x 1 vectors)
%   x_ED, y_ED - Coordinates of the eavesdropper device

    % Generate BS position (center of the grid)
    x_BS = gridSize / 2;
    y_BS = gridSize / 2;

    % Generate UE positions
    x_UE = gridSize * rand(K, 1);
    y_UE = gridSize * rand(K, 1);

    % Generate ED position
    x_ED = gridSize * rand;
    y_ED = gridSize * rand;
end