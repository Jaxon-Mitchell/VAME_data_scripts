% Requires ffmpeg, will merge all video files within a folder

% If FFMPEG doesn't work on Ubuntu, launch matlab using this command:
% LD_PRELOAD=/lib/x86_64-linux-gnu/libstdc++.so.6 matlab

% Input amount of motifs used
noMotifs = 20;
% Input folder to videos to organise
filePath = '/home/hoverfly/Documents/Behaviour/allBehaviourAnalysis/Results';
% Make folder to place compiled motifs into
mkdir([filePath '/compilations'])

% Loop over all motifs and search for the correct videos that match
for motif = 0:noMotifs-1
    videos = dir([filePath '/motif_' num2str(motif) '/*.avi']);
    
    % Get only the folder names into a cell array.
    videos = {videos(1:end).name}; 

    % Generate a text file of all videos 
    fid = fopen([filePath '/videos.txt'], 'wt' );
    for video = 1:length(videos)
      fprintf( fid, 'file ''motif_%d/%s''\n', motif, videos{video});
    end
    fclose(fid);

    % Use ffmpeg to concatenate all videos within the text file we made
    system(['ffmpeg -f concat -safe 0 -i ' filePath '/videos.txt -c copy ' filePath '/compilations/motif_' num2str(motif) '_compilation.avi']);
    system(['rm ' filePath '/videos.txt']);
end
