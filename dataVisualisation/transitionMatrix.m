% This script is meant to develop a transition matrix between all motifs
% found using VAME

% We want to do this over multiple videos, so get user to select the folder
% containing all VAME results, so the script can loop over each folder



% First, we load our data as an array

% Search through the whole array to find what the biggest motif number is,
% noting that for n motifs they are indexed from 0 to n-1

% Then, we want to define a nxn array, where n represents the number of
% motifs we have

% 