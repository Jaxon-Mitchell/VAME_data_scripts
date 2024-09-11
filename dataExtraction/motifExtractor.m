% Extracts VAME motif videos from their folder
% filePath = uigetdir();
filePath = '/home/hoverfly/Documents/Behaviour/Flying/Results';
files = dir(filePath);

% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];

% Extract only those that are directories.
subFolders = files(dirFlags); % A structure with extra info.

% Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}; % Start at 3 to skip . and ..
clear dirFlags subFolders

for folder = 1:length(subFolderNames)
    videoPath = [filePath '/' subFolderNames{folder} '/VAME/kmeans-15/cluster_videos'];
    
    videos = dir(videoPath);
    videos = {videos(3:end).name}; % Start at 3 to skip . and ..

    for video = 1:length(videos)
        movefile([videoPath '/' videos{video}], filePath);
    end
end