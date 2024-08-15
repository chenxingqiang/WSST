% SETUP Set up the MATLAB path for WSST
%
% This script adds all necessary WSST directories to the MATLAB path.
% Run this script before using any WSST functions.

% Get the directory of this script
rootDir = fileparts(mfilename('fullpath'));

% Add all subdirectories to the MATLAB path
addpath(genpath(rootDir));

% Remove .git directory from path if it exists
gitDir = fullfile(rootDir, '.git');
if exist(gitDir, 'dir')
    rmpath(genpath(gitDir));
end

% Display success message
disp('WSST paths have been set up successfully.');
disp('You can now use WSST functions in your MATLAB sessions.');
disp('To make this change permanent, use the "savepath" command.');