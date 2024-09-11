%% Renames .csv files based on parameter files

% This script is used to merge all DLC models from a single video into one
% .csv file, so it can be used for vame
inputFolderPath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/Saved Data/', 'Select folder containing all experiments');
% Get output destination
outputFolderPath = uigetdir('/mnt/f7f78664-d0bb-46b3-b287-f7b88456453e/Saved Data/', 'Select folder for file output');
% List of all folders (experiments)
experimentDayList = dir(inputFolderPath);


% Ignore first two entries '.' and '..' and loop through all folders
for folder = 3:length(experimentDayList)
    % What kind of experiments are we re-naming? (Uncomment your choice)
    % experimentType = 'REVideo';
    experimentType = 'REvideo_Nonflying';
    experimentDay = experimentDayList(folder).name;
    % Get fly number
    flyNo = dir(fullfile([inputFolderPath '/' experimentDay]));
    % Get pathway to videos and .csv's
    currentFolderPath = [inputFolderPath '/' experimentDay '/' flyNo(3).name '/' experimentType];

    % List of all parameter .mat files
    parameterFileList = dir(fullfile([inputFolderPath '/' experimentDay '/' flyNo(3).name '/parameters' '/*' '.mat']));
    
    % List of all videos
    videoFileList = dir(fullfile([currentFolderPath, '/*.mp4']));
    % List of all DLC analysis
    csvFileList = dir(fullfile([currentFolderPath, '/*.csv']));

    % If we don't find any videos in a non-flying folder, double check if non-flying was stored elsewhere
    if isempty(videoFileList)
        extraTypes = {'REvideo', 'REVideo'};
        % Loop over other video folder types to find our data
        for i = 1:length(extraTypes)
            currentFolderPath = [inputFolderPath '/' experimentDay '/' flyNo(3).name '/' extraTypes{i}];
            videoFileList = dir(fullfile([currentFolderPath, '/*.mp4']));
            csvFileList = dir(fullfile([currentFolderPath, '/*.csv']));
            csvFileTest = {csvFileList(1:end).name};
            if strcmpi(experimentType, 'REVideo')
                % Double check the folder to see if this is a non-flying dataset
                nameTest = regexp(csvFileTest, 'NonFlying', 'ignorecase'); %#ok<UNRCH>
                wrongFolder = false;
                for j = 1:length(csvFileTest)
                    if ~isempty(nameTest{j})
                        wrongFolder = true;
                        break
                    end
                end
            else
                % If we're looking for non-flying data, check if its there
                nameTest = regexp(csvFileTest, 'NonFlying', 'ignorecase');
                wrongFolder = true;
                for j = 1:length(csvFileTest)
                    if ~isempty(nameTest{j})
                        wrongFolder = false;
                        break
                    end
                end
            end
            % If it turns out to be the correct folder, escape this nightmare
            if wrongFolder == false
                break
            end
        end
    end

    % If we cannot find a match for the files we need, check next folder
    if wrongFolder == true
        continue
    end
   
    clear csvFileTest

    % Print a status message so the user knows what's going on internally
    folderMessage = sprintf('Re-naming csv''s for folder %d out of %d\n', (folder - 2), (length(experimentDayList) - 2));
    disp(folderMessage);
    
    %Initialise variables
    clear temp
    
    %Get only the combined .csv files
    count = 1;
    for i = 1:length(csvFileList)
        if isempty(regexp(csvFileList(i).name, 'DLC', 'ONCE'))
            temp(count) = csvFileList(i); %#ok<SAGROW>
            count = count + 1;
        end
    end
    
    csvFileList = temp;
    clear temp count
    

    % Loop through each video so we can combine alike .csv's
    for video = 1:length(videoFileList)
        % Get video name on its own
        videoName = videoFileList(video).name;
        videoName = strsplit(videoName, '.mp4');
        videoName = videoName{1};
        % Get video time on its own
        videoTime = strsplit(videoName, ' ');
        videoTime = str2double(erase(videoTime{2}, '_'));

        % Ignore labelled DLC videos as we don't need them
        if ~isempty(regexp(videoName, 'labeled', 'ignorecase'))
            continue
        end

        % Ignore hidden videos as they cause issues
        if videoName(1) == '.'
            continue
        end

        % Check through parameters folder to find a matching time
        for i = 1:length(parameterFileList)
            % Get stim time on its own
            stimName = parameterFileList(i).name;
            stimName = strsplit(stimName, '.mat');
            stimName = stimName{1};
            stimTime = strsplit(stimName, ' ');
            stimTime = str2double(erase(stimTime{2}, '_'));

            if abs(stimTime - videoTime) <= 2
                experimentName = strsplit(parameterFileList(i).name, '-');
                experimentName = experimentName{1};
                break
            end
        end
    
        % Print a status message so the user knows what's going on internally
        message = sprintf('Re-naming analysis %d out of %d\n', video, length(videoFileList));
        disp(message);
    
        newName = strsplit(videoName, 'RE-');
        newName = newName{2};
        newName = [experimentName ' ' newName]; %#ok<AGROW> It is reset every loop
    
        warning('off')
        mkdir([outputFolderPath '/' experimentName])
        warning('on')
    
        ogVideo = [currentFolderPath '/' videoName '.mp4'];
        newVideo = [outputFolderPath '/' experimentName '/' newName '.mp4'];
    
        copyfile(ogVideo, newVideo);
    
        ogCSV = [currentFolderPath '/' videoName '.csv'];
        newCSV = [outputFolderPath '/' experimentName '/' newName '.csv'];
    
        copyfile(ogCSV, newCSV);
    
        clear newName
    
        % Clear analysis video message for a clean command window 
        for character = 1 : length(message) + 1
            fprintf('\b')
        end
    end
    % Delete folder message
    for character = 1 : length(folderMessage) + 1
        fprintf('\b')
    end
end
disp("Done!")
