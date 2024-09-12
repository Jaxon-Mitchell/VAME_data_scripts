% This script organises VAME motifs from different videos into folders for
% analysis.

% Input amount of motifs used
noMotifs = 20;
% Input folder to videos to organise
filePath = '/home/hoverfly/Documents/Behaviour/allBehaviourAnalysis/Results';

videos = dir([filePath '/*.avi']);

% Get only the folder names into a cell array.
videos = {videos(1:end).name}; 

for motif = 0:noMotifs-1
    % Create a directory for the current motif
    warning('off')
    mkdir([filePath '/motif_' num2str(motif)])
    warning('on')

    % Check which videos belong to the current motif
    motifTest = regexp(videos, ['motif_' num2str(motif) '.avi']);
    motifTest = ~cellfun(@isempty, motifTest);
    motifTest = find(motifTest);

    for video = 1:length(motifTest)
        movefile([filePath '/' videos{motifTest(video)}], [filePath '/motif_' num2str(motif)])
    end
end