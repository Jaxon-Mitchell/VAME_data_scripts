% This script is meant to be used to remove undesired DLC labels that might
% corrupt a kinematics analysis using unsupervised machine learning

% Start by opening a folder that contains a lot of DLC csv's
inputFolderPath = uigetdir('/home/hoverfly/Documents/', 'Select folder containing all DLC csv''s');
outputFolderPath = uigetdir('/home/hoverfly/Documents/', 'Select folder to save your cut csv''s to');

% List of all DLC analysis
csvFileList = dir(fullfile([inputFolderPath, '/*.csv']));
csvFileList = {csvFileList.name};

% Open an example csv (it is assumed that all have same amount of columns)
% and divide by three to get amount of features present
testMatrix = readcell([inputFolderPath '/' csvFileList{1}]);

featureNo = (size(testMatrix, 2) -1) / 3;

% Print out what features can be removed
disp("Here are the following features you can remove")
for feature = 1:featureNo
    fprintf("%d - %s\n", feature, testMatrix{2,1+(3*feature)})
end
clear testMatrix

% Add into the array what columns you would like removed
numsToObliterate = input("enter (as an array) which features you want removed\n");

% Open all files in a loop and remove the undesired features, then save the
% new files elsewhere
for file = 1:length(csvFileList)
    currentFile = readcell([inputFolderPath '/' csvFileList{file}]);
    for i = length(numsToObliterate):-1:1
        index = 2 + ((numsToObliterate(i) - 1) * 3);
        currentFile(:, index:index + 2) = [];
    end
    % Write the cell to a CSV file
    writecell(currentFile, [outputFolderPath '/' csvFileList{file}])
end
