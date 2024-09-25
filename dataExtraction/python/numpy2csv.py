# This script is designed to extract np arrays made from VAME and convert them into a language neutral .csv format

import pandas as pd
import numpy as np
import os

inputDirectory = "/home/hoverfly/Documents/Behaviour/allBehaviourAnalysis/behaviour_analysis_loomingStimuli-Sep23-2024/results/"
outputDirectory = "/home/hoverfly/Documents/Behaviour/allBehaviourAnalysis/behaviour_analysis_loomingStimuli-Sep23-2024/csvOutput/"

folders = os.listdir(inputDirectory)

for folder in folders:
    layer = 1
    experiment = os.walk(inputDirectory + folder)
    for (dirpath, dirnames, filenames) in experiment:
        results = []
        if layer == 3:
            results.extend(filenames)
            # Convert all .nmpy files into .csv files and save to output folder
            for expFile in results:
                # Load raw numpy array
                dataArray = np.load(dirpath + "/" + expFile)
                # convert array into dataframe 
                dataFrame = pd.DataFrame(dataArray) 
                # save the dataframe as a csv file 
                dataFrame.to_csv(outputDirectory + expFile.split(".npy")[0] + ".csv")
            break
        layer += 1
