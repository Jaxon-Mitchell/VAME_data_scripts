% This script is meant to be used to remove undesired DLC labels that might
% corrupt a kinematics analysis using unsupervised machine learning

% Start by opening a folder that contains a lot of DLC csv's

% Open an example csv (it is assumed that all have same amount of columns)
% and divide by three to get amount of features present

% Print out what columns can be removed

%% Add into the array what columns you would like removed

featuresToRemove = [3, 6, 8];

% Open all files in a loop and remove the undesired features, then save the
% new files elsewhere