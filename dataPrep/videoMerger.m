% Requires ffmpeg, this script will truncate videos based on user 
% parameters and merge them into either one compiled video or a series of
% videos. This will also assist with merging .csv's together.

% If FFMPEG doesn't work on Ubuntu, launch matlab using this command:
% LD_PRELOAD=/lib/x86_64-linux-gnu/libstdc++.so.6 matlab

%% Define Variables
% Input names of experiments used
experiments = ["Dorsal_Loom_Fast", "Dorsal_Loom_HalfFast", ...
    "Dorsal_Loom_Halfslow", "Dorsal_Loom_Slow", ...
    "Ventral_Loom_Fast", "Ventral_Loom_HalfFast", ...
    "Ventral_Loom_HalfSlow", "Ventral_Loom_Slow", ...
    "Dorsal_Loom_control", "Ventral_Loom_control"];
% experiments = "Combined";
% Input folder to videos to organise
filePath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/2TB Storage/Saved Data/', 'Select folder containing all experiments');
warning('off')
mkdir([filePath '/truncated'])
warning('on')
% Get list of all the videos in the folder
videos = dir([filePath '/*.mp4']);
% Get only the video names into a cell array.
videos = {videos(1:end).name}; 

%% Truncate the videos part of the data set
% Loop over all videos
for video = 1:length(videos)
    % Just copy the control videos, as we want them whole
    if ~isempty(regexp(videos{video}, 'control', 'ONCE'))
        copyfile([filePath '/' videos{video}], [filePath '/truncated/' videos{video}])
        continue
    end
    % Use ffmpeg to cut the video from the first three seconds (-ss) to the
    % end of the video (-to) and copy it into a dedicated folder
    system(['ffmpeg -i ''' filePath '/' videos{video} ''' -ss 00:00:03  -to 00:10:00 -c:v libx264 -c:a aac ''' filePath '/truncated/' videos{video} '''']);
end

%% Find how many frames are in each video and use that to cut down the .csv files
% Get list of all the truncated videos
truncatedVids = dir([filePath '/truncated/*.mp4']);
% Get only the video names into a cell array.
truncatedVids = {truncatedVids(1:end).name};

for video = 1:length(truncatedVids)
    % Grab the name of the current experiment so we can find the DLC file
    currentExperiment = strsplit(truncatedVids{video}, '.mp4');
    currentExperiment = currentExperiment{1};
    % Do not need to truncate control videos
    if ~isempty(regexp(videos{video}, 'control', 'ONCE'))
        copyfile([filePath '/' currentExperiment '.csv'], [filePath '/truncated/' currentExperiment '.csv'])
        continue
    end
    % Get the exact number of frames in each video
    [~, videoLengths] = system(['ffmpeg -i ''' filePath '/truncated/' truncatedVids{video} ''' -map 0:v:0 -c copy -f null -y /dev/null 2>&1 | grep -Eo ''frame= *[0-9]+ *'' | grep -Eo ''[0-9]+'' | tail -1']);
    % Read the corresponding DLC .csv as a cell array 
    experimentAnalysis = readcell([filePath '/' currentExperiment '.csv' ]);
    % Add the headers of deeplabcut into the cell array
    truncatedAnalysis = experimentAnalysis(1:3, 1:end);
    % Add the data representing the truncated video
    truncatedAnalysis = [truncatedAnalysis; experimentAnalysis((end - str2double(videoLengths) + 1):end, 1:end)]; %#ok<AGROW> Reset at end of every loop, doesn't grow
    % Save the data set into the truncated folder
    writecell(truncatedAnalysis, [filePath '/truncated/' currentExperiment '.csv'])
end

%% Merge the truncated videos and csv's together by experiment type
% To do this, please make sure that you've put all videos and csv's in the
% same folder first

% Get updated list of analysis .csv's and videos
experimentAnalysis = dir([filePath '/truncated/*.csv']);
experimentAnalysis = {experimentAnalysis(1:end).name};
truncatedVids = dir([filePath '/truncated/*.mp4']);
truncatedVids = {truncatedVids(1:end).name};

for experiment = 1:length(experiments)
    % Create a text file listing all the videos to be merged, relative to
    % where the main filepath is
    fid = fopen([filePath '/videos.txt'], 'wt');
    for video = 1:length(truncatedVids)
      if isempty(regexp(truncatedVids{video}, experiments(experiment), 'once'))
          continue
      end
      fprintf(fid, 'file ''truncated/%s''\n', truncatedVids{video});
    end
    fclose(fid);
    % Concatenate all the videos of a single experiment type using ffmpeg
    system(['ffmpeg -f concat -safe 0 -i ''' filePath '/videos.txt'' -c copy ''' filePath '/truncated/' convertStringsToChars(experiments(experiment)) '_Combined.mp4''']);
    system(['rm ''' filePath '/videos.txt''']);

    % Combine all .csv's of the same experiment
    clear combinedAnalysis
    for analysis = 1:length(experimentAnalysis)
        % Use only matches for the current experiment
        if isempty(regexp(experimentAnalysis{analysis}, experiments(experiment), 'once'))
          continue
        end
        % Read the corresponding DLC .csv as a cell array 
        currentAnalysis = readcell([filePath '/truncated/' experimentAnalysis{analysis}]);
        % Init the combined analysis file if not setup already
        if ~exist('combinedAnalysis', 'var')
            combinedAnalysis = currentAnalysis;
            continue
        end
        % Add the data representing the truncated video
        combinedAnalysis = [combinedAnalysis; currentAnalysis(4:end, 1:end)]; %#ok<AGROW>
    end
    % Reset frame data for the combined analysis file
    for i = 1:size(combinedAnalysis, 1) - 3
        combinedAnalysis{i + 3, 1} = i;
    end
    % Save the data set into the truncated folder
    writecell(combinedAnalysis, [filePath '/truncated/' experiments{experiment} '_Combined.csv'])
end

%% Cleans up all now unused truncated files, leaving only the combined files

% Get list of all .csv's and .mp4's
experimentAnalysis = dir([filePath '/truncated/*.csv']);
experimentAnalysis = {experimentAnalysis(1:end).name};
truncatedVids = dir([filePath '/truncated/*.mp4']);
truncatedVids = {truncatedVids(1:end).name};

% Delete all .csv's that don't have 'Combined' in them
for i = 1:length(experimentAnalysis)
    if ~isempty(regexp(experimentAnalysis{i},'Combined', 'once'))
        continue
    end
    delete([filePath '/truncated/' experimentAnalysis{i}])
end

% Do the same for all .mp4 files
for i = 1:length(truncatedVids)
    if ~isempty(regexp(truncatedVids{i},'Combined', 'once'))
        continue
    end
    delete([filePath '/truncated/' truncatedVids{i}])
end
