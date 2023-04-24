
%This is a test to run the TerraceM_photon function to map marine terraces
%using photon data.
%The data can be downloaded as .csv format from the openaltimetry webpage
%(www.openaltimetry.org) in the section IceSat-2 data. This requires
%selecting the appropiate profiles and downloading the photon data from the
%visualization interface in openaltimetry



%% RUN TerraceM_photon
clear

filename='photon_2020-07-24_gt3l_t438_1682201062883.csv';%file name downloaded from openaltimetry and stored in the same folder as this script and functions
level = 1; %level you want to map
TerraceM_photon(filename,level) %run the function

%% Display mapped shoreline angles

filename='PH_MAP_photon_2020-07-24_gt3l_t438_1682201062883.csv.mat';% .mat file saved automatically after running the TerraceM_photon function
TerraceM_plot_photon(filename);%run plot function