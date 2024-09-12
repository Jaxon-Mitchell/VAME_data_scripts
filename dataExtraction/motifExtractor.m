% Extracts VAME motif videos from their folder
% Start by selecting the 'results' folder of your VAME project
filePath = uigetdir();
files = dir(filePath);

% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];

% Extract only those that are directories.
subFolders = files(dirFlags); % A structure with extra info.

% Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}; % Start at 3 to skip . and ..
clear dirFlags subFolders

for folder = 1:length(subFolderNames)
    % Search through all the folders in the results section (Make sure to
    % get the subdirectories of your specific project right!)
    videoPath = [filePath '/' subFolderNames{folder} '/VAME/hmm-20/cluster_videos'];
    
    videos = dir(videoPath);
    videos = {videos(3:end).name}; % Start at 3 to skip . and ..

    for video = 1:length(videos)
        movefile([videoPath '/' videos{video}], filePath);
    end
end